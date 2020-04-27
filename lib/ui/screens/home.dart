import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/service/UserService.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/ui/widgets/recipe_card_thumbnail.dart';

import '../../locator.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final log = Logger('HomeScreen');

  HomeScreen({Key key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final log = Logger('_HomeScreenState');

  final UserService userService;

  Stream<QuerySnapshot> stream;
  String sortBy;

  String uid;

  _HomeScreenState(): this.userService = locator.get<UserService>();

  @override
  void initState() {
    super.initState();
    log.info("Loading home screen");
    sortBy = 'name';
    userService.getCurrentUser().then((user) {
        uid = user.uid;
        log.info("User $uid is logged in");
        setState(() {
          queryFirestore();
        });
    });
  }

  void queryFirestore() {
    stream = Firestore.instance
        .collection('recipes')
        .where("uid", isEqualTo: uid)
        .orderBy(sortBy)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    if (stream == null) {
      log.info("Recipes have not been loaded yet");
      return Container(child: Text("Loading recipes..."));
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
                  icon: Icon(Icons.loyalty), //todo: implement
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
      //print("You have cancelled the menu");
    },
    onSelected: (value) {
      setState((){
        sortBy = value;
        queryFirestore();
      });
      //print("You have chosen wisely:$value");
    },
    icon: Icon(Icons.sort),
    //offset: Offset(0,100)
  );


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
    var dbQuery = Firestore.instance
        .collection('recipes')
        .where("keywords", arrayContainsAny: query.toLowerCase().split(" "));
    if (maxResults != null) {
      dbQuery = dbQuery.limit(maxResults);
    }
    var stream = dbQuery.snapshots();

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
