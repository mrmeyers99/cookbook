import 'package:flutter/material.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/ui/screens/individual_recipe.dart';

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
                  title: Text(recipe.name),
                ),
                // todo cache image and make this look better and handle resizing
                recipe.imageUrl == null ? Container() : Image.network(recipe.imageUrl, height: 100),
              ])
      )
    );
  }

}
