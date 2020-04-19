import 'package:flutter/material.dart';
import 'package:test_flutter/model/recipe.dart';
import 'package:test_flutter/ui/screens/individual_recipe.dart';

class RecipeThumbnail extends StatelessWidget {
  final Recipe recipe;

  RecipeThumbnail(this.recipe);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipe.id),
            ));
      },
      child: Card(
          child: Column(
              children: [
                ListTile(
                  title: Text(recipe.title),
                )
                // todo cache image and make this look better
                recipe.imageUrl == null ? Container() : Image.network(recipe.imageUrl, height: 140, fit: BoxFit.fitHeight),
              ])
      )
    );
  }

}
