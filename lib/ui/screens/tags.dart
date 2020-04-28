
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/service/UserService.dart';
import '../../locator.dart';
//import 'package:ordered_set/ordered_set.dart';



class TagScreen extends StatefulWidget {

  final uid;

  TagScreen(this.uid);


  @override
  State<StatefulWidget> createState() {
    return _TagScreenState(uid);
  }

}

List<String> litems = ["1","2","Third","4","5"];
//List<String> litems2 = getAllTags().toList();


class _TagScreenState extends State<TagScreen> {

  final UserService userService;
  final RecipeService recipeService;
  final uid;

  //List<QuerySnapshot> allTags;
  //Stream<QuerySnapshot> allTags;
  Future<Set<QuerySnapshot>> allTags;

  _TagScreenState(this.uid):
    this.userService = locator.get<UserService>(),
    this.recipeService = locator.get<RecipeService>();


  void queryAllTags() async {
    print('working on getting tags');
    var allTags = await recipeService.getAllTags(uid);
    print(allTags);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Filter'),
        backgroundColor: Colors.redAccent,
      ),
      /*body: new ListView.builder(
        itemCount: litems.length,
        itemBuilder: (
          BuildContext ctxt, int index) {
            return new Text(litems[index]);
          }
        )
        */
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Click button to display all tags'),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.redAccent,
              child: Text('Get Tags'),
              onPressed: () {
                queryAllTags();
                //Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
