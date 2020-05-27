import 'dart:convert';

import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final List<String> keywords;

  final double scale;
  final List<String> scaledIngredients;

  final int prepTime;
  final int cookTime;
  final int readyTime;
  final String servings;
  final String source;
  final String notes;

  Recipe({this.id, this.name, this.imageUrl, this.ingredients, this.instructions, this.tags, this.keywords, this.scale, this.scaledIngredients, this.prepTime, this.cookTime, this.readyTime, this.servings, this.source, this.notes});

  Recipe.blank() : this(id: "", ingredients: List(), instructions: List());

  Recipe.fromMap(Map<String, dynamic> data, String id) : this(
    id: id,
    name: data['name'],
    imageUrl: data['imageUrl'],
    ingredients: _buildList(data, 'ingredients'),
    instructions: _buildList(data, 'instructions'),
    tags: _buildList(data, 'tags'),
    keywords: _buildList(data, 'keywords'),
    scale: data['scale'] == null ? 1 : data['scale'],
    scaledIngredients: data['scaledIngredients'] == null ? _buildList(data, 'igredients') : _buildList(data, 'scaledIngredients'),
    prepTime: data['prepTime'],
    cookTime: data['cookTime'],
    readyTime: data['readyTime'],
    servings: data['servings'],
    source: data['source'],
    notes: data['notes'],
  );

  static List<Recipe> fromJsonList(String jsonContent) {
    final parsed = json.decode(jsonContent).cast<Map<String, dynamic>>();
    return parsed.map<Recipe>((json) => Recipe.fromMap(json, null)).toList();
  }

  static List<String> _buildList(map, key) => map[key] == null ? List() : List.from(map[key]);

  @override
  String toString() {
    return 'Recipe{id: $id, name: $name, imageUrl: $imageUrl, ingredients: $ingredients, instructions: $instructions, tags: $tags, keywords: $keywords, scale: $scale, scaledIngredients: $scaledIngredients, prepTime: $prepTime, cookTime: $cookTime, readyTime: $readyTime, servings: $servings, source: $source, notes: $notes}';
  }


}

class Section {
  final String title;
  final List<String> list;

  Section(this.title, this.list);


  @override
  int get hashCode => title.hashCode + list.hashCode;

  @override
  bool operator ==(o) =>
      o is Section
        && this.title == o.title
        && listEquals(this.list, o.list);

  static List<Section> fromMarkup(List<String> list) {
    if (list == null || list.length == 0) {
      return List();
    }
    var sections = List<Section>();
    _parseList(list, sections, 0);
    return sections;

  }

  static void _parseList(List<String> list, List<Section> sections, int startFrom) {
    var firstHeading = list.indexWhere(_isHeading, startFrom);
    var nextHeading = list.indexWhere(_isHeading, firstHeading + 1);
    if (firstHeading == -1) {
      sections.add(Section(null, _sublistFilterComments(list, startFrom)));
    } else {
      if (firstHeading > startFrom) {
        sections.add(Section(null, _sublistFilterComments(list, startFrom, firstHeading)));
      }
      var title = list.elementAt(firstHeading);
      var lastElement = nextHeading == -1 ? list.length : nextHeading;
      var items = _sublistFilterComments(list, firstHeading + 1, lastElement);

      sections.add(Section(title.substring(1, title.length - 1), items));
      if (nextHeading >= 0) {
        _parseList(list, sections, nextHeading);
      }
    }
  }

  static bool _isHeading(String string) => string.startsWith("*") && string.endsWith("*");

  static List<String> _sublistFilterComments(List<String> list, int begin, [int end]) {
    return list
        .sublist(begin, end)
        .where((s) => !s.startsWith("//"))
        .skipWhile((s) => s.isEmpty)
        .toList()
        .reversed.skipWhile((s) => s.isEmpty).toList()
        .reversed.toList();
  }
}
