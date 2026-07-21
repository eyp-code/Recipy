import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/recipe_sort_option.dart';
import '../../data/models/recipe.dart';
import '../../main.dart';
import '../../viewmodels/recipe_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _randomRecipeRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_randomRecipeRequested) {
      return;
    }

    _randomRecipeRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      RecipeViewModelScope.of(context).generateRandomRecipe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final RecipeViewModel viewModel = RecipeViewModelScope.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tariflerim'),
            actions: <Widget>[
              PopupMenuButton<RecipeSortOption>(
                tooltip: 'Sırala',
                icon: const Icon(Icons.sort),
                initialValue: viewModel.sortOption,
                onSelected: viewModel.changeSortOption,
                itemBuilder: (BuildContext context) {
                  return const <PopupMenuEntry<RecipeSortOption>>[
                    PopupMenuItem<RecipeSortOption>(
                      value: RecipeSortOption.rating,
                      child: Text('Puan'),
                    ),
                    PopupMenuItem<RecipeSortOption>(
                      value: RecipeSortOption.newest,
                      child: Text('Yeni'),
                    ),
                    PopupMenuItem<RecipeSortOption>(
                      value: RecipeSortOption.alphabetical,
                      child: Text('A-Z'),
                    ),
                  ];
                },
              ),
              IconButton(
                tooltip: 'İstatistikler',
                icon: const Icon(Icons.insights),
                onPressed: () => context.push('/statistics'),
              ),
              IconButton(
                tooltip: 'Dışa aktar',
                icon: const Icon(Icons.download),
                onPressed: () => _exportRecipes(context),
              ),
              IconButton(
                tooltip: 'İçe aktar',
                icon: const Icon(Icons.upload),
                onPressed: () => _importRecipes(context, viewModel),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RandomRecipeCard(recipe: viewModel.randomRecipe),
                const SizedBox(height: 24),
                _CategoryFilter(
                  selectedCategory: viewModel.selectedCategory,
                  onSelected: viewModel.selectCategory,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tüm Tarifler',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _RecipeList(recipes: viewModel.recipes),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add-recipe'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _exportRecipes(BuildContext context) async {
    final exportImportService = RecipeViewModelScope.exportImportServiceOf(
      context,
    );

    await exportImportService.exportRecipes();
  }

  Future<void> _importRecipes(
    BuildContext context,
    RecipeViewModel viewModel,
  ) async {
    final exportImportService = RecipeViewModelScope.exportImportServiceOf(
      context,
    );
    final bool imported = await exportImportService.importRecipes();

    if (!mounted) {
      return;
    }

    if (!imported) {
      return;
    }

    viewModel
      ..loadRecipes()
      ..generateRandomRecipe();
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.selectedCategory,
    required this.onSelected,
  });

  static const List<String> _categories = <String>[
    'Tümü',
    'Tavuk',
    'Makarna',
    'Tatlı',
    'Çorba',
    'Vejetaryen',
  ];

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((String category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (_) => onSelected(category),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _RandomRecipeCard extends StatelessWidget {
  const _RandomRecipeCard({required this.recipe});

  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    final Recipe? currentRecipe = recipe;

    if (currentRecipe == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Henüz günün tarifi yok.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/recipe/${currentRecipe.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Bugün bunu mu yapsan?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Text(
                currentRecipe.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                '⭐ ${currentRecipe.rating.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  const _RecipeList({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Center(
        child: Text(
          'Henüz tarif eklenmedi.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (BuildContext context, int index) {
        final Recipe recipe = recipes[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(recipe.title),
            subtitle: Text(_ingredientsSummary(recipe.ingredients)),
            trailing: Text('⭐ ${recipe.rating.toStringAsFixed(1)}'),
            onTap: () => context.push('/recipe/${recipe.id}'),
          ),
        );
      },
    );
  }

  String _ingredientsSummary(List<String> ingredients) {
    if (ingredients.isEmpty) {
      return 'Malzeme eklenmedi';
    }

    if (ingredients.length <= 3) {
      return ingredients.join(', ');
    }

    return '${ingredients.take(3).join(', ')}...';
  }
}
