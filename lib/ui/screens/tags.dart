import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
import '../../locator.dart';

class TagScreen extends StatefulWidget {
  final uid;

  TagScreen(this.uid);

  @override
  State<StatefulWidget> createState() {
    return _TagScreenState();
  }
}

class _TagScreenState extends State<TagScreen> {
  final UserService userService;
  final RecipeService recipeService;
  var selectedIdx = [];
  List<String> allTags;

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
              icon: Icon(Icons.check),
              onPressed: () {
                if (selectedIdx.length > 0) {
                  Navigator.pop(context,
                      selectedIdx.map((index) => allTags[index]).toList());
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
                allTags = snapshot.data;
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

  Future<List<String>> getFutureTags() => recipeService.getAllTags(widget.uid);
}
