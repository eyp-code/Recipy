import 'package:flutter/foundation.dart';

import '../data/models/recipe.dart';
import '../data/repositories/recipe_repository.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  List<Recipe> _recipes = <Recipe>[];
  Recipe? _randomRecipe;

  RecipeViewModel(this._repository);

  List<Recipe> get recipes => _recipes;

  Recipe? get randomRecipe => _randomRecipe;

  void loadRecipes() {
    _recipes = _repository.getAllRecipes();
    notifyListeners();
  }

  void generateRandomRecipe() {
    _randomRecipe = _repository.getRandomRecipe();
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _repository.addRecipe(recipe);
    loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _repository.updateRecipe(recipe);
    loadRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    await _repository.deleteRecipe(id);
    loadRecipes();
  }
}
