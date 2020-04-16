import 'package:flutter/material.dart';

// mostly from https://medium.com/@diegoveloper/flutter-collapsing-toolbar-sliver-app-bar-14b858e87abe

class MainCollapsingToolbar extends StatefulWidget {
  final recipe;

  MainCollapsingToolbar(this.recipe);

  @override
  _MainCollapsingToolbarState createState() => _MainCollapsingToolbarState(recipe);
}

class _MainCollapsingToolbarState extends State<MainCollapsingToolbar> {

  final recipe;

  _MainCollapsingToolbarState(this.recipe);

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
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: recipe['imageUrl'] != null ? 200.0 : 20.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(recipe['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: recipe['imageUrl'] != null ? Image.network(
                      recipe['imageUrl'], //todo use cache
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
              buildListView(List.from(recipe['ingredients'])),
              buildListView(List.from(recipe['instructions'])),
            ],
          ),
        ),
      ),
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
