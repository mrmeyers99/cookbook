import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final CollectionReference _recipes;
  final Firestore _db;

  RecipeService():
        this._recipes = Firestore.instance.collection("recipes"),
        this._db = Firestore.instance;

  Stream<QuerySnapshot> getRecipes(String uid, {
    String sortBy = 'name',
    List filterBy = const [""],
    String keywords = '',
    int maxResults = 0
    }
    ) {
    Query query = _recipes.where("uid", isEqualTo: uid);
    if (keywords != '' && keywords != null) {
      query = query.where("keywords", arrayContainsAny: keywords.toLowerCase().split(" "));
    }
    if (filterBy != [""] && filterBy != null) {
      query = query.where("tags", arrayContainsAny: filterBy);
    }
    query = query.orderBy(sortBy);
    if (maxResults > 0) {
      query = query.limit(maxResults);
    }
    return query.snapshots();
  }

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

}
