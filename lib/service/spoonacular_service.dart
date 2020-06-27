import 'dart:convert';

import 'package:home_cooked/model/parsed_ingredient.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/util/string_util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;

class SpoonacularService {

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
        source: url,
        servings: res['servings'] == null ? null : res['servings'].toString(),
        readyTime: res['readyInMinutes'],
    );
  }

  Future<List<ParsedIngredient>> parseIngredients(List<String> ingredients) async {
    var url = Uri.https('api.spoonacular.com', '/recipes/parseIngredients', {
      'apiKey': apiKey,
    });
    var body = {
      'ingredientList': ingredients.join("\n"),
    };
    print(ingredients.join("\n"));
    var response = await http.post(url, body: body);
    var responseString = Utf8Codec().decode(response.bodyBytes);
    print(responseString);
    var res = json.jsonDecode(responseString);
    var parsedIngredientMap = Map<String, ParsedIngredient>();
    res.forEach((ingredient) {
      var parsedIngredient = ParsedIngredient.fromMap(ingredient);
      parsedIngredientMap[parsedIngredient.original] = parsedIngredient;
    });
    return ingredients.map((ingredient) => parsedIngredientMap[ingredient]).toList();
  }
}
