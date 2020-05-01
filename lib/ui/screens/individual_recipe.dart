import 'package:flutter/material.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:logging/logging.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:wakelock/wakelock.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'edit_recipe.dart';

// mostly from https://medium.com/@diegoveloper/flutter-collapsing-toolbar-sliver-app-bar-14b858e87abe

class RecipeScreen extends StatefulWidget {

  final log = Logger('RecipeScreen');
  final recipeId;

  RecipeScreen(this.recipeId);

  @override
  _RecipeScreenState createState() {
    log.info("creating state for recipe $recipeId");
    return _RecipeScreenState(recipeId);
  }
}

class _RecipeScreenState extends State<RecipeScreen> with RouteAware {

  final String recipeId;
  final RecipeService _recipeService;

  var stream;

  _RecipeScreenState(this.recipeId) : this._recipeService = locator.get<RecipeService>();

  @override
  void initState() {
    super.initState();
    stream = _recipeService.getRecipe(recipeId);
    _recipeService.markViewed(recipeId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    Wakelock.enable();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    Wakelock.disable();
    super.dispose();
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    Wakelock.enable();
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    Wakelock.enable();
  }

  ListView buildListView(List<Section> sections) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: sections.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (BuildContext ctxt, int index) {
        var children = List<Widget>();
        if (sections[index].title != null) {
          //todo: figure out how to make there be less space between the section header
          children.add(ListTile(title: Text(sections[index].title, style: TextStyle(fontWeight: FontWeight.bold)), contentPadding: EdgeInsets.only(top: 0, left: 16, bottom: 0),));
          children.add(Divider(color: Colors.black12, height: 12));
        }
        children.add(ListTile(title: Text(sections[index].list.join("\n")), contentPadding: EdgeInsets.only(left: 16, bottom: 16, right: 16, top: 8),));
//        children.addAll(sections[index].list.map((i) => ListTile(title: Text(i), dense: true)));
        return Card(child: Column(
          children: children,
        ));
      }

    );
  }

  Widget buildOverview(Recipe recipe) {
    return Card(child: ListView(
      children: [
        recipe.imageUrl != null ? Image.network(
          recipe.imageUrl, //todo use cache
          fit: BoxFit.cover,
        ) : Container(),
        Divider(),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(children: [
              Text("Prep Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(recipe.prepTime == null ? '' : recipe.prepTime),
            ]),
            Column(children: [
              Text("Cook Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(recipe.cookTime == null ? '' : recipe.cookTime)
            ]),
            Column(children: [
              Text("Ready Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(recipe.readyTime == null ? '' : recipe.readyTime)
            ]),
          ]
        ),
        Divider(),
        recipe.source == null ? Container() : ListTile(
          title: Text("Source"),
          subtitle: getSourceText(recipe.source),
        ),
        recipe.notes == null ? Container() : ListTile(
          title: Text("Notes"),
          subtitle: Text(recipe.notes == null ? '' : recipe.notes),
        ),
      ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data.data == null) {
          return Container();
        }

        var recipe = Recipe.fromMap(snapshot.data.data, recipeId);

        return Scaffold(
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    actions: <Widget>[
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditRecipeScreen(recipe),
                            ));
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext alertContext) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: new Text("Are you sure?"),
                              content: new Text("Are you sure you want to delete recipe ${recipe.name}?"),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: new Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(alertContext).pop(false);
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("Delete"),
                                  onPressed: () {
                                    Navigator.of(alertContext).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((shouldDelete) {
                          if (shouldDelete) {
                            _recipeService.deleteRecipe(recipe.id);
                            Navigator.pop(context);
                          }
                        });
                      }),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(recipe.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            )),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(icon: Icon(Icons.fastfood), text: "Overview"),
                          Tab(icon: Icon(Icons.fastfood), text: "Ingredients"),
                          Tab(icon: Icon(Icons.format_list_numbered), text: "Instructions"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  buildOverview(recipe),
                  buildListView(Section.fromMarkup(recipe.ingredients)),
                  buildListView(Section.fromMarkup(recipe.instructions)),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget getSourceText(String source) {
    if (source == null) {
      return Text('');
    } else if (source.startsWith("http")) {
      return InkWell(child: Text(source), onTap: () => launch(source));
    } else {
      return Text(source);
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
