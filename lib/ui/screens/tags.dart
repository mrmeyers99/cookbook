import 'dart:core';
import 'package:flutter/material.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
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
  final List selectedTags = [];

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
              onPressed: () {
                Navigator.pop(context, selectedTags);
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
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // implement
              },
              label: Text('All'),
              icon: Icon(Icons.check),
            ),
            SizedBox(height: 8),
            FloatingActionButton.extended(
              onPressed: () {
                // implement
              },
              label: Text('All'),
              icon: Icon(Icons.clear),
            ),
          ]
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<List<String>> getFutureTags() => recipeService.getTagList();
}
