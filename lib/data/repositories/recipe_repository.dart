import 'dart:math';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe.dart';

class RecipeRepository {
  static const String _boxName = 'recipes';

  final Random _random;
  Box<Recipe>? _box;

  RecipeRepository({Random? random}) : _random = random ?? Random();

  Box<Recipe> get _recipesBox {
    final Box<Recipe>? box = _box;

    if (box == null || !box.isOpen) {
      throw StateError('RecipeRepository.init() must be called first.');
    }

    return box;
  }

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }

    _box = await Hive.openBox<Recipe>(_boxName);
  }

  List<Recipe> getAllRecipes() {
    return _recipesBox.values.toList(growable: false);
  }

  Future<void> addRecipe(Recipe recipe) {
    return _recipesBox.put(recipe.id, recipe);
  }

  Future<void> updateRecipe(Recipe recipe) {
    return _recipesBox.put(recipe.id, recipe);
  }

  Future<void> deleteRecipe(String id) {
    return _recipesBox.delete(id);
  }

  Recipe? getRandomRecipe() {
    final List<Recipe> recipes = getAllRecipes();

    if (recipes.isEmpty) {
      return null;
    }

    return recipes[_random.nextInt(recipes.length)];
  }
}
