class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final List<String> keywords;

  Recipe({this.id, this.title, this.imageUrl, this.ingredients, this.instructions, this.tags, this.keywords});

  Recipe.fromMap(Map<String, dynamic> data, String id) : this(
    id: id,
    title: data['title'],
    imageUrl: data['imageUrl'],
    ingredients: data['ingredients'] == null ? List() : List.from(data['ingredients']),
    instructions: data['instructions'] == null ? List() : List.from(data['instructions']),
    tags: new List<String>.from(data['tags']),
    keywords: new List<String>.from(data['keywords']),
  );
}
