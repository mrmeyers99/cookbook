import 'package:flutter/material.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/ui/screens/individual_recipe.dart';
import 'package:logging/logging.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/service/RecipeService.dart';

class RecipeThumbnail extends StatelessWidget {
  final Recipe recipe;

  RecipeThumbnail(this.recipe);
  final log = Logger('_RecipeThumbnail');
  final RecipeService _recipeService = locator.get<RecipeService>();

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipe.id),
            ));
      },
      onLongPress: () {
        if (recipe.tags.contains('queue')) {
          recipe.tags.remove('queue');
        } else {
          recipe.tags.add('queue');
        }
        _recipeService.updateTags(recipe.id, recipe.tags);
      },
      child: Card(
        child: Container(
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(
              color: recipe.tags.contains('queue') == true ? Colors.blueAccent : Colors.white,
              width: 5,
            )
          ),
          alignment: Alignment.center,
          child: Column(
              children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child:Text(
                        recipe.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 15.0
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // todo cache image and make this look better and handle resizing
                recipe.imageUrl == null ? Container() : Image.network(recipe.imageUrl, height: 120),
              ]
          )
        )
      )
    );
  }

}
