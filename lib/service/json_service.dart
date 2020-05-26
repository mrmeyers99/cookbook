import 'dart:convert' as json;
import 'package:home_cooked/model/recipe.dart';

class JsonService {

  final String apiKey = 'db878a56ae6a46739cdb8695eed51af3';
  final String apiUrl = 'https://api.spoonacular.com/recipes/extract';

  Future<Recipe> importJson(String jsonIn) async {
    var res = json.jsonDecode(jsonIn);
    List<String> ingredients = List();
    res['extendedIngredients']
        .forEach((ingredient) => ingredients.add(ingredient['original']));

    List<String> instructions = List();
    res['analyzedInstructions'].forEach((section) {
      if (section['name'] != null && section['name'] != '') {
        instructions.add("*${section['name']}*");
      }
      section['steps'].forEach((step) => instructions.add(step['step']));
    });

    return Recipe(
        name: res['title'],
        imageUrl: res['image'],
        ingredients: ingredients,
        instructions: instructions,
        source: 'url',
        servings: res['servings'] == null ? null : res['servings'].toString(),
        readyTime: res['readyInMinutes'],
    );
  }
}
