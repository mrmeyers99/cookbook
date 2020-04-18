import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/model/recipe.dart';
import 'package:test_flutter/ui/screens/individual_recipe.dart';

class HomeScreen extends StatefulWidget {
  final log = Logger('HomeScreen');

  HomeScreen({Key key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    stream = Firestore.instance.collection('recipes').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

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
                var docSnapshot = snapshot.data.documents[index];
                return getRecipeCard(Recipe.fromMap(docSnapshot.data, docSnapshot.documentID), context);
              },
              /// Set childCount to limit no.of items
              childCount: snapshot.hasData ? snapshot.data.documents.length : 0,
            ),
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
              builder: (context) => RecipeScreen(recipe.id),
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
  Widget buildResults(BuildContext context, {int maxResults}) {
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

    // todo: I think i shouldn't be creating this instance in a buildResults function for performance reaons
    var dbQuery = Firestore.instance.collection('recipes').where("keywords", arrayContainsAny: query.split(" "));
    if (maxResults != null) {
      dbQuery = dbQuery.limit(maxResults);
    }
    var stream = dbQuery.snapshots();

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
                              builder: (context) => RecipeScreen(snapshot.data.documents[index].documentID),
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
    return buildResults(context, maxResults: 6);
  }
}
