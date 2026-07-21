import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/recipe.dart';
import '../../main.dart';
import '../../viewmodels/recipe_viewmodel.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final List<TextEditingController> _ingredientControllers =
      <TextEditingController>[TextEditingController()];

  double _rating = 4;
  bool _submitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();

    for (final TextEditingController controller in _ingredientControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarif Ekle'),
        actions: <Widget>[
          TextButton(
            onPressed: _saveRecipe,
            child: const Text('Kaydet'),
          ),
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
              const SizedBox(height: 24),
              Text(
                'Malzemeler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._buildIngredientFields(),
              if (_submitted && _validIngredients().isEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'En az 1 malzeme girilmelidir.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Malzeme Ekle'),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _instructionsController,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Yapılış Aşamaları',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Yapılış aşamaları boş bırakılamaz.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Puanlama',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _ingredientControllers[index],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Malzeme ${index + 1}'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Malzemeyi sil',
              icon: const Icon(Icons.delete),
              onPressed: _ingredientControllers.length == 1
                  ? null
                  : () => _removeIngredientField(index),
            ),
          ],
        ),
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

  List<String> _validIngredients() {
    return _ingredientControllers
        .map((TextEditingController controller) => controller.text.trim())
        .where((String ingredient) => ingredient.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _saveRecipe() async {
    setState(() {
      _submitted = true;
    });

    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    final List<String> ingredients = _validIngredients();

    if (!isFormValid || ingredients.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();
    final Recipe recipe = Recipe(
      id: now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      ingredients: ingredients,
      instructions: _instructionsController.text.trim(),
      rating: _rating,
      createdAt: now,
    );

    final RecipeViewModel viewModel = RecipeViewModelScope.of(context);
    await viewModel.addRecipe(recipe);
    viewModel.generateRandomRecipe();

    if (!mounted) {
      return;
    }

    context.pop();
  }
}
