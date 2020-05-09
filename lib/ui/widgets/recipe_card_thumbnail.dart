import 'package:flutter/material.dart';
import 'package:home_cooked/model/recipe.dart';
import 'package:home_cooked/ui/screens/individual_recipe.dart';
import 'package:logging/logging.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/service/recipe_service.dart';

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
          log.info("${recipe.id} removed from queue");
          recipe.tags.remove('queue');
        } else {
          log.info("${recipe.id} added from queue");
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
          child: AspectRatio(
            aspectRatio: 0.95, //This needs to match the aspectRatio on home.dart
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //title at top, image at bottom
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
                // todo cache image
                recipe.imageUrl == null ? Container() : Expanded(
                  child: Container(
                    child: Image.network(recipe.imageUrl, fit: BoxFit.cover)
                  )
                )
              ]
            )
          )
        )
      )
    );
  }

}
