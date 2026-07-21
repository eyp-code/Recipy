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
        rating: 4.5,
        createdAt: createdAt,
        category: 'Çorba',
        prepTimeInMinutes: 25,
        servingSize: 4,
        difficulty: 'Kolay',
        steps: <String>['Malzemeleri pişir.', 'Blenderdan geçir.'],
      );

      final Map<String, dynamic> json = recipe.toJson();

      expect(json['id'], 'recipe-1');
      expect(json['title'], 'Mercimek Çorbası');
      expect(json['ingredients'], <String>['Mercimek', 'Soğan', 'Havuç']);
      expect(json['rating'], 4.5);
      expect(json['created_at'], createdAt.toIso8601String());
      expect(json['category'], 'Çorba');
      expect(json['prep_time_in_minutes'], 25);
      expect(json['serving_size'], 4);
      expect(json['difficulty'], 'Kolay');
      expect(json['is_favorite'], false);
      expect(json['steps'], <String>['Malzemeleri pişir.', 'Blenderdan geçir.']);
    });

    test('fromJson should create recipe from snake case json', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'recipe-2',
        'title': 'Menemen',
        'ingredients': <String>['Yumurta', 'Domates', 'Biber'],
        'rating': 5,
        'created_at': '2026-07-21T11:15:00.000',
        'category': 'Tavuk',
        'prep_time_in_minutes': 15,
        'serving_size': 2,
        'difficulty': 'Kolay',
        'is_favorite': true,
        'steps': <String>['Sebzeleri kavur.', 'Yumurtayı ekle.'],
      };

      final Recipe recipe = Recipe.fromJson(json);

      expect(recipe.id, 'recipe-2');
      expect(recipe.title, 'Menemen');
      expect(recipe.ingredients, <String>['Yumurta', 'Domates', 'Biber']);
      expect(recipe.rating, 5.0);
      expect(recipe.createdAt, DateTime.parse('2026-07-21T11:15:00.000'));
      expect(recipe.category, 'Tavuk');
      expect(recipe.prepTimeInMinutes, 15);
      expect(recipe.servingSize, 2);
      expect(recipe.difficulty, 'Kolay');
      expect(recipe.isFavorite, true);
      expect(recipe.steps, <String>['Sebzeleri kavur.', 'Yumurtayı ekle.']);
    });
  });
}
