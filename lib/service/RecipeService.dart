import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:home_cooked/model/recipe.dart';

class RecipeService {
  final CollectionReference recipes;

  RecipeService(): this.recipes = Firestore.instance.collection("recipes");

  Stream<QuerySnapshot> getRecipes(String uid, {
    String sortBy = 'name', 
    List filterBy = const [""],
    String keywords = '', 
    int maxResults = 0
    }
    ) {
    Query query = recipes.where("uid", isEqualTo: uid);
    if (keywords != '' && keywords != null) {
      query = query.where("keywords", arrayContainsAny: keywords.toLowerCase().split(" "));
    }
    else if (!listEquals(filterBy,[""]) && !listEquals(filterBy,['all']) && filterBy != null) {
      query = query.where("tags", arrayContainsAny: filterBy);
    }
    query = query.orderBy(sortBy);
    if (maxResults > 0) {
      query = query.limit(maxResults);
    }
    return query.snapshots();
  }

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
}
