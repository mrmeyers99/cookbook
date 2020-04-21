
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/model/recipe.dart';

class EditRecipeScreen extends StatefulWidget {

  final Recipe recipe;

  EditRecipeScreen(this.recipe);

  @override
  State<StatefulWidget> createState() {
    return _EditRecipeScreenState(recipe);
  }

}

class _EditRecipeScreenState extends State<EditRecipeScreen> {

  final Recipe recipe;
  final TextEditingController nameController;
  final TextEditingController ingredientsController;
  final TextEditingController instructionsController;

  _EditRecipeScreenState(this.recipe):
        this.nameController = TextEditingController(text: recipe.name),
        this.ingredientsController = TextEditingController(text: recipe.ingredients.join("\n")),
        this.instructionsController = TextEditingController(text: recipe.instructions.join("\n"));

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  List<String> _buildKeywords(String name, List<String> ingredients) {
    var wordList = name.split(" ");
    //todo since we add ingredient parsing, we should probably ignore quantities and units
    //todo ignore punctuation in words?  smores vs s'mores?
    ingredients.where((s) => !s.startsWith("//")).forEach((s) => wordList.addAll(s.split(" ")));
    var wordSet = wordList.map((s) => s.toLowerCase()).toSet();

    var subWordSet = Set<String>();
    wordSet.forEach((word) {
      for(var i = 2; i <= word.length; i++) {
        subWordSet.add(word.substring(0, i));
      }
    });
    return subWordSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return
      Scaffold(
          appBar: AppBar(
            title: Text("Edit Recipe"),
          ),
          body:
            Form(
              key: _formKey,
              child: SingleChildScrollView(child: Column(
                  children: <Widget>[
                  ListTile(title:
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: "Name"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                  )),
                  ListTile(
                    leading: Icon(Icons.fastfood),
                    title:
                      TextFormField(
                        controller: ingredientsController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(hintText: "Ingredients"),
                        maxLines: null,
                  )),
                  ListTile(
                    leading: Icon(Icons.format_list_numbered),
                    title:
                      TextFormField(
                        controller: instructionsController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(hintText: "Instructions"),
                        maxLines: null,
                  )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false
                          // otherwise.
                          if (_formKey.currentState.validate()) {
                            var db = Firestore.instance;
                            var recipeRef = db.collection("recipes").document(recipe.id);
                            db.runTransaction((transaction) {
                              return transaction.get(recipeRef).then((recipeDoc) {
                                if (!recipeDoc.exists) {
                                  throw "Recipe does not exist!";
                                }
                                transaction.update(recipeRef, {
                                  "name": nameController.text,
                                  "ingredients": ingredientsController.text.split("\n"),
                                  "instructions": instructionsController.text.split("\n"),
                                  "keywords": _buildKeywords(nameController.text, ingredientsController.text.split("\n")),
                                  "updated_at": FieldValue.serverTimestamp()
                                });
                              });
                            })
                            .then((result) {
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Text('Save'),
                      ),
                    ),
                  ]
              )
            ))
      );
  }
}
