import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String diet,
    required String difficultyLevel,
    required String title,
    required String overview,
    required String duration,
    required String category,
    required String image,
    required String chef,
    required String chefID,
    required String id,
    required String chefToken,
    required DateTime createdAt,
    required List<String> likes,
    required List<String> ingredients,
    required List<String> instructions,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  factory Recipe.initial() => Recipe(
        diet: '',
        difficultyLevel: '',
        title: '',
        overview: '',
        duration: '',
        category: '',
        image: '',
        chef: '',
        chefID: '',
        id: '',
        chefToken: '',
        createdAt: DateTime.now(),
        likes: [],
        ingredients: [],
        instructions: [],
      );
}
