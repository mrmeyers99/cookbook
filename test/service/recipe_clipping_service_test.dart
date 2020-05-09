import 'package:flutter_test/flutter_test.dart';
import 'package:home_cooked/service/spoonacular_service.dart';

void main() {
  var spoonacular = SpoonacularService();

  test('Recipe clipping service should clip recipes', () async {
    var recipe = await spoonacular.clipRecipe("https://www.bonappetit.com/recipe/bas-best-chicken-parm");
    expect(recipe.name, equals("BA's Best Chicken Parm"));
    expect(recipe.source, equals("https://www.bonappetit.com/recipe/bas-best-chicken-parm"));
    expect(recipe.servings, equals('8'));
    expect(recipe.imageUrl, equals("https://spoonacular.com/recipeImages/1443263-556x370.jpg"));
    expect(recipe.readyTime, equals(45));
  });

}
