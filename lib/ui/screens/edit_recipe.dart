
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/ui/screens/individual_recipe.dart';
import 'package:logging/logging.dart';

import 'tags.dart';

class EditRecipeScreen extends StatefulWidget {

  final Recipe recipe;

  EditRecipeScreen(this.recipe);

  @override
  State<StatefulWidget> createState() {
    return _EditRecipeScreenState(recipe);
  }

}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final log = Logger('_EditRecipeScreenState');
  final Recipe recipe;
  final TextEditingController nameController;
  final TextEditingController ingredientsController;
  final TextEditingController instructionsController;
  final TextEditingController prepTimeController;
  final TextEditingController cookTimeController;
  final TextEditingController readyTimeController;
  final TextEditingController sourceController;
  final TextEditingController notesController;
  List tagsList;
  final TextEditingController tagsController;
  final RecipeService _recipeService;

  _EditRecipeScreenState(this.recipe):
        this.nameController = TextEditingController(text: recipe.name),
        this.ingredientsController = TextEditingController(text: recipe.ingredients.join("\n")),
        this.instructionsController = TextEditingController(text: recipe.instructions.join("\n")),
        this.prepTimeController = TextEditingController(text: recipe.prepTime),
        this.cookTimeController = TextEditingController(text: recipe.cookTime),
        this.readyTimeController = TextEditingController(text: recipe.readyTime),
        this.sourceController = TextEditingController(text: recipe.source),
        this.notesController = TextEditingController(text: recipe.notes),
        this.tagsList = recipe.tags,
        this.tagsController = TextEditingController(text: recipe.tags == null ? '' : recipe.tags.join("\n")),
        this._recipeService = locator.get<RecipeService>();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return
      Scaffold(
          appBar: AppBar(
            title: Text("Edit Recipe"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                // todo: make check only appear if selection has changed?
                onPressed: () {
                  saveRecipe();
                },
              ),
            ],
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
                  ListTile(
                    leading: Column(
                      children: [
                        Icon(Icons.timer),
                        Text('Prep')
                      ]
                    ),
                    title:
                      TextFormField(
                        controller: prepTimeController,
                        decoration: InputDecoration(hintText: "Prep Time"),
                  )),
                  ListTile(
                    leading: Column(
                      children: [
                        Icon(Icons.timer),
                        Text('Cook')
                      ]
                    ),
                    title:
                      TextFormField(
                        controller: cookTimeController,
                        decoration: InputDecoration(hintText: "Cook Time"),
                  )),
                  ListTile(
                    leading: Column(
                      children: [
                        Icon(Icons.timer),
                        Text('Ready')
                      ]
                    ),
                    title:
                      TextFormField(
                        controller: readyTimeController,
                        decoration: InputDecoration(hintText: "Ready Time"),
                  )),
                  ListTile(
                    leading: Icon(Icons.bookmark),
                      title:
                      TextFormField(
                        controller: sourceController,
                        decoration: InputDecoration(hintText: "Source"),
                  )),
                  ListTile(
                    leading: Icon(Icons.note),
                    title:
                      TextFormField(
                        controller: notesController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(hintText: "Notes"),
                        maxLines: null,
                  )),
                    ListTile(
                      leading: Icon(Icons.loyalty),
                      title: TextFormField(
                          controller: tagsController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(hintText: "Tags"),
                          maxLines: null,
                        ),
                      trailing: RaisedButton(
                        onPressed: () {
                          // implement
                        },
                      child: Text('Choose'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    /*child: RaisedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false
                        // otherwise.
                        saveRecipe();
                      },
                      child: Text('Save'),
                    ),*/
                  ),
                ]
              )
            ))
      );
  }




  void saveRecipe () {
    if (_formKey.currentState.validate()) {
      _recipeService.updateRecipe(recipe.id,
          name: nameController.text,
          ingredients: ingredientsController.text.split("\n"),
          instructions: instructionsController.text.split("\n"),
          imageUrl: recipe.imageUrl,
          prepTime: prepTimeController.text,
          cookTime: cookTimeController.text,
          readyTime: readyTimeController.text,
          source: sourceController.text,
          notes: notesController.text,
          tags: tagsController.text.split("\n"),
      )
      .then((result) {
        if (recipe.id == null || recipe.id == "") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RecipeScreen(result)));
        } else {
          Navigator.pop(context);
        }
      })
      .catchError((err) => log.severe("Error saving recipe", err) /*todo: display error to user*/);
    }
  }

  /*Future navigateToTagScreen(context) async {
    tagsList = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => TagScreen(tagsList),
        ));
    }*/


}
