import 'package:flutter/material.dart';

import '../../data/models/recipe.dart';
import '../../main.dart';
import '../../viewmodels/recipe_viewmodel.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RecipeViewModel viewModel = RecipeViewModelScope.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        final Recipe? highestRatedRecipe = viewModel.highestRatedRecipe;

        return Scaffold(
          appBar: AppBar(title: const Text('İstatistikler')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: <Widget>[
                _MetricCard(
                  icon: Icons.restaurant_menu,
                  title: 'Toplam Tarif',
                  value: viewModel.totalRecipeCount.toString(),
                ),
                _MetricCard(
                  icon: Icons.star,
                  title: 'Ortalama Puan',
                  value: viewModel.averageRating.toStringAsFixed(1),
                ),
                _MetricCard(
                  icon: Icons.emoji_events,
                  title: 'En Yüksek Puanlı',
                  value: highestRatedRecipe?.title ?? 'Yok',
                  compactValue: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    this.compactValue = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: colorScheme.primary),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: compactValue ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: (compactValue
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.headlineMedium)
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
