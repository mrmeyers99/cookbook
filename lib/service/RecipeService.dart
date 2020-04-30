import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:logging/logging.dart';

class RecipeService {
  final log = Logger('RecipeService');
  final CollectionReference _recipes;
  final Firestore _db;

  RecipeService():
        this._recipes = Firestore.instance.collection("recipes"),
        this._db = Firestore.instance;

  Stream<QuerySnapshot> getRecipes(String uid, {
    String sortBy = 'name',
    bool sortDesc = false,
    List filterBy = const [""],
    String keywords = '',
    int maxResults = 0
    }
    ) {
    Query query = _recipes.where("uid", isEqualTo: uid);

    if (keywords != '' && keywords != null) {
      query = query.where("keywords", arrayContainsAny: keywords.toLowerCase().split(" "));
    } else if (!listEquals(filterBy,[""]) && !listEquals(filterBy,['all']) && filterBy != null) {
      query = query.where("tags", arrayContainsAny: filterBy);
    }
    log.info("sorting by $sortBy, descending = $sortDesc");
    query = query.orderBy(sortBy, descending: sortDesc);
    if (maxResults > 0) {
      query = query.limit(maxResults);
    }
    return query.snapshots();
  }

  Future<List<String>> getTagList(String uid) async {
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

  Future<String> updateRecipe(String id, {name: String, ingredients: String, instructions}) {
    if (id == "") {
      return FirebaseAuth.instance.currentUser().then((user) => _recipes.add({
        "name": name,
        "ingredients": ingredients,
        "instructions": instructions,
        "keywords": _buildKeywords(name, ingredients),
        "tags": List(),
        "updated_at": FieldValue.serverTimestamp(),
        'viewed_at': FieldValue.serverTimestamp(),
        'viewed_times': 1,
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
          "ingredients": ingredients,
          "instructions": instructions,
          "keywords": _buildKeywords(name, ingredients),
          "updated_at": FieldValue.serverTimestamp()
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
          "viewed_times": recipeDoc.data['viewed_times'] == null ? 1 : recipeDoc.data['viewed_times'] + 1,
          "viewed_at": FieldValue.serverTimestamp()
        });
      });
    })
    .then((value) => {})
    .catchError((err) => log.warning("Error marking recipe as viewed", err));
  }

}
