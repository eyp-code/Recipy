import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.rating,
    required this.createdAt,
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final double rating;
  final DateTime createdAt;

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
      instructions: fields[3] as String,
      rating: (fields[4] as num).toDouble(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.ingredients)
      ..writeByte(3)
      ..write(obj.instructions)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
