import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/recipe.dart';
import '../../main.dart';
import '../../viewmodels/recipe_viewmodel.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({this.initialRecipe, super.key});

  final Recipe? initialRecipe;

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  static const List<String> _categories = <String>[
    'Tümü',
    'Tavuk',
    'Makarna',
    'Tatlı',
    'Çorba',
    'Vejetaryen',
  ];

  static const List<String> _difficulties = <String>['Kolay', 'Orta', 'Zor'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController(
    text: '25',
  );
  final TextEditingController _servingSizeController = TextEditingController(
    text: '2',
  );
  final List<TextEditingController> _ingredientControllers =
      <TextEditingController>[TextEditingController()];
  final List<TextEditingController> _stepControllers =
      <TextEditingController>[TextEditingController()];

  String _category = 'Tümü';
  String _difficulty = 'Kolay';
  double _rating = 4;
  bool _isFavorite = false;
  bool _submitted = false;

  bool get _isEditing => widget.initialRecipe != null;

  @override
  void initState() {
    super.initState();

    final Recipe? recipe = widget.initialRecipe;

    if (recipe == null) {
      return;
    }

    _titleController.text = recipe.title;
    _prepTimeController.text = recipe.prepTimeInMinutes.toString();
    _servingSizeController.text = recipe.servingSize.toString();
    _category = _categories.contains(recipe.category)
        ? recipe.category
        : _categories.first;
    _difficulty = _difficulties.contains(recipe.difficulty)
        ? recipe.difficulty
        : _difficulties.first;
    _rating = recipe.rating;
    _isFavorite = recipe.isFavorite;

    _replaceControllers(_ingredientControllers, recipe.ingredients);
    _replaceControllers(_stepControllers, recipe.steps);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _prepTimeController.dispose();
    _servingSizeController.dispose();

    for (final TextEditingController controller in _ingredientControllers) {
      controller.dispose();
    }

    for (final TextEditingController controller in _stepControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Tarifi Düzenle' : 'Tarif Ekle'),
        actions: <Widget>[
          TextButton(onPressed: _saveRecipe, child: const Text('Kaydet')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Tarif Adı'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tarif adı boş bırakılamaz.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _category = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hazırlanma Süresi',
                        suffixText: 'dk',
                      ),
                      validator: _positiveIntegerValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _servingSizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Porsiyon',
                        suffixText: 'kişi',
                      ),
                      validator: _positiveIntegerValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Zorluk', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _difficulties.map((String difficulty) {
                  return ChoiceChip(
                    label: Text(difficulty),
                    selected: _difficulty == difficulty,
                    selectedColor: _difficultyColor(context, difficulty),
                    onSelected: (_) {
                      setState(() {
                        _difficulty = difficulty;
                      });
                    },
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favori'),
                secondary: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                value: _isFavorite,
                onChanged: (bool value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text('Malzemeler', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._buildIngredientFields(),
              _ValidationText(
                visible: _submitted && _validIngredients().isEmpty,
                text: 'En az 1 malzeme girilmelidir.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Malzeme Ekle'),
              ),
              const SizedBox(height: 24),
              Text(
                'Hazırlanış Adımları',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._buildStepFields(),
              _ValidationText(
                visible: _submitted && _validSteps().isEmpty,
                text: 'En az 1 hazırlanış adımı girilmelidir.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _addStepField,
                icon: const Icon(Icons.add),
                label: const Text('Adım Ekle'),
              ),
              const SizedBox(height: 24),
              Text('Puanlama', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 5,
                      divisions: 8,
                      value: _rating,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (double value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('⭐ ${_rating.toStringAsFixed(1)}'),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIngredientFields() {
    return List<Widget>.generate(_ingredientControllers.length, (int index) {
      return _DynamicTextRow(
        controller: _ingredientControllers[index],
        label: 'Malzeme ${index + 1}',
        deleteTooltip: 'Malzemeyi sil',
        canDelete: _ingredientControllers.length > 1,
        onDelete: () => _removeIngredientField(index),
      );
    });
  }

  List<Widget> _buildStepFields() {
    return List<Widget>.generate(_stepControllers.length, (int index) {
      return _DynamicTextRow(
        controller: _stepControllers[index],
        label: '${index + 1}. Adım',
        deleteTooltip: 'Adımı sil',
        canDelete: _stepControllers.length > 1,
        maxLines: 3,
        onDelete: () => _removeStepField(index),
      );
    });
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    final TextEditingController controller = _ingredientControllers.removeAt(
      index,
    );
    controller.dispose();

    setState(() {});
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    final TextEditingController controller = _stepControllers.removeAt(index);
    controller.dispose();

    setState(() {});
  }

  List<String> _validIngredients() {
    return _textValuesFrom(_ingredientControllers);
  }

  List<String> _validSteps() {
    return _textValuesFrom(_stepControllers);
  }

  List<String> _textValuesFrom(List<TextEditingController> controllers) {
    return controllers
        .map((TextEditingController controller) => controller.text.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  String? _positiveIntegerValidator(String? value) {
    final int? number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Pozitif sayı gir.';
    }

    return null;
  }

  Color _difficultyColor(BuildContext context, String difficulty) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (difficulty) {
      case 'Kolay':
        return colorScheme.primaryContainer;
      case 'Orta':
        return colorScheme.secondaryContainer;
      case 'Zor':
        return colorScheme.errorContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Future<void> _saveRecipe() async {
    setState(() {
      _submitted = true;
    });

    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    final List<String> ingredients = _validIngredients();
    final List<String> steps = _validSteps();

    if (!isFormValid || ingredients.isEmpty || steps.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();
    final Recipe? initialRecipe = widget.initialRecipe;
    final Recipe recipe = Recipe(
      id: initialRecipe?.id ?? now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      ingredients: ingredients,
      rating: _rating,
      createdAt: initialRecipe?.createdAt ?? now,
      category: _category,
      prepTimeInMinutes: int.parse(_prepTimeController.text.trim()),
      servingSize: int.parse(_servingSizeController.text.trim()),
      difficulty: _difficulty,
      isFavorite: _isFavorite,
      steps: steps,
    );

    final RecipeViewModel viewModel = RecipeViewModelScope.of(context);
    if (_isEditing) {
      await viewModel.updateRecipe(recipe);
    } else {
      await viewModel.addRecipe(recipe);
    }
    viewModel.generateRandomRecipe();

    if (!mounted) {
      return;
    }

    context.pop();
  }

  void _replaceControllers(
    List<TextEditingController> controllers,
    List<String> values,
  ) {
    for (final TextEditingController controller in controllers) {
      controller.dispose();
    }

    controllers
      ..clear()
      ..addAll(
        (values.isEmpty ? <String>[''] : values).map(
          (String value) => TextEditingController(text: value),
        ),
      );
  }
}

class _DynamicTextRow extends StatelessWidget {
  const _DynamicTextRow({
    required this.controller,
    required this.label,
    required this.deleteTooltip,
    required this.canDelete,
    required this.onDelete,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String deleteTooltip;
  final bool canDelete;
  final VoidCallback onDelete;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.next,
              maxLines: maxLines,
              decoration: InputDecoration(labelText: label),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: deleteTooltip,
            icon: const Icon(Icons.delete),
            onPressed: canDelete ? onDelete : null,
          ),
        ],
      ),
    );
  }
}

class _ValidationText extends StatelessWidget {
  const _ValidationText({required this.visible, required this.text});

  final bool visible;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
