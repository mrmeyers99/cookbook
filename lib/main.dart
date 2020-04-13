import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:test_flutter/recipe.dart';

import 'cache.dart';


Future<void> main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final log = Logger('Main');
  WidgetsFlutterBinding.ensureInitialized();

  final cache = CustomCacheManager();


  log.info("Going to get recipes from online");
  final file = await cache.getSingleFile("https://drive.google.com/uc?export=view&id=1XjlY4002dNszTBcwtuVr-lZlnLSD3scK");
  final contents = file.readAsStringSync();
  var list = json.decode(contents) as List;
  List<Recipe> recipes = list.map((i)=>Recipe.fromJson(i)).toList();

  runApp(MaterialApp(
      title: 'Cookbook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeList(recipes)));
}
