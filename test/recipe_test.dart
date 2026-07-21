import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipes/data/models/recipe.dart';

void main() {
  group('Recipe', () {
    test('toJson should convert recipe fields to snake case json', () {
      final DateTime createdAt = DateTime(2026, 7, 21, 10, 30);
      final Recipe recipe = Recipe(
        id: 'recipe-1',
        title: 'Mercimek Çorbası',
        ingredients: <String>['Mercimek', 'Soğan', 'Havuç'],
        instructions: 'Malzemeleri pişir ve blenderdan geçir.',
        rating: 4.5,
        createdAt: createdAt,
      );

      final Map<String, dynamic> json = recipe.toJson();

      expect(json['id'], 'recipe-1');
      expect(json['title'], 'Mercimek Çorbası');
      expect(json['ingredients'], <String>['Mercimek', 'Soğan', 'Havuç']);
      expect(json['instructions'], 'Malzemeleri pişir ve blenderdan geçir.');
      expect(json['rating'], 4.5);
      expect(json['created_at'], createdAt.toIso8601String());
    });

    test('fromJson should create recipe from snake case json', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'recipe-2',
        'title': 'Menemen',
        'ingredients': <String>['Yumurta', 'Domates', 'Biber'],
        'instructions': 'Sebzeleri kavur, yumurtayı ekle.',
        'rating': 5,
        'created_at': '2026-07-21T11:15:00.000',
      };

      final Recipe recipe = Recipe.fromJson(json);

      expect(recipe.id, 'recipe-2');
      expect(recipe.title, 'Menemen');
      expect(recipe.ingredients, <String>['Yumurta', 'Domates', 'Biber']);
      expect(recipe.instructions, 'Sebzeleri kavur, yumurtayı ekle.');
      expect(recipe.rating, 5.0);
      expect(recipe.createdAt, DateTime.parse('2026-07-21T11:15:00.000'));
    });
  });
}
