import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:test_flutter/model/recipe.dart';
import 'package:wakelock/wakelock.dart';

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

  final recipeId;
  var stream;

  _RecipeScreenState(this.recipeId);

  @override
  void initState() {
    stream = Firestore.instance.collection("recipes").document(recipeId);
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

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: stream.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        var recipe = Recipe.fromMap(snapshot.data.data, recipeId);

        return Scaffold(
          body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: recipe.imageUrl != null ? 200.0 : 20.0,
                    floating: false,
                    pinned: true,
                    actions: <Widget>[
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditRecipeScreen(recipe),
                            ));
                      })],
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(recipe.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            )),
                        background: recipe.imageUrl != null ? Image.network(
                          recipe.imageUrl, //todo use cache
                          fit: BoxFit.cover,
                        ) : null
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
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
