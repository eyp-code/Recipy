// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['category'] as String? ?? 'Tümü',
      prepTimeInMinutes: (json['prep_time_in_minutes'] as num?)?.toInt() ?? 0,
      servingSize: (json['serving_size'] as num?)?.toInt() ?? 1,
      difficulty: json['difficulty'] as String? ?? 'Kolay',
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      isFavorite: json['is_favorite'] as bool? ?? false,
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'ingredients': instance.ingredients,
      'rating': instance.rating,
      'created_at': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'prep_time_in_minutes': instance.prepTimeInMinutes,
      'serving_size': instance.servingSize,
      'difficulty': instance.difficulty,
      'is_favorite': instance.isFavorite,
      'steps': instance.steps,
    };
