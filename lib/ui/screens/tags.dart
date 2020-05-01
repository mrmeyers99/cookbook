import 'dart:core';
import 'package:flutter/material.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
import '../../locator.dart';

class TagScreen extends StatefulWidget {
  final uid;
  final List<String> preexistingFilters;

  TagScreen(this.uid, this.preexistingFilters);

  @override
  State<StatefulWidget> createState() {
    return _TagScreenState();
  }
}

class _TagScreenState extends State<TagScreen> {
  final UserService userService;
  final RecipeService recipeService;
  final List<String> selectedTags = [];

  _TagScreenState()
      : this.userService = locator.get<UserService>(),
        this.recipeService = locator.get<RecipeService>();

  @override
  void initState() {
    super.initState();
    if (widget.preexistingFilters != null) {
      widget.preexistingFilters.forEach(selectedTags.add);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Choose Tags'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              // todo: make check only appear if selection has changed
              onPressed: () {
                if (selectedTags.length > 0) {
                  Navigator.pop(context, selectedTags);
                } else {
                  Navigator.pop(
                      context, [""]); // If none selected, don't filter.
                }
              },
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: FutureBuilder(
            future: getFutureTags(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Center(
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          var tag = snapshot.data[index];
                          return FilterChip(
                            label: Text(tag),
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
                          );
                        }));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ));
  }

  Future<List<String>> getFutureTags() => recipeService.getTagList(widget.uid);
}
