import 'package:flutter/material.dart';

class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe(this.title, this.ingredients, this.instructions);
}

class RecipeList extends StatelessWidget {

  final recipes = List<Recipe>.generate(
    20,
        (i) {
          List<String> ingredients = List<String>.generate(5, (k) => '$k cups ingredient $k');
          List<String> instructions = List<String>.generate(5, (k) => 'Add ingredient $k into a bowl and stir to combine');
          return Recipe(
            'Recipe $i',
            ingredients,
            instructions,
          );
        },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index].title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeScreen(recipe: recipes[index]),
                )
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeScreen extends StatelessWidget {
  final Recipe recipe;

  // In the constructor, require a Todo.
  RecipeScreen({Key key, @required this.recipe}) : super(key: key);

  ListView buildListView(List<String> list) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: list.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (BuildContext ctxt, int index) =>
          Card(
            child: ListTile(title: Text(list[index]))
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return OrientationBuilder(
      builder: (context, orientation) {
        // TODO eventually change layout for portrait vs landscape
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: "Ingredients"),
                  Tab(text: "Instructions"),
                ],
              ),
              title: Text(recipe.title),
            ),
            body: TabBarView(
              children: [
                buildListView(recipe.ingredients),
                buildListView(recipe.instructions),
              ],
            ),
          ),
        );
      }
    );


//    return Scaffold(
//      appBar: AppBar(
//        title: Text(recipe.title),
//      ),
//      body: Padding(
//        padding: EdgeInsets.all(16.0),
//        child: Text(recipe.ingredients),
//      ),
//    );
  }
}
