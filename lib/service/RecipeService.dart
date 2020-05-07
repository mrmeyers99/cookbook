import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

class RecipeService {
  final _log = Logger('RecipeService');
  final Uuid _uuid = Uuid();
  final CollectionReference _recipes;
  final Firestore _db;
  final StorageReference _storageReference;

  RecipeService():
        this._recipes = Firestore.instance.collection("recipes"),
        this._db = Firestore.instance,
        this._storageReference = FirebaseStorage.instance.ref().child("recipe_photos/");

  Stream<QuerySnapshot> getRecipes(String uid, {
    String sortBy = 'name',
    bool sortDesc = false,
    List filterBy = const [],
    String keywords = '',
    int maxResults = 0
    }
    ) {
    Query query = _recipes.where("uid", isEqualTo: uid);

    if (keywords != '' && keywords != null) {
      query = query.where("keywords", arrayContainsAny: keywords.toLowerCase().split(" "));
    } else if (!listEquals(filterBy,[]) && !listEquals(filterBy,['all']) && filterBy != null) {
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
    QuerySnapshot query = await _recipes.where("uid", isEqualTo: uid).getDocuments();
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

  Future<String> updateRecipe(String id, {name: String, ingredients: String, instructions: String, imageUrl: String, prepTime: String, cookTime: String, readyTime: String, servings: String, source: String, notes: String, tags: String}) {
    if (id == null || id == "") {
      return FirebaseAuth.instance.currentUser().then((user) => _recipes.add({
        "name": name,
        "ingredients": ingredients,
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
      })).then((ref) => ref.documentID);
    }
    var recipeRef = _recipes.document(id);
    return _db.runTransaction((transaction) {
      return transaction.get(recipeRef).then((recipeDoc) {
        if (!recipeDoc.exists) {
          throw "Recipe does not exist!";
        }
        transaction.update(recipeRef, {
          "name": name,
          "imageUrl": imageUrl,
          "ingredients": ingredients,
          "instructions": instructions,
          "prepTime": prepTime,
          "cookTime": cookTime,
          "readyTime": readyTime,
          "servings": servings,
          "source": source,
          "notes": notes,
          "tags": tags,
          "keywords": _buildKeywords(name, ingredients),
          "updatedAt": FieldValue.serverTimestamp()
        });
      });
    }).then((value) => id);
  }

  List<String> _buildKeywords(String name, List<String> ingredients) {
    var wordList = name.split(" ");
    //todo since we add ingredient parsing, we should probably ignore quantities and units
    //todo ignore punctuation in words?  smores vs s'mores?
    ingredients.where((s) => !s.startsWith("//")).forEach((s) => wordList.addAll(s.split(" ")));
    var wordSet = wordList.map((s) => s.toLowerCase()).toSet();

    var subWordSet = Set<String>();
    wordSet.forEach((word) {
      for(var i = 2; i <= word.length; i++) {
        subWordSet.add(word.substring(0, i));
      }
    });
    return subWordSet.toList();
  }

  Future<void> markViewed(String id) {
    var recipeRef = _recipes.document(id);
    return _db.runTransaction((transaction) {
      return transaction.get(recipeRef).then((recipeDoc) {
        if (!recipeDoc.exists) {
          throw "Recipe does not exist!";
        }
        transaction.update(recipeRef, {
          "viewedTimes": recipeDoc.data['viewedTimes'] == null ? 1 : recipeDoc.data['viewedTimes'] + 1,
          "viewedAt": FieldValue.serverTimestamp()
        });
      });
    })
    .then((value) => {})
    .catchError((err) => _log.warning("Error marking recipe as viewed", err));
  }


  Future<void> updateTags(String id, List newTagList) {
    var recipeRef = _recipes.document(id);
    return _db.runTransaction((transaction) {
      return transaction.get(recipeRef).then((recipeDoc) {
        if (!recipeDoc.exists) {
          throw "Recipe does not exist!";
        }
        transaction.update(recipeRef, {
          "tags": newTagList
        });
      });
    })
    .then((value) => {})
    .catchError((err) => _log.warning("Error updating recipe tags", err));
  }

  Future<StorageMetadata> _getImageMetdata() async {
    var user = await FirebaseAuth.instance.currentUser();
    return StorageMetadata(customMetadata: {
      'uid': user.uid
    });
  }

  Future<dynamic> uploadImageFromDisk(File image) async {
    var storageReference = _storageReference.child("/"+_uuid.v1());
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
}
