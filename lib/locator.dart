import 'package:get_it/get_it.dart';
import 'package:home_cooked/service/RecipeClippingService.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => RecipeService());
  locator.registerLazySingleton(() => RecipeClippingService());
}
