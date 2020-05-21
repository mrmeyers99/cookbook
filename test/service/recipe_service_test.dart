import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_cooked/model/parsed_ingredient.dart';
import 'package:home_cooked/service/recipe_service.dart';
import 'package:home_cooked/service/spoonacular_service.dart';
import 'package:mockito/mockito.dart';

class MockSpoonacularService extends Mock implements SpoonacularService {}
class MockFirestore extends Mock implements Firestore {}
class MockCollection extends Mock implements CollectionReference {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockFireStore = MockFirestore();
  final mockSpoonacular = MockSpoonacularService();
  GetIt.instance.registerLazySingleton<SpoonacularService>(() => mockSpoonacular);
  GetIt.instance.registerLazySingleton<Firestore>(() => mockFireStore);
  final recipeService = RecipeService();
  final recipes = MockCollection();

    test('Recipe service should scale recipes', () async {
    when(mockSpoonacular.parseIngredients(any))
        .thenAnswer((_) async =>
          Future.value(
              [
                  ParsedIngredient(123, "flour", 1.0, "cups", "cups", "cups", "", "", "", ""),
              ]
          )
    );

    when(mockFireStore.collection(any)).thenReturn(recipes);

    await recipeService.scaleRecipe("gx7wCQkbEFhWirKvELm5", 2.0);
  });

}
