import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/model/user.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
import 'package:home_cooked/ui/screens/edit_recipe.dart';
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
  bool sortDesc;
  List filterBy;
  //var tagButtonColor = Colors.white;
  bool clearTagsButtonVisible;

  User user;

  _HomeScreenState():
      this.userService = locator.get<UserService>(),
      this.recipeService = locator.get<RecipeService>();

  @override
  void initState() {
    super.initState();
    log.info("Loading home screen");
    sortBy = 'name';
    sortDesc = false;
    clearTagsButtonVisible = false;
    userService.getCurrentUser().then((user) {
        log.info("User ${user.email} is logged in");
        setState(() {
          this.user = user;
          queryRecipes();
        });
    });
  }

  void queryRecipes() {
    stream = recipeService.getRecipes(user.uid, sortBy: sortBy, sortDesc: sortDesc, filterBy: filterBy); //todo: implement this again: filterBy: filterBy
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    if (stream == null) {
      log.info("Recipes have not been loaded yet");
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                  accountName: Text(user.fullName),
                  accountEmail: Text(user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                    child: Text(
                      user.initials,
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
              ),
              ListTile(
                title: Text('New Recipe'),
                trailing: Icon(Icons.add_circle_outline),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => EditRecipeScreen(Recipe.blank()),
                  ));
                },
              ),
              ListTile(
                title: Text('Logout'),
                trailing: Icon(Icons.exit_to_app),
                onTap: () {
                  userService.signOut().then((result) =>
                      Navigator.pushReplacementNamed(context, LoginViewRoute));
                },
              ),
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
                  color: Colors.white,//tagButtonColor,
                  onPressed: () {
                    navigateToTagScreen(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: RecipeSearchDelegate(user.uid),
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
        ],
        ),
        floatingActionButton: new Visibility(
          visible: clearTagsButtonVisible,
          child: new FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                filterBy = [];
                clearTagsButtonVisible = false;
                queryRecipes();
              });
            },
            label: Row(
            children: <Widget>[Text('Clear '),Icon(Icons.loyalty)],
            )
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

    Widget _sortPopup() => PopupMenuButton<String>(
    //https://medium.com/flutteropen/widgets-14-popupmenubutton-1f1437bbdce2
    itemBuilder: (context) => [
      PopupMenuItem(
        value: "name:asc",
        child: Text("Name")
      ),
      PopupMenuItem(
        value: "viewed_at:desc",
        child: Text("Last Viewed")
      ),
      PopupMenuItem(
        value: "viewed_times:desc",
        child: Text("Most Viewed")
      ),
      PopupMenuItem(
        value: "updated_at:desc",
        child: Text("Last Updated")
      ),
    ],
    initialValue: 'name:asc',
    onSelected: (value) {
      setState((){
        var parts = value.split(":");
        sortBy = parts[0];
        sortDesc = parts[1] == 'desc';
        queryRecipes();
      });
    },
    icon: Icon(Icons.sort),
    //offset: Offset(0,100)
  );



  Future navigateToTagScreen(context) async {
    filterBy = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => TagScreen(user.uid, filterBy),
        ));
    if (filterBy != null) { // will be null if the back arrow was pressed on tag screen
      setState(() {
        queryRecipes();
        if (listEquals(filterBy,[])) {
          //tagButtonColor = Colors.white;
          clearTagsButtonVisible = false;
        } else {
          //tagButtonColor = Colors.orangeAccent;
          clearTagsButtonVisible = true;
        }
      });
    }
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
