import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router.dart';
import 'data/repositories/recipe_repository.dart';
import 'data/services/export_import_service.dart';
import 'data/services/onboarding_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/recipe_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final RecipeRepository repository = RecipeRepository();
  await repository.init();

  final RecipeViewModel viewModel = RecipeViewModel(repository);
  final ExportImportService exportImportService = ExportImportService(
    repository,
  );
  final OnboardingService onboardingService = OnboardingService();
  final bool showOnboarding = await onboardingService.shouldShowOnboarding();
  final GoRouter appRouter = createRouter(showOnboarding: showOnboarding);

  viewModel.loadRecipes();

  runApp(
    MyRecipesApp(
      viewModel: viewModel,
      exportImportService: exportImportService,
      onboardingService: onboardingService,
      router: appRouter,
    ),
  );
}

class MyRecipesApp extends StatelessWidget {
  const MyRecipesApp({
    required this.viewModel,
    required this.exportImportService,
    required this.onboardingService,
    required this.router,
    super.key,
  });

  final RecipeViewModel viewModel;
  final ExportImportService exportImportService;
  final OnboardingService onboardingService;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return RecipeViewModelScope(
      viewModel: viewModel,
      exportImportService: exportImportService,
      onboardingService: onboardingService,
      child: MaterialApp.router(
        title: 'My Recipes',
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }
}

class RecipeViewModelScope extends InheritedNotifier<RecipeViewModel> {
  const RecipeViewModelScope({
    required RecipeViewModel viewModel,
    required this.exportImportService,
    required this.onboardingService,
    required super.child,
    super.key,
  }) : super(notifier: viewModel);

  final ExportImportService exportImportService;
  final OnboardingService onboardingService;

  static RecipeViewModel of(BuildContext context) {
    final RecipeViewModelScope? scope = context
        .dependOnInheritedWidgetOfExactType<RecipeViewModelScope>();

    if (scope == null || scope.notifier == null) {
      throw StateError('RecipeViewModelScope was not found in the widget tree.');
    }

    return scope.notifier!;
  }

  static ExportImportService exportImportServiceOf(BuildContext context) {
    final RecipeViewModelScope? scope = context
        .dependOnInheritedWidgetOfExactType<RecipeViewModelScope>();

    if (scope == null) {
      throw StateError('RecipeViewModelScope was not found in the widget tree.');
    }

    return scope.exportImportService;
  }

  static OnboardingService onboardingServiceOf(BuildContext context) {
    final RecipeViewModelScope? scope = context
        .dependOnInheritedWidgetOfExactType<RecipeViewModelScope>();

    if (scope == null) {
      throw StateError('RecipeViewModelScope was not found in the widget tree.');
    }

    return scope.onboardingService;
  }
}
