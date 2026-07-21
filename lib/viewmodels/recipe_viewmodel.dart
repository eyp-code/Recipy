import 'package:flutter/foundation.dart';

import '../core/recipe_sort_option.dart';
import '../data/models/recipe.dart';
import '../data/repositories/recipe_repository.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  List<Recipe> _allRecipes = <Recipe>[];
  List<Recipe> _recipes = <Recipe>[];
  Recipe? _randomRecipe;
  String _selectedCategory = 'Tümü';
  RecipeSortOption _sortOption = RecipeSortOption.newest;

  RecipeViewModel(this._repository);

  List<Recipe> get recipes => _recipes;

  Recipe? get randomRecipe => _randomRecipe;

  String get selectedCategory => _selectedCategory;

  RecipeSortOption get sortOption => _sortOption;

  int get totalRecipeCount => _allRecipes.length;

  Recipe? get highestRatedRecipe {
    if (_allRecipes.isEmpty) {
      return null;
    }

    final List<Recipe> sortedRecipes = List<Recipe>.of(_allRecipes)
      ..sort((Recipe first, Recipe second) {
        return second.rating.compareTo(first.rating);
      });

    return sortedRecipes.first;
  }

  double get averageRating {
    if (_allRecipes.isEmpty) {
      return 0;
    }

    final double totalRating = _allRecipes.fold<double>(
      0,
      (double total, Recipe recipe) => total + recipe.rating,
    );

    return totalRating / _allRecipes.length;
  }

  void loadRecipes() {
    _allRecipes = _repository.getAllRecipes();
    _recipes = _repository.getRecipes(
      category: _selectedCategory,
      sortOption: _sortOption,
    );
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    loadRecipes();
  }

  void changeSortOption(RecipeSortOption sortOption) {
    _sortOption = sortOption;
    loadRecipes();
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
