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
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: _AppBarActions(
                  sortOption: viewModel.sortOption,
                  onSortSelected: viewModel.changeSortOption,
                  onStatisticsPressed: () => context.push('/statistics'),
                  onExportPressed: () => _exportRecipes(context),
                  onImportPressed: () => _importRecipes(context, viewModel),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(child: _RecipeList(recipes: viewModel.recipes)),
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

class _AppBarActions extends StatelessWidget {
  const _AppBarActions({
    required this.sortOption,
    required this.onSortSelected,
    required this.onStatisticsPressed,
    required this.onExportPressed,
    required this.onImportPressed,
  });

  final RecipeSortOption sortOption;
  final ValueChanged<RecipeSortOption> onSortSelected;
  final VoidCallback onStatisticsPressed;
  final VoidCallback onExportPressed;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PopupMenuButton<RecipeSortOption>(
            tooltip: 'Sırala',
            icon: const Icon(Icons.sort, size: 22),
            initialValue: sortOption,
            constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
            padding: EdgeInsets.zero,
            onSelected: onSortSelected,
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
          _ToolbarIconButton(
            tooltip: 'İstatistikler',
            icon: Icons.insights,
            onPressed: onStatisticsPressed,
          ),
          _ToolbarIconButton(
            tooltip: 'Dışa aktar',
            icon: Icons.download,
            onPressed: onExportPressed,
          ),
          _ToolbarIconButton(
            tooltip: 'İçe aktar',
            icon: Icons.upload,
            onPressed: onImportPressed,
          ),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 22),
        constraints: const BoxConstraints.tightFor(width: 42, height: 42),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
      ),
    );
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 32,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _categories.map((String category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) => onSelected(category),
              ),
            );
          }).toList(growable: false),
        ),
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

    return SizedBox(
      width: double.infinity,
      child: Card(
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
