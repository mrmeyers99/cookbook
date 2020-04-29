
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/ui/screens/individual_recipe.dart';
import 'package:logging/logging.dart';

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
  final RecipeService _recipeService;

  _EditRecipeScreenState(this.recipe):
        this.nameController = TextEditingController(text: recipe.name),
        this.ingredientsController = TextEditingController(text: recipe.ingredients.join("\n")),
        this.instructionsController = TextEditingController(text: recipe.instructions.join("\n")),
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
                            _recipeService.updateRecipe(recipe.id,
                                name: nameController.text,
                                ingredients: ingredientsController.text.split("\n"),
                                instructions: instructionsController.text.split("\n"))
                            .then((result) {
                              if (recipe.id == "") {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RecipeScreen(result)));
                              } else {
                                Navigator.pop(context);
                              }
                            })
                            .catchError((err) => log.severe("Error saving recipe", err) /*todo: display error to user*/);
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
