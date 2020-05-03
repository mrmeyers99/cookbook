import 'dart:convert';

import 'package:home_cooked/model/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;

class RecipeClippingService {

  final String apiKey = 'db878a56ae6a46739cdb8695eed51af3';
  final String apiUrl = 'https://api.spoonacular.com/recipes/extract';

  Future<Recipe> clipRecipe(String url) async {
    var response = await http.get(Uri.https('api.spoonacular.com', '/recipes/extract', {
      'url': url,
      'apiKey': apiKey,
    }));
    var res = json.jsonDecode(Utf8Codec().decode(response.bodyBytes));
    List<String> ingredients = List();
    res['extendedIngredients']
        .forEach((ingredient) => ingredients.add(ingredient['original']));

    List<String> instructions = List();
    res['analyzedInstructions'].forEach((section) {
      if (section['name'] != null) {
        instructions.add("*${section['name']}*");
      }
      section['steps'].forEach((step) => instructions.add(step['step']));
    });

    return Recipe(
        name: res['title'],
        imageUrl: res['image'],
        ingredients: ingredients,
        instructions: instructions,
        source: url,
        servings: res['servings'],
        readyTime: res['readyInMinutes'] == null ? '' : "${res['readyInMinutes']} minutes",
    );
  }
}
