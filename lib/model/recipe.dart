import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final List<String> keywords;

  Recipe({this.id, this.name, this.imageUrl, this.ingredients, this.instructions, this.tags, this.keywords});

  Recipe.fromMap(Map<String, dynamic> data, String id) : this(
    id: id,
    name: data['name'],
    imageUrl: data['imageUrl'],
    ingredients: _buildList(data, 'ingredients'),
    instructions: _buildList(data, 'instructions'),
    tags: _buildList(data, 'tags'),
    keywords: _buildList(data, 'keywords'),
  );

  static List<String> _buildList(map, key) => map[key] == null ? List() : List.from(map[key]);
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
        .toList();
  }
}
