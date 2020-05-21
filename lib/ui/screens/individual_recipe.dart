import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/service/recipe_service.dart';
import 'package:home_cooked/ui/widgets/confirm_dialog.dart';
import 'package:home_cooked/ui/widgets/input_alert_dialog.dart';
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

enum BulletType {
  bullets,
  numbers,
}

enum RecipeMenuEntry {
  Edit, Delete, Scale
}

class _RecipeScreenState extends State<RecipeScreen> with RouteAware {

  final String recipeId;
  final RecipeService _recipeService;
  final _httpRegex = RegExp(r"https?://([^/]+).*");
  final _colorRegex = RegExp(r"(.*){color:([A-Za-z0-9]+)}(.*){color}(.*)");

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

  ListView buildListView(List<Section> sections, BulletType bulletType) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: sections.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (BuildContext ctxt, int index) {
        var children = List<Widget>();
        if (sections[index].title != null) {
          children.add(
              Container(
                  padding: EdgeInsets.only(top: 8, left: 16, bottom: 0),
                  child: Row(
                      children: [
                        Expanded(child:
                            Text(sections[index].title,
                                style: TextStyle(fontWeight: FontWeight.bold)))
                      ]
                  )
              )
          );
          children.add(Divider(color: Colors.black12, height: 12));
        }
        children.addAll(sections[index].list.asMap().map<int, Widget>((i, line) => MapEntry(i, Container(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0, top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bulletType == BulletType.numbers ? "${i + 1}. " : "\u2022   "),
                Expanded(child: _buildItemText(ctxt, line)),
          ])))).values.toList());
        return Card(child: Column(children: children));
      }
    );
  }

  Widget _buildItemText(BuildContext context, String string) {
    var match = _colorRegex.firstMatch(string);
    if (match == null) {
      return Text(string);
    } else {
      this.widget.log.info('1: ${match.group(1)},2: ${match.group(2)},3: ${match.group(3)},4: ${match.group(4)}');
      return RichText(
          text: TextSpan(
            text: match.group(1),
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: match.group(3), style: TextStyle(color: Color(int.parse(match.group(2))))),
              TextSpan(text: match.group(4)),
            ],
          ));
//      return RichText(
//        text: TextSpan(
//          text: 'Hello ',
//          style: DefaultTextStyle.of(context).style,
//          children: <TextSpan>[
//            TextSpan(text: 'bold', style: TextStyle(fontWeight: FontWeight.bold)),
//            TextSpan(text: ' world!'),
//          ],
//        ),
//      );
    }
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
              Text(recipe.prepTime == null ? '' : "${recipe.prepTime} minutes"),
            ]),
            Column(children: [
              Text("Cook Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(recipe.cookTime == null ? '' : "${recipe.cookTime} minutes")
            ]),
            Column(children: [
              Text("Ready Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(recipe.readyTime == null ? '' : "${recipe.readyTime} minutes")
            ]),
          ]
        ),
        Divider(),
        recipe.source == null ? Container() : ListTile(
          title: Text("Source"),
          subtitle: getSourceText(recipe.source),
        ),
        Divider(),
        recipe.servings == null ? Container() : ListTile(
          title: Text("Servings"),
          subtitle: Text(recipe.servings),
        ),
        Divider(),
        recipe.notes == null ? Container() : ListTile(
          title: Text("Notes"),
          subtitle: Text(recipe.notes == null ? '' : recipe.notes),
        ),
      ],
      )
    );
  }

  void _onEditPressed(Recipe recipe) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRecipeScreen(recipe),
        ));
  }

  void _onDeletePressed(Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext alertContext) {
        return ConfirmDialog("Are you sure you want to delete recipe ${recipe.name}?", "Delete");
      },
    ).then((shouldDelete) {
      if (shouldDelete) {
        _recipeService.deleteRecipe(recipe.id);
        Navigator.pop(context);
      }
    });
  }

  void _onScalePressed(Recipe recipe) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InputAlertDialog("Enter scale factor", "1.0", TextInputType.number);
        }
    ).then((scaleFactor) {
      if (scaleFactor != null) {
        this.widget.log.info('Scaling recipe ${recipe.id} to $scaleFactor');
        _recipeService.scaleRecipe(recipe.id, double.parse(scaleFactor));
      }
    });
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

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(recipe.name),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: (result) {
                    switch (result) {
                      case RecipeMenuEntry.Edit:
                        _onEditPressed(recipe);
                        break;
                      case RecipeMenuEntry.Delete:
                        _onDeletePressed(recipe);
                        break;
                      case RecipeMenuEntry.Scale:
                        _onScalePressed(recipe);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<RecipeMenuEntry>>[
                    PopupMenuItem<RecipeMenuEntry>(
                      value: RecipeMenuEntry.Scale,
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.compare_arrows, color: Colors.black54),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Text('Scale'),
                          ]
                      ),
                    ),
                    PopupMenuItem<RecipeMenuEntry>(
                      value: RecipeMenuEntry.Edit,
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.edit, color: Colors.black54),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Text('Edit'),
                          ]
                      ),
                    ),
                    PopupMenuItem<RecipeMenuEntry>(
                      value: RecipeMenuEntry.Delete,
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.delete, color: Colors.black54),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Text('Delete'),
                          ]
                      ),
                    ),
                  ],
                )
              ],
              bottom: TabBar(
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.local_see), text: "Overview"),
                  Tab(icon: Icon(Icons.fastfood), text: "Ingredients"),
                  Tab(icon: Icon(Icons.format_list_numbered), text: "Instructions"),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                buildOverview(recipe),
                buildListView(addScaledInfo(recipe), BulletType.bullets),
                buildListView(Section.fromMarkup(recipe.instructions), BulletType.numbers),
              ],
            ),
//            child: NestedScrollView(
//              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//                return <Widget>[
//                  SliverAppBar(
//                    floating: false,
//                    pinned: true,
//                    actions: <Widget>[
//                      IconButton(icon: Icon(Icons.edit), onPressed: () {
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                              builder: (context) => EditRecipeScreen(recipe),
//                            ));
//                      }),
//                      IconButton(icon: Icon(Icons.delete), onPressed: () {

//                      }),
//                    ],
//                    flexibleSpace: FlexibleSpaceBar(
//                        centerTitle: true,
//                        title: Text(recipe.name,
//                            style: TextStyle(
//                              color: Colors.white,
//                              fontSize: 16.0,
//                            )),
//                    ),
//                  ),
//                  SliverPersistentHeader(
//                    delegate: _SliverAppBarDelegate(
//
//                    ),
//                    pinned: true,
//                  ),
//                ];
//              },
//              body: TabBarView(
//                children: [
//                ],
//              ),
//            ),
          ),
//          endDrawer: Drawer(
//            child: Container(
//              child: ListView(
//                padding: EdgeInsets.all(10.0),
//                children: [
//                  ListTile(title: Text("hi")),
//                ]
//              ),
//            ),
//          ),
        );
      }
    );
  }

  Widget getSourceText(String source) {
    if (source == null) {
      return Text('');
    } else if (source.startsWith("http")) {
      return InkWell(child: Text(extractHost(source)), onTap: () => launch(source));
    } else {
      return Text(source);
    }
  }

  String extractHost(String source) {
    return _httpRegex.firstMatch(source).group(1);
  }

  List<Section> addScaledInfo(Recipe recipe) {
    if (recipe.scale != 1.0 && recipe.scaledIngredients.length > 0) {
      var sections = List<Section>();
      sections.add(Section("Scale", ["Scaled to ${recipe.scale}X.  Ingredients in {color:0xFFC62828}red{color} could not be scaled."]));
      sections.addAll(Section.fromMarkup(recipe.scaledIngredients));
      return sections;
    } else {
      return Section.fromMarkup(recipe.ingredients);
    }
  }
}
