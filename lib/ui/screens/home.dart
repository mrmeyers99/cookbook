import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_cooked/model/user.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/service/recipe_service.dart';
import 'package:home_cooked/service/user_service.dart';
import 'package:home_cooked/service/spoonacular_service.dart';
import 'package:home_cooked/ui/screens/edit_recipe.dart';
import 'package:home_cooked/ui/widgets/input_alert_dialog.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/ui/widgets/recipe_card_thumbnail.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:simple_gravatar/simple_gravatar.dart';
import 'package:file_picker/file_picker.dart';

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
  final SpoonacularService clippingService;

  Stream<QuerySnapshot> stream;
  String sortBy;
  bool sortDesc;
  List filterBy;
  //var tagButtonColor = Colors.white;
  bool clearTagsButtonVisible;
  bool _jsonLoadingPath = false;
  String _jsonFileName;
  String _jsonFilePath;
  Map<String, String> _jsonFilePaths;

  User user;
  StreamSubscription _intentDataStreamSubscription;

  _HomeScreenState():
      this.userService = locator.get<UserService>(),
      this.recipeService = locator.get<RecipeService>(),
      this.clippingService = locator.get<SpoonacularService>();

  @override
  void initState() {
    super.initState();
    log.info("Loading home screen");
    sortBy = 'name';
    sortDesc = false;
    clearTagsButtonVisible = false;
    userService.getCurrentUser().then((user) {
        log.info("User ${user.email} is logged in");
        if (mounted) {
          setState(() {
            this.user = user;
            queryRecipes();
          });
        }
    });
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          log.info("Received $value.  Will clip this recipe");
          clippingService.clipRecipe(value).then((recipe) =>
              Navigator.push(context,  MaterialPageRoute(
                builder: (context) => EditRecipeScreen(recipe),
              ))
          );
        }, onError: (err) {
          log.severe("getLinkStream error", err);
        });

    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value != null && value.startsWith("http")) {
        log.info("Received $value.  Will clip this recipe.");
        clippingService.clipRecipe(value).then((recipe) =>
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => EditRecipeScreen(recipe),
            ))
        );
      } else {
        log.info("Received $value but do not recognize it as a URL");
      }
    });
  }

  void queryRecipes() {
    stream = recipeService.getRecipes(user.uid, sortBy: sortBy, sortDesc: sortDesc, filterBy: filterBy);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    log.info("Building home screen");

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
                    backgroundImage: _getGravatar(user.email),
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
                title: Text('Clip Recipe'),
                trailing: Icon(Icons.content_cut), //was attach_file, could use public
                onTap: () {
                  showDialog(context: context, builder: (context) =>
                    InputAlertDialog("Enter a URL to clip", "url", TextInputType.url)
                  ).then((url) async {
                    if (url != null) {
                      var recipe = await clippingService.clipRecipe(url);
                      Navigator.pushReplacement(context,  MaterialPageRoute(
                        builder: (context) => EditRecipeScreen(recipe),
                      ));
                    }
                  });
                },
              ),
              ListTile(
                title: Text('Import JSON'),
                trailing: Icon(Icons.file_download),
                onTap: () {
                  //todo: implement () => _openFileExplorer();
                },
              ),
              ListTile(
                title: Text('Logout'),
                trailing: Icon(Icons.perm_identity), //could use people, lock, perm_identity, exit_to_app
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
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                ///no.of items in the horizontal axis
                //crossAxisCount: 2,
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 0.95, // Needs to match the value on recipe_card_thumbnail.dart to make images look good.
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
        value: "viewedAt:desc",
        child: Text("Most Recently Viewed")
      ),
      PopupMenuItem(
        value: "viewedTimes:desc",
        child: Text("Most Viewed")
      ),
      PopupMenuItem(
        value: "updatedAt:desc",
        child: Text("Most Recently Updated")
      ),
      PopupMenuItem(
        value: "createdAt:desc",
        child: Text("Most Recently Added")
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
    var filterByFuture = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => TagScreen(filterBy),
        ));
    if (filterByFuture != null) { // will be null if the back arrow was pressed on tag screen
      filterBy = filterByFuture;
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

//https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#android
//https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/lib/src/file_picker_demo.dart
  void _openFileExplorer() async {
    setState(() => _jsonLoadingPath = true);
    try{
      _jsonFilePaths = null;
      _jsonFilePath = await FilePicker.getFilePath(
        type: FileType.any,
        //allowedExtensions: 
      );
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _jsonLoadingPath = false;
      _jsonFileName = _jsonFilePath != null ? _jsonFilePath.split('/').last : _jsonFilePaths != null ? _jsonFilePaths.keys.toString() : '...';
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  ImageProvider _getGravatar(String email) {
    var gravatar = Gravatar(email);
    return NetworkImage(gravatar.imageUrl(
      size: 100,
      defaultImage: GravatarImage.retro,
      rating: GravatarRating.pg,
      fileExtension: true,
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
