import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/recipe.dart';
import '../../main.dart';
import '../../viewmodels/recipe_viewmodel.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Set<int> _completedSteps = <int>{};

  @override
  Widget build(BuildContext context) {
    final RecipeViewModel viewModel = RecipeViewModelScope.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        final Recipe? recipe = _findRecipe(viewModel.recipes);

        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tarif Bulunamadı')),
            body: Center(
              child: Text(
                'Bu tarif artık mevcut değil.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: <Widget>[
              IconButton(
                tooltip: 'Düzenle',
                icon: const Icon(Icons.edit),
                onPressed: null,
              ),
              IconButton(
                tooltip: 'Sil',
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, viewModel, recipe),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RecipeHeader(recipe: recipe),
                const SizedBox(height: 24),
                const _SectionTitle(text: 'Malzemeler'),
                const SizedBox(height: 12),
                _IngredientsList(ingredients: recipe.ingredients),
                const SizedBox(height: 24),
                const _SectionTitle(text: 'Hazırlanışı'),
                const SizedBox(height: 12),
                _StepChecklist(
                  steps: recipe.steps,
                  completedSteps: _completedSteps,
                  onChanged: _toggleStep,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Recipe? _findRecipe(List<Recipe> recipes) {
    for (final Recipe recipe in recipes) {
      if (recipe.id == widget.recipeId) {
        return recipe;
      }
    }

    return null;
  }

  void _toggleStep(int index, bool completed) {
    setState(() {
      if (completed) {
        _completedSteps.add(index);
      } else {
        _completedSteps.remove(index);
      }
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RecipeViewModel viewModel,
    Recipe recipe,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tarifi sil'),
          content: Text('${recipe.title} tarifini silmek istiyor musun?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await viewModel.deleteRecipe(recipe.id);
    viewModel.generateRandomRecipe();

    if (!context.mounted) {
      return;
    }

    context.pop();
  }
}

class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              recipe.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _formattedDate(recipe.createdAt),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _InfoBadge(text: '⭐ ${recipe.rating.toStringAsFixed(1)}'),
                _InfoBadge(text: '⏱ ${recipe.prepTimeInMinutes} dk'),
                _InfoBadge(text: '${recipe.servingSize} kişi'),
                _InfoBadge(text: recipe.difficulty),
                _InfoBadge(text: recipe.isFavorite ? '❤️ Favori' : '♡ Favori'),
                _InfoBadge(text: recipe.category),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  const _IngredientsList({required this.ingredients});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          children: ingredients.map((String ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('•', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _StepChecklist extends StatelessWidget {
  const _StepChecklist({
    required this.steps,
    required this.completedSteps,
    required this.onChanged,
  });

  final List<String> steps;
  final Set<int> completedSteps;
  final void Function(int index, bool completed) onChanged;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Hazırlanış adımı eklenmedi.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: List<Widget>.generate(steps.length, (int index) {
            final bool completed = completedSteps.contains(index);

            return CheckboxListTile(
              value: completed,
              onChanged: (bool? value) {
                onChanged(index, value ?? false);
              },
              title: Text(
                '${index + 1}. ${steps[index]}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: completed
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                    ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}
