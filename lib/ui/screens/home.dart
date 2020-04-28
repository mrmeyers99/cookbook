import 'package:flutter/material.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/ui/widgets/recipe_card_thumbnail.dart';

import '../../locator.dart';
import 'tags.dart';

class HomeScreen extends StatefulWidget {
  final log = Logger('HomeScreen');

  HomeScreen({Key key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final log = Logger('_HomeScreenState');

  final UserService userService;
  final RecipeService recipeService;

  Stream<QuerySnapshot> stream;
  String sortBy;
  List filterBy;

  String uid;

  _HomeScreenState():
      this.userService = locator.get<UserService>(),
      this.recipeService = locator.get<RecipeService>();

  @override
  void initState() {
    super.initState();
    log.info("Loading home screen");
    sortBy = 'name';
    userService.getCurrentUser().then((user) {
        uid = user.uid;
        log.info("User $uid is logged in");
        setState(() {
          queryRecipes();
        });
    });
  }

  void queryRecipes() {
    stream = recipeService.getRecipes(uid, sortBy: sortBy, filterBy: filterBy);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    if (stream == null) {
      log.info("Recipes have not been loaded yet");
      return Scaffold(
        body: Center(
          child: Container(
            child: Text("Loading recipes..."),
          ),
        ),
      );
    }

    return Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Menu'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  userService.signOut().then((result) =>
                      Navigator.pushReplacementNamed(context, LoginViewRoute));
                },
              )
            ],
          ),
        ),
        // https://medium.com/flutterpub/implementing-search-in-flutter-17dc5aa72018
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
              title: Text("Recipes"),
              floating: true,
              pinned: true,
              actions: <Widget>[
                _sortPopup(),
                IconButton(
                  icon: Icon(Icons.loyalty),
                  onPressed: () {
                    //setState((){
                    //  filterBy = ['all']; //todo:change to be dynamic
                    //  queryRecipes();
                    //});
                    navigateToTagScreen(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: RecipeSearchDelegate(uid),
                    );
                  },
                ),
              ]),
          StreamBuilder(
            stream: stream,
            builder: (context, snapshot) => SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                ///no.of items in the horizontal axis
                crossAxisCount: 2,
              ),

              ///Lazy building of list
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  var docSnapshot = snapshot.data.documents[index];
                  return RecipeThumbnail(
                      Recipe.fromMap(docSnapshot.data, docSnapshot.documentID));
                },

                /// Set childCount to limit no.of items
                childCount:
                    snapshot.hasData ? snapshot.data.documents.length : 0,
              ),
            ),
          ),
        ]));
  }

    Widget _sortPopup() => PopupMenuButton<String>(
    //https://medium.com/flutteropen/widgets-14-popupmenubutton-1f1437bbdce2
    itemBuilder: (context) => [
      PopupMenuItem(
        value: "name",
        child: Text("Name")
      ),
      PopupMenuItem(
        value: "updated_at",
        child: Text("Last Updated")
      ),
    ],
    initialValue: 'name',
    onCanceled: () {
      sortBy = sortBy;
    },
    onSelected: (value) {
      setState((){
        sortBy = value;
        queryRecipes();
      });
    },
    icon: Icon(Icons.sort),
    //offset: Offset(0,100)
  );



  Future navigateToTagScreen(context) async {
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => TagScreen(uid),
        ));
}


}

class RecipeSearchDelegate extends SearchDelegate {
  final RecipeService recipeService;
  final String uid;

  RecipeSearchDelegate(this.uid): this.recipeService = locator.get<RecipeService>();

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

    var stream = recipeService.getRecipes(uid, keywords: query, maxResults: maxResults);

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) => GridView.builder(
        itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          return RecipeThumbnail(Recipe.fromMap(
              snapshot.data.documents[index].data,
              snapshot.data.documents[index].documentID));
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
