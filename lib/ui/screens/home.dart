import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter/model/recipe.dart';
import 'package:test_flutter/ui/screens/individual_recipe.dart';
import 'package:test_flutter/ui/widgets/recipe_card_thumbnail.dart';

class HomeScreen extends StatefulWidget {
  final log = Logger('HomeScreen');
  final String uid;

  HomeScreen({Key key, String uid}): this.uid = uid;

  @override
  _HomeScreenState createState() => _HomeScreenState(uid);
}

class _HomeScreenState extends State<HomeScreen> {

  final String uid;

  Stream<QuerySnapshot> stream;

  _HomeScreenState(this.uid);

  @override
  void initState() {
    stream = Firestore.instance.collection('recipes').where("uid", isEqualTo: uid).snapshots();
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
                return RecipeThumbnail(Recipe.fromMap(docSnapshot.data, docSnapshot.documentID));
              },
              /// Set childCount to limit no.of items
              childCount: snapshot.hasData ? snapshot.data.documents.length : 0,
            ),
          ),
      ),
    ]));
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
    if (query.length < 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than one letter.",
            ),
          )
        ],
      );
    }

    // todo: I think i shouldn't be creating this instance in a buildResults function for performance reasons
    var dbQuery = Firestore.instance.collection('recipes').where("keywords", arrayContainsAny: query.toLowerCase().split(" "));
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
                return RecipeThumbnail(Recipe.fromMap(snapshot.data.documents[index].data, snapshot.data.documents[index].documentID));
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
