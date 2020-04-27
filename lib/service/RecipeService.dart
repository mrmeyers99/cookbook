import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (filterBy != [""] && filterBy != null) {
      query = query.where("tags", arrayContainsAny: filterBy);
    }
    query = query.orderBy(sortBy);
    if (maxResults > 0) {
      query = query.limit(maxResults);
    }
    return query.snapshots();
  }
}
