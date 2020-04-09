import 'package:flutter/material.dart';

class Recipe {
  final String title;
  final String ingredients;
  final String instructions;

  Recipe(this.title, this.ingredients, this.instructions);
}

class RecipeList extends StatelessWidget {

  final recipes = List<Recipe>.generate(
    20,
        (i) => Recipe(
      'Recipe $i',
      'Ingredients for recipe $i',
      'Instructions for recipe $i',
    ),
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

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
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
                  Text(recipe.ingredients),
                  Text(recipe.instructions),
                ],
              ),
            ),
          );
        } else {
          return Container(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(recipe.ingredients)
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(recipe.instructions)
                  ],
                ),
              ]
            ),
          );
        }
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
