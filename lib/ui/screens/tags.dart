import 'dart:core';
import 'package:flutter/material.dart';
import 'package:home_cooked/service/recipe_service.dart';
import 'package:home_cooked/service/user_service.dart';
import '../../locator.dart';

class TagScreen extends StatefulWidget {
  final List preexistingFilters;

  TagScreen(this.preexistingFilters);

  @override
  State<StatefulWidget> createState() {
    return _TagScreenState();
  }
}

class _TagScreenState extends State<TagScreen> {
  final UserService userService;
  final RecipeService recipeService;
  final Set<String> selectedTags = Set();
  Future<List<String>> tagListFuture;

  _TagScreenState()
      : this.userService = locator.get<UserService>(),
        this.recipeService = locator.get<RecipeService>();

  @override
  void initState() {
    super.initState();
    tagListFuture = recipeService.getTagList();
    if (widget.preexistingFilters != null) {
      widget.preexistingFilters.forEach((tag) => selectedTags.add(tag));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: tagListFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var body = snapshot.hasData
              ? Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 15),
                    Wrap(
                      alignment: WrapAlignment.center,
                      //runSpacing: 0,
                      children: snapshot.data.map((tag) => Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: FilterChip(
                          avatar: selectedTags.contains(tag) ? CircleAvatar(backgroundColor: Colors.black) : CircleAvatar(backgroundColor: Colors.white),
                          label: Text(tag == '' ? 'Untagged' : tag),
                          onSelected: (bool value) {
                            setState(() {
                              if (selectedTags.contains(tag)) {
                                selectedTags.remove(tag);
                              } else {
                                selectedTags.add(tag);
                              }
                            });
                          },
                          selected: selectedTags.contains(tag),
                          selectedColor: Colors.deepOrange,
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.green,
                        )
                      )
                      ).toList().cast<Widget>(),
                    )
                  ]
                )
              )
              : Center(child: CircularProgressIndicator());
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title: Text('Choose Tags'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      Navigator.pop(context, selectedTags.toList());
                    },
                  ),
                ],
              ),
            body: body,
              floatingActionButton: Visibility(
                visible: snapshot.hasData,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'fabSelectAllTags',
                        onPressed: () {
                          setState(() {
                            selectedTags.addAll(snapshot.data);
                          });
                        },
                        label: Text('All'),
                        icon: Icon(Icons.check),
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton.extended(
                        heroTag: 'fabSelectNoneTags',
                        onPressed: () {
                          setState(() {
                            selectedTags.clear();
                          });},
                        label: Text('All'),
                        icon: Icon(Icons.clear),
                      ),
                    ]
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
          );
        }
    );
  }
}
