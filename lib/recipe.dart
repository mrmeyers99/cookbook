import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:test_flutter/view_recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cache.dart';

//part 'recipe.g.dart';

//@JsonSerializable()
//class Recipe {
//  final String title;
//  final String imageUrl;
//  final List<String> ingredients;
//  final List<String> instructions;
//
//  Recipe(this.title, this.imageUrl, this.ingredients, this.instructions);
//
//  factory Recipe.fromJson(Map<String, dynamic> json) =>
//      _$RecipeFromJson(json);
//
//  Map<String, dynamic> toJson() => _$RecipeToJson(this);
//}

class RecipeList extends StatefulWidget {
  final log = Logger('RecipeList');

  RecipeList({Key key});

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {

  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    stream = Firestore.instance.collection('recipes').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    final cache = CustomCacheManager();

    return Scaffold(
        // https://medium.com/flutterpub/implementing-search-in-flutter-17dc5aa72018
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        title: Text("Recipes"),
        floating: true,
        pinned: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort), //todo: implement
          ),
          IconButton(
            icon: Icon(Icons.loyalty),  //todo: implement
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(),
              );
            },
          ),
        ]),
      StreamBuilder(
        stream: stream,
        builder: (context, snapshot) =>
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
                return getRecipeCard(snapshot.data.documents[index], context);
              },
              /// Set childCount to limit no.of items
              childCount: snapshot.hasData ? snapshot.data.documents.length : 0,
            ),
          ),
      ),
    ]));
  }

  Card getRecipeCard(DocumentSnapshot recipe, BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(recipe['title']),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainCollapsingToolbar(recipe),
            ));
      },
    ));
  }
}

class RecipeSearchDelegate extends SearchDelegate {

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

    var stream = Firestore.instance.collection('recipes').where("title", isEqualTo: query).snapshots();

    //todo actually return search results instead of everything
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) =>
            GridView.builder(
              itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return Card(
                    child: ListTile(
                      title: Text(snapshot.data.documents[index]['title']),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainCollapsingToolbar(snapshot.data.documents[index]),
                            ));
                      },
                    ));
              },
            ),
    );

    // https://medium.com/flutterpub/implementing-search-in-flutter-17dc5aa72018 shows an implementation we want to explore.  It returns a StreamBuilder which sounds like an infinite scrolling thing that could show the results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
    //todo actually return suggestions instead of hardcoding 4
//    return GridView.builder(
//      itemCount: 4,
//      gridDelegate:
//          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//      itemBuilder: (context, index) {
//        return Card(
//            child: ListTile(
//          title: Text(recipes[index].title),
//          onTap: () {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => MainCollapsingToolbar(recipes[index]),
//                ));
//          },
//        ));
//      },
//    );
  }
}
