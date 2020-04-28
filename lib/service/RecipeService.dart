import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
import 'package:home_cooked/model/recipe.dart';
=======
import 'package:logging/logging.dart';
>>>>>>> fba8b7638bcf28274154d1c11c42f0050d740063

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
<<<<<<< HEAD
    }
    else if (!listEquals(filterBy,[""]) && !listEquals(filterBy,['all']) && filterBy != null) {
=======
    } else if (filterBy != [""] && filterBy != null) {
>>>>>>> fba8b7638bcf28274154d1c11c42f0050d740063
      query = query.where("tags", arrayContainsAny: filterBy);
    }
    log.info("sorting by $sortBy, descending = $sortDesc");
    query = query.orderBy(sortBy, descending: sortDesc);
    if (maxResults > 0) {
      query = query.limit(maxResults);
    }
    return query.snapshots();
  }

<<<<<<< HEAD
  Future<List<Recipe>> getAllTags(String uid) async {
      QuerySnapshot query = await recipes.where("uid", isEqualTo: uid).getDocuments();
  
      return query.documents.map(
        (doc) => Recipe(
          //doc.data['tags']
        )
      ).toList();
    }

  /*Stream<QuerySnapshot> getAllTags(String uid) {
    Query query = recipes.where("uid", isEqualTo: uid);
    return query.snapshots();
  }*/
  
  }
  
  class RecipeTag {
=======
  Stream<DocumentSnapshot> getRecipe(String id) {
    return _recipes.document(id).snapshots();
  }

  Future<Map<String, dynamic>> updateRecipe(String id, {name: String, ingredients: String, instructions}) {
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
    });
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

>>>>>>> fba8b7638bcf28274154d1c11c42f0050d740063
}
