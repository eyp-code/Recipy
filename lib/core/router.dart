import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/recipe.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../ui/screens/add_recipe_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/recipe_detail_screen.dart';
import '../ui/screens/statistics_screen.dart';

GoRouter createRouter({required bool showOnboarding}) {
  return GoRouter(
    initialLocation: showOnboarding ? '/onboarding' : '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/add-recipe',
      builder: (BuildContext context, GoRouterState state) {
        final Object? extra = state.extra;

        return AddRecipeScreen(
          initialRecipe: extra is Recipe ? extra : null,
        );
      },
    ),
    GoRoute(
      path: '/recipe/:id',
      builder: (BuildContext context, GoRouterState state) {
        return RecipeDetailScreen(
          recipeId: state.pathParameters['id'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/statistics',
      builder: (BuildContext context, GoRouterState state) {
        return const StatisticsScreen();
      },
    ),
    ],
  );
}
