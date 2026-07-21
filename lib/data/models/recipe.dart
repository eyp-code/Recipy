import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.rating,
    required this.createdAt,
    required this.category,
    required this.prepTimeInMinutes,
    required this.servingSize,
    required this.difficulty,
    required this.steps,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final double rating;
  final DateTime createdAt;
  @JsonKey(defaultValue: 'Tümü')
  final String category;
  @JsonKey(defaultValue: 0)
  final int prepTimeInMinutes;
  @JsonKey(defaultValue: 1)
  final int servingSize;
  @JsonKey(defaultValue: 'Kolay')
  final String difficulty;
  @JsonKey(defaultValue: false)
  final bool isFavorite;
  @JsonKey(defaultValue: <String>[])
  final List<String> steps;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final int numberOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
      for (int i = 0; i < numberOfFields; i++) reader.readByte(): reader.read(),
    };

    return Recipe(
      id: fields[0] as String,
      title: fields[1] as String,
      ingredients: (fields[2] as List).cast<String>(),
      rating: (fields[4] as num).toDouble(),
      createdAt: fields[5] as DateTime,
      category: fields[6] as String? ?? 'Tümü',
      prepTimeInMinutes: fields[7] as int? ?? 0,
      servingSize: fields[8] as int? ?? 1,
      difficulty: fields[9] as String? ?? 'Kolay',
      isFavorite: fields[10] as bool? ?? false,
      steps: _readSteps(fields),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.ingredients)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.prepTimeInMinutes)
      ..writeByte(8)
      ..write(obj.servingSize)
      ..writeByte(9)
      ..write(obj.difficulty)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.steps);
  }

  List<String> _readSteps(Map<int, dynamic> fields) {
    final dynamic stepsValue = fields[11];

    if (stepsValue is List) {
      return stepsValue.cast<String>();
    }

    final dynamic legacyInstructions = fields[3];

    if (legacyInstructions is String && legacyInstructions.trim().isNotEmpty) {
      return <String>[legacyInstructions];
    }

    return <String>[];
  }
}
