import 'package:flutter/material.dart';
import 'package:test_flutter/recipe.dart';

void main() => runApp(MaterialApp(
    title: 'Cookbook',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: RecipeList()));
