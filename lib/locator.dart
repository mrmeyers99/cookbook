import 'package:get_it/get_it.dart';
import 'package:home_cooked/service/recipe_service.dart';
import 'package:home_cooked/service/user_service.dart';
import 'package:home_cooked/service/spoonacular_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => RecipeService());
  locator.registerLazySingleton(() => SpoonacularService());
}
