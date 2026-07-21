import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

class ExportImportService {
  final RecipeRepository _repository;

  const ExportImportService(this._repository);

  Future<void> exportRecipes() async {
    final List<Recipe> recipes = _repository.getAllRecipes();
    final String jsonText = jsonEncode(
      recipes.map((Recipe recipe) => recipe.toJson()).toList(),
    );

    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File backupFile = File(
      '${temporaryDirectory.path}/my_recipes_backup.json',
    );

    await backupFile.writeAsString(jsonText);

    await Share.shareXFiles(<XFile>[
      XFile(backupFile.path, mimeType: 'application/json'),
    ]);
  }

  Future<bool> importRecipes() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final PlatformFile selectedFile = result.files.single;
      final String jsonText;

      if (selectedFile.bytes != null) {
        jsonText = utf8.decode(selectedFile.bytes!);
      } else if (selectedFile.path != null) {
        jsonText = await File(selectedFile.path!).readAsString();
      } else {
        return false;
      }

      final Object? decodedJson = jsonDecode(jsonText);

      if (decodedJson is! List) {
        return false;
      }

      final List<Recipe> recipes = decodedJson
          .whereType<Map<String, dynamic>>()
          .map(Recipe.fromJson)
          .toList(growable: false);

      if (recipes.length != decodedJson.length) {
        return false;
      }

      for (final Recipe recipe in recipes) {
        await _repository.addRecipe(recipe);
      }

      return true;
    } on FormatException {
      return false;
    } on FileSystemException {
      return false;
    } on ArgumentError {
      return false;
    } on TypeError {
      return false;
    }
  }
}
