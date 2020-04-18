import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:test_flutter/model/recipe.dart';

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

class _RecipeScreenState extends State<RecipeScreen> {

  final recipeId;
  var stream;

  _RecipeScreenState(this.recipeId);

  @override
  void initState() {
    stream = Firestore.instance.collection("recipes").document(recipeId);
  }

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
                  buildListView(recipe.ingredients),
                  buildListView(recipe.instructions),
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
