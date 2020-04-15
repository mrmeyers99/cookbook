import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';

import 'cache.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe(this.title, this.imageUrl, this.ingredients, this.instructions);

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

class RecipeList extends StatelessWidget {
  final log = Logger('RecipeList');
  final recipes;

  RecipeList(this.recipes);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    final cache = CustomCacheManager();

//    log.info("Going to get a file from the cache");
//    final future = cache.getSingleFile("https://drive.google.com/uc?export=view&id=1XjlY4002dNszTBcwtuVr-lZlnLSD3scK");
//    future.then((file) {
//      log.info("got file");
//      log.info(file);
//      final contents = file.readAsStringSync();
//      var list = json.decode(contents) as List;
//      List<Recipe> newRecipes = list.map((i)=>Recipe.fromJson(i)).toList();
//      log.info("got ${newRecipes.length} recipes");
//      recipes.addAll(newRecipes);
//    });

    return Scaffold(
        // https://medium.com/flutterpub/implementing-search-in-flutter-17dc5aa72018
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        title: Text("Recipes"), 
        floating: true, 
        actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: RecipeSearchDelegate(recipes),
            );
          },
        ),
      ]),
      SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          ///no.of items in the horizontal axis
          crossAxisCount: 2,
        ),

        ///Lazy building of list
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            /// To convert this infinite list to a list with "n" no of items,
            /// uncomment the following line:
            /// if (index > n) return null;
            return getRecipeCard(recipes[index], context);
          },

          /// Set childCount to limit no.of items
          childCount: recipes.length,
        ),
      ),
    ]));
  }

  Card getRecipeCard(Recipe recipe, BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(recipe.title),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipe: recipe),
            ));
      },
    ));
  }
}

class RecipeSearchDelegate extends SearchDelegate {
  final List<Recipe> recipes;

  //todo find a better way to manage recipes
  RecipeSearchDelegate(this.recipes);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }

    //todo actually return search results instead of everything
    return GridView.builder(
      itemCount: recipes.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        return Card(
            child: ListTile(
          title: Text(recipes[index].title),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeScreen(recipe: recipes[index]),
                ));
          },
        ));
      },
    );

    // https://medium.com/flutterpub/implementing-search-in-flutter-17dc5aa72018 shows an implementation we want to explore.  It returns a StreamBuilder which sounds like an infinite scrolling thing that could show the results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //todo actually return suggestions instead of hardcoding 4
    return GridView.builder(
      itemCount: 4,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        return Card(
            child: ListTile(
          title: Text(recipes[index].title),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeScreen(recipe: recipes[index]),
                ));
          },
        ));
      },
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
          Card(child: ListTile(title: Text(list[index]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return OrientationBuilder(builder: (context, orientation) {
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
    });

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
