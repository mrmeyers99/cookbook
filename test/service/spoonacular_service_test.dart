import 'package:flutter_test/flutter_test.dart';
import 'package:home_cooked/model/parsed_ingredient.dart';
import 'package:home_cooked/service/spoonacular_service.dart';

void main() {
  var spoonacular = SpoonacularService();

  test('Spoonacular service should clip recipes', () async {
    var recipe = await spoonacular.clipRecipe("https://www.bonappetit.com/recipe/bas-best-chicken-parm");
    expect(recipe.name, equals("BA's Best Chicken Parm"));
    expect(recipe.source, equals("https://www.bonappetit.com/recipe/bas-best-chicken-parm"));
    expect(recipe.servings, equals('8'));
    expect(recipe.imageUrl, equals("https://spoonacular.com/recipeImages/1443263-556x370.jpg"));
    expect(recipe.readyTime, equals(45));
  });

  test('Spoonacular service should parse ingredients', () async {
    var ingredients = await spoonacular.parseIngredients(["// comment", "1/2 cup flour", "4 lbs. butter, melted"]);
    expect(ingredients, containsAllInOrder([
      ParsedIngredient(null, "comment", 2.0, null, "servings", "servings", null, "// comment", "comment", null),
      ParsedIngredient(20081, "flour", 0.5, "cup", "cups", "cup", "flour.png", "1/2 cup flour", "flour", "Baking"),
      ParsedIngredient(1001, "butter", 4.0, "lbs", "pounds", "lb", "butter-sliced.jpg", "4 lbs. butter, melted", "butter, melted", "Milk, Eggs, Other Dairy"),
    ]));
  });

}
