
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/service/RecipeService.dart';
import 'package:home_cooked/ui/screens/individual_recipe.dart';
import 'package:home_cooked/util/string_util.dart';
import 'package:image_picker/image_picker.dart';
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
  final _log = Logger('_EditRecipeScreenState');
  final Recipe _recipe;
  final TextEditingController _nameController;
  final TextEditingController _ingredientsController;
  final TextEditingController _instructionsController;
  final TextEditingController _prepTimeController;
  final TextEditingController _cookTimeController;
  final TextEditingController _readyTimeController;
  final TextEditingController _servingsController;
  final TextEditingController _sourceController;
  final TextEditingController _notesController;
  final TextEditingController _tagsController;
  final RecipeService _recipeService;
  File _image;

  @override
  void dispose() {
    super.dispose();
    if (_nameController != null) {
      _nameController.dispose();
      _ingredientsController.dispose();
      _instructionsController.dispose();
      _prepTimeController.dispose();
      _cookTimeController.dispose();
      _readyTimeController.dispose();
      _servingsController.dispose();
      _sourceController.dispose();
      _notesController.dispose();
      _tagsController.dispose();
    }
  }

  _EditRecipeScreenState(this._recipe):
        this._nameController = TextEditingController(text: _recipe.name),
        this._ingredientsController = TextEditingController(text: _recipe.ingredients.join("\n")),
        this._instructionsController = TextEditingController(text: _recipe.instructions.join("\n")),
        this._prepTimeController = TextEditingController(text: _recipe.prepTime),
        this._cookTimeController = TextEditingController(text: _recipe.cookTime),
        this._readyTimeController = TextEditingController(text: _recipe.readyTime),
        this._sourceController = TextEditingController(text: _recipe.source),
        this._servingsController = TextEditingController(text: _recipe.servings),
        this._notesController = TextEditingController(text: _recipe.notes),
        this._tagsController = TextEditingController(text: _recipe.tags == null ? '' : _recipe.tags.join("\n")),
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
                      controller: _nameController,
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
                        controller: _ingredientsController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(hintText: "Ingredients"),
                        maxLines: null,
                  )),
                  ListTile(
                      leading: Icon(Icons.format_list_numbered),
                      title:
                      TextFormField(
                        controller: _instructionsController,
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
                        controller: _prepTimeController,
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
                        controller: _cookTimeController,
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
                        controller: _readyTimeController,
                        decoration: InputDecoration(hintText: "Ready Time"),
                  )),
                  ListTile(
                    leading: Icon(Icons.short_text),
                      title:
                      TextFormField(
                        controller: _servingsController,
                        decoration: InputDecoration(hintText: "Servings"),
                  )),
                  ListTile(
                    leading: Icon(Icons.bookmark),
                      title:
                      TextFormField(
                        controller: _sourceController,
                        decoration: InputDecoration(hintText: "Source"),
                  )),
                  ListTile(
                    leading: Icon(Icons.note),
                    title:
                      TextFormField(
                        controller: _notesController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(hintText: "Notes"),
                        maxLines: null,
                  )),
                    ListTile(
                      leading: Icon(Icons.loyalty),
                      title: TextFormField(
                          controller: _tagsController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(hintText: "Tags"),
                          maxLines: null,
                        ),
                      trailing: RaisedButton(
                        onPressed: () {
                          navigateToTagScreen(context);
                        },
                        child: Text('Choose'),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: _image != null
                          ? Image.asset(_image.path, height: 100)
                          : _recipe.imageUrl != null
                            ? Image.network(_recipe.imageUrl, height: 100)
                            : Container(height: 100),
                      trailing: RaisedButton(
                        onPressed: chooseFile,
                        child: Text('Choose'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ]
              )
            ))
      );
  }

  Future<void> chooseFile() {
    return ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future<dynamic> _uploadRecipeImage() {
    if (_image != null) {
      return _recipeService.uploadImageFromDisk(_image);
    } else if (StringUtil.isNullOrEmpty(_recipe.id) && _recipe.imageUrl != null
        || (StringUtil.notNullOrEmpty(_recipe.imageUrl) && !_recipe.imageUrl.contains("firebasestorage"))) {
      return _recipeService.uploadImageFromUrl(_recipe.imageUrl);
    } else {
      return Future.value(_recipe.imageUrl);
    }
  }

  void saveRecipe () {
    if (_formKey.currentState.validate()) {
      _uploadRecipeImage()
      .then((newUrl) {
        _log.info("Updating URL to $newUrl");
        return _recipeService.updateRecipe(_recipe.id,
          name: _nameController.text,
          ingredients: _ingredientsController.text.split("\n"),
          instructions: _instructionsController.text.split("\n"),
          imageUrl: newUrl,
          prepTime: _prepTimeController.text,
          cookTime: _cookTimeController.text,
          readyTime: _readyTimeController.text,
          servings: _servingsController.text,
          source: _sourceController.text,
          notes: _notesController.text,
          tags: _tagsController.text.split("\n"),
        );
      }
      )
      .then((result) {
        if (_recipe.id == null || _recipe.id == "") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RecipeScreen(result)));
        } else {
          Navigator.pop(context);
        }
      })
      .catchError((e, stackTrace) => _log.severe("Error saving recipe", e, stackTrace) /*todo: display error to user*/);
    }
  }

  Future navigateToTagScreen(context) async {
    var tagsListFuture = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => TagScreen(_tagsController.text.split('\n')),
        ));
    if (tagsListFuture != null) { // will be null if the back arrow was pressed on tag screen
      _tagsController.text = tagsListFuture.join('\n');
    }
  }


}
