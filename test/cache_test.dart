// Import the test package and Counter class
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/cache.dart';
import 'package:test_flutter/recipe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('Counter value should be incremented', () async {

    List<String> ingredients = List<String>.generate(
        5, (k) => '$k cups ingredient $k');
    List<String> instructions = List<String>.generate(
        5, (k) => 'Add ingredient $k into a bowl and stir to combine');
    final recipe = Recipe(
      'Recipe 0',
      null,
      ingredients,
      instructions,
    );
    print(jsonEncode(recipe));
//    final cache = CustomCacheManager();
//    final file = await cache.getFileFromCache("https://www.google-analytics.com/analytics.js");
//    var contents = file.file.readAsStringSync();
//    expect(contents, contains("hello"));
//    expect(counter.value, 1);
  });
}
