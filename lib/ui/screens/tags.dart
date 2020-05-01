import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
import '../../locator.dart';

class TagScreen extends StatefulWidget {
  final uid;
  final preexistingFilters;

  TagScreen(this.uid, this.preexistingFilters);

  @override
  State<StatefulWidget> createState() {
    return _TagScreenState();
  }
}

class _TagScreenState extends State<TagScreen> {
  final UserService userService;
  final RecipeService recipeService;
  List<String> preexistingFilters;
  List<String> tagList;
  var selectedIdx = [];

  _TagScreenState()
      : this.userService = locator.get<UserService>(),
        this.recipeService = locator.get<RecipeService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Choose Tags'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check), // todo: make check only appear if selection has changed
              onPressed: () {
                if (selectedIdx.length > 0) {
                  Navigator.pop(context,
                      selectedIdx.map((index) => tagList[index]).toList());
                } else {
                  Navigator.pop(context, [""]); // If none selected, don't filter.
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
                tagList = snapshot.data; // tagList variable mostly for convenience

                // initialize the chips if there were already tags selected
                // is this the only way to initialize a future? Seems a little weird.
                if (preexistingFilters != null && selectedIdx.isEmpty) {
                  for (var i = 0; i < preexistingFilters.length; i++) {
                    selectedIdx.add(tagList.indexWhere((tagName) => tagName == preexistingFilters[i]));
                  }
                  preexistingFilters = null; // avoid any additional initializations of selectedIdx
                }
                return Center(
                    child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) => FilterChip(
                    label: Text(snapshot.data[index]),
                    onSelected: (bool value) {
                      setState(() {
                        if (selectedIdx.contains(index)) {
                          selectedIdx.remove(index);
                        } else {
                          selectedIdx.add(index);
                        }
                      });
                    },
                    selected: selectedIdx.contains(index),
                    selectedColor: Colors.deepOrange,
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                  ),
                ));
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
