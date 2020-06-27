import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/model/parsed_ingredient.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/service/spoonacular_service.dart';
import 'package:home_cooked/util/fraction_util.dart';
import 'package:home_cooked/util/string_util.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

class RecipeService {
  final _log = Logger('RecipeService');
  final Uuid _uuid = Uuid();
  final CollectionReference _recipes;
  final Firestore _db;
  final StorageReference _storageReference;
  final SpoonacularService _spoonacularService;

  RecipeService()
      : this._recipes = locator.get<Firestore>().collection("recipes"),
        this._db = locator.get<Firestore>(),
        this._storageReference =
            FirebaseStorage.instance.ref().child("recipe_photos/"),
        this._spoonacularService = locator.get<SpoonacularService>();

  Stream<QuerySnapshot> getRecipes(String uid,
      {String sortBy = 'name',
      bool sortDesc = false,
      List filterBy = const [],
      String keywords = '',
      int maxResults = 0}) {
    Query query = _recipes.where("uid", isEqualTo: uid);

    if (keywords != '' && keywords != null) {
      query = query.where("keywords",
          arrayContainsAny: keywords.toLowerCase().split(" "));
    } else if (!listEquals(filterBy, []) &&
        !listEquals(filterBy, ['all']) &&
        filterBy != null) {
      query = query.where("tags", arrayContainsAny: filterBy);
    }
    _log.info("sorting by $sortBy, descending = $sortDesc");
    query = query.orderBy(sortBy, descending: sortDesc);
    if (maxResults > 0) {
      query = query.limit(maxResults);
    }
    return query.snapshots();
  }

  Future<List<String>> getTagList() async {
    String uid = (await FirebaseAuth.instance.currentUser()).uid;
    QuerySnapshot query =
        await _recipes.where("uid", isEqualTo: uid).getDocuments();
    var tagSet = Set<String>();
    query.documents
        .where((doc) => doc.data['tags'] != null)
        .forEach((doc) => tagSet.addAll(List.from(doc.data['tags'])));
    var tagList = tagSet.toList();
    tagList.sort();
    return tagList;
  }

  Stream<DocumentSnapshot> getRecipe(String id) {
    return _recipes.document(id).snapshots();
  }

  Future<void> deleteRecipe(String id) {
    return _recipes.document(id).delete();
  }

  Future<void> scaleRecipe(String id, double scale) {
    var recipeRef = _recipes.document(id);
    return _db.runTransaction((transaction) {
      return transaction.get(recipeRef).then((recipeDoc) async {
        if (!recipeDoc.exists) {
          throw "Recipe does not exist!";
        }

        Map<String, dynamic> updatedData = {
          'scale': scale,
        };
        if (recipeDoc.data['ingredients'] != null && scale != 1.0) {
          updatedData['scaledIngredients'] = await _scaleIngredients(scale, List.from(recipeDoc.data['ingredients']));
        }
        transaction.update(recipeRef, updatedData);
      });
    }).then((value) => id);
  }

  Future<String> updateRecipe(String id,
      { String name,
        List<String> ingredients,
        List<String> instructions,
        String imageUrl,
        int prepTime,
        int cookTime,
        int readyTime,
        String servings,
        String source,
        String notes,
        List<String> tags}) {

    var ingredientsChecksum = _calculateChecksum(ingredients.join("\n"));

    if (StringUtil.isNullOrEmpty(id)) {
      return FirebaseAuth.instance
          .currentUser()
          .then((user) => _recipes.add({
                "name": name,
                "ingredients": ingredients,
                "scale": 1.0,
                "ingredientsChecksum": ingredientsChecksum,
                "instructions": instructions,
                "imageUrl": imageUrl,
                "prepTime": prepTime,
                "cookTime": cookTime,
                "readyTime": readyTime,
                "source": source,
                "notes": notes,
                "servings": servings,
                "keywords": _buildKeywords(name, ingredients),
                "tags": tags,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                'viewedAt': FieldValue.serverTimestamp(),
                'viewedTimes': 1,
                'uid': user.uid,
              }))
          .then((ref) => ref.documentID);
    }
    var recipeRef = _recipes.document(id);
    return _db.runTransaction((transaction) {
      return transaction.get(recipeRef).then((recipeDoc) async {
        if (!recipeDoc.exists) {
          throw "Recipe does not exist!";
        }

        String currentChecksum = recipeDoc.data['ingredientsChecksum'];
        String currentName = recipeDoc.data['name'];
        double currentScale = recipeDoc.data['scale'];

        var updatedData = {
          "name": name,
          "imageUrl": imageUrl,
          "ingredients": ingredients,
          "ingredientsChecksum": ingredientsChecksum,
          "instructions": instructions,
          "prepTime": prepTime,
          "cookTime": cookTime,
          "readyTime": readyTime,
          "servings": servings,
          "source": source,
          "notes": notes,
          "tags": tags,
          "updatedAt": FieldValue.serverTimestamp()
        };

        if (ingredientsChecksum != currentChecksum || name != currentName) {
          updatedData['keywords'] = _buildKeywords(name, ingredients);
        }

        if (currentScale != null && currentScale != 1.0 && ingredientsChecksum != currentChecksum) {
          updatedData['scaledIngredients'] = await _scaleIngredients(currentScale, ingredients);
        }

        transaction.update(recipeRef, updatedData);
      });
    }).then((value) => id);
  }

  List<String> _buildKeywords(String name, List<String> ingredients) {
    var wordList = name.split(" ");
    //todo since we add ingredient parsing, we should probably ignore quantities and units
    //todo ignore punctuation in words?  smores vs s'mores?
    ingredients
        .where((s) => !s.startsWith("//"))
        .forEach((s) => wordList.addAll(s.split(" ")));
    var wordSet = wordList.map((s) => s.toLowerCase()).toSet();

    var subWordSet = Set<String>();
    wordSet.forEach((word) {
      for (var i = 2; i <= word.length; i++) {
        subWordSet.add(word.substring(0, i));
      }
    });
    return subWordSet.toList();
  }

  Future<void> markViewed(String id) {
    var recipeRef = _recipes.document(id);
    return _db
        .runTransaction((transaction) {
          return transaction.get(recipeRef).then((recipeDoc) {
            if (!recipeDoc.exists) {
              throw "Recipe does not exist!";
            }
            transaction.update(recipeRef, {
              "viewedTimes": recipeDoc.data['viewedTimes'] == null
                  ? 1
                  : recipeDoc.data['viewedTimes'] + 1,
              "viewedAt": FieldValue.serverTimestamp()
            });
          });
        })
        .then((value) => {})
        .catchError(
            (err) => _log.warning("Error marking recipe as viewed", err));
  }

  Future<void> updateTags(String id, List newTagList) {
    var recipeRef = _recipes.document(id);
    return _db
        .runTransaction((transaction) {
          return transaction.get(recipeRef).then((recipeDoc) {
            if (!recipeDoc.exists) {
              throw "Recipe does not exist!";
            }
            transaction.update(recipeRef, {"tags": newTagList});
          });
        })
        .then((value) => {_log.info("Recipe $id updated")})
        .catchError((err) => _log.warning("Error updating recipe tags", err));
  }

  Future<StorageMetadata> _getImageMetdata() async {
    var user = await FirebaseAuth.instance.currentUser();
    return StorageMetadata(customMetadata: {'uid': user.uid});
  }

  Future<dynamic> uploadImageFromDisk(File image) async {
    var storageReference = _storageReference.child("/" + _uuid.v1());
    var metadata = await _getImageMetdata();
    StorageUploadTask uploadTask = storageReference.putFile(image, metadata);
    await uploadTask.onComplete;
    _log.info('File Uploaded');
    return storageReference.getDownloadURL();
  }

  Future<dynamic> uploadImageFromUrl(String url) async {
    var response = await http.get(url).then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        throw "Unable to download image";
      }
    });

    var metadata = await _getImageMetdata();
    StorageReference storageReference = _storageReference.child(_uuid.v1());
    StorageUploadTask uploadTask = storageReference.putData(response, metadata);
    await uploadTask.onComplete;
    _log.info('File Uploaded');
    return storageReference.getDownloadURL();
  }

  static String _calculateChecksum(String ingredients) {
    var digest = sha1.convert(utf8.encode(ingredients));
    return digest.toString();
  }

  static bool _isHeading(String string) => string.startsWith('*') && string.endsWith('*');

  static bool _isComment(String string) => string.startsWith('//');

  Future<List<String>> _scaleIngredients(double scale, List<String> ingredients) async {
    _log.info("scaling ingredients");
    List<ParsedIngredient> parsedIngredients = await _spoonacularService.parseIngredients(ingredients);
    List<String> scaledIngredients = List();
    parsedIngredients.asMap().entries
      .forEach((entry) {
        var newValue = "";
        var original = entry.value.original;
        if (_isHeading(original) || _isComment(original)) {
          newValue = original;
        } else if (entry.value.id == null) {
          newValue = "{color:0xFFC62828}$original{color}";
        } else {
          _log.info(entry.value);
          newValue = "${FractionUtil.toFraction(entry.value.amount * scale)} ${entry.value.unit} ${entry.value.originalName}";
        }
        scaledIngredients.add(newValue);
    });
    return scaledIngredients;
  }

  void importRecipes(List<Recipe> recipes) {
    recipes.forEach((recipe) {
      updateRecipe(null,
        name: recipe.name,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        imageUrl: recipe.imageUrl,
        prepTime: recipe.prepTime,
        cookTime: recipe.cookTime,
        readyTime: recipe.readyTime,
        servings: recipe.servings,
        source: recipe.source,
        notes: recipe.notes,
        tags: recipe.tags,
      );
    });
  }

}
