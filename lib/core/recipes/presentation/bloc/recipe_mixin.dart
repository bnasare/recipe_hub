// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recipe_hub/core/recipes/domain/entities/recipe.dart';
import 'package:recipe_hub/shared/data/collection_ids.dart';
import 'package:recipe_hub/shared/data/firebase_constants.dart';
import 'package:recipe_hub/shared/widgets/snackbar.dart';

import '../../../../injection_container.dart';
import '../../../../shared/platform/push_notification.dart';
import '../../../chef/domain/entities/chef.dart';
import '../../../chef/presentation/bloc/chef_bloc.dart';
import '../../../review/domain/entities/review.dart';
import '../../../review/presentation/bloc/review_bloc.dart';
import 'recipe_bloc.dart';

mixin RecipeMixin {
  final bloc = sl<RecipeBloc>();
  final reviewBloc = sl<ReviewBloc>();
  final chefBloc = sl<ChefBloc>();

  Future<void> createARecipe({
    required BuildContext context,
    required String diet,
    required String difficultyLevel,
    required String title,
    required String overview,
    required String duration,
    required String category,
    required String image,
    required List<String> ingredients,
    required List<String> instructions,
  }) async {
    final result = await bloc.createARecipe(
      diet,
      difficultyLevel,
      title,
      overview,
      duration,
      category,
      image,
      ingredients,
      instructions,
    );
    return result.fold(
      (l) => SnackBarHelper.showErrorSnackBar(context, l.message),
      (r) {
        SnackBarHelper.showSuccessSnackBar(context, 'Recipe created');
        final String chefId = FirebaseConsts.currentUser!.uid;
        final tokenStream =
            retrieveChefStream(context: context, chefId: chefId);
        tokenStream.listen(
          (Chef chef) async {
            final PushNotification pushNotification = PushNotificationImpl(
              FlutterLocalNotificationsPlugin(),
            );
            final List<String> token = chef.token;
            if (token.isNotEmpty) {
              for (var singleToken in token) {
                await pushNotification.sendPushNotifs(
                  title: 'New Recipe Created',
                  body:
                      '${FirebaseConsts.currentUser!.displayName} created a new recipe!',
                  token: singleToken,
                );
              }
            } else {
              return;
            }
          },
          onError: (error) {
            log(error);
          },
        );
      },
    );
  }

  Stream<List<Recipe>> getRecipes({
    required BuildContext context,
    required String documentID,
  }) async* {
    final result = await bloc.getRecipes(documentID);
    yield result.fold(
      (l) {
        l;
        return <Recipe>[];
      },
      (r) => r,
    );
  }

  Stream<List<Recipe>> fetchAllRecipes(BuildContext context) async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String collectionPath = DatabaseCollections.recipes;

    Stream<QuerySnapshot> querySnapshotStream = firestore
        .collection(collectionPath)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots();

    await for (QuerySnapshot querySnapshot in querySnapshotStream) {
      List<Recipe> allRecipes = [];

      for (DocumentSnapshot snapshot in querySnapshot.docs) {
        String documentId = snapshot.id;
        await for (List<Recipe> recipes
            in getRecipes(context: context, documentID: documentId)) {
          allRecipes.addAll(recipes);
        }
      }

      yield allRecipes;
    }
  }

  Stream<List<Recipe>> fetchAllRecipesByCategory(
      BuildContext context, String category) async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String collectionPath = DatabaseCollections.recipes;
    QuerySnapshot querySnapshot = await firestore
        .collection(collectionPath)
        .where('category', isEqualTo: category)
        .get();

    List<Recipe> allRecipes = [];
    for (DocumentSnapshot snapshot in querySnapshot.docs) {
      String documentId = snapshot.id;
      await for (List<Recipe> recipes
          in getRecipes(context: context, documentID: documentId)) {
        allRecipes.addAll(recipes);
      }
    }
    yield allRecipes;
  }

  Stream<List<Recipe>> fetchAllRecipesByChefID(
      BuildContext context, String chefID) async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String collectionPath = DatabaseCollections.recipes;
    QuerySnapshot querySnapshot = await firestore
        .collection(collectionPath)
        .where('chefID', isEqualTo: chefID)
        .get();
    List<Recipe> allRecipes = [];

    for (DocumentSnapshot snapshot in querySnapshot.docs) {
      String documentId = snapshot.id;
      await for (List<Recipe> recipes
          in getRecipes(context: context, documentID: documentId)) {
        allRecipes.addAll(recipes);
      }
    }
    yield allRecipes;
  }

  Stream<List<Review>> getReviews({
    required BuildContext context,
    required String documentID,
  }) async* {
    final result = await reviewBloc.getReviews(documentID);
    yield result.fold(
      (l) {
        return <Review>[];
      },
      (r) => r,
    );
  }

  Stream<List<Review>> fetchReviewsByRecipeID(
      BuildContext context, String recipeID) async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String collectionPath = DatabaseCollections.reviews;
    QuerySnapshot querySnapshot = await firestore
        .collection(collectionPath)
        .where('recipeID', isEqualTo: recipeID)
        .get();

    List<Review> allReviews = [];

    for (DocumentSnapshot snapshot in querySnapshot.docs) {
      String documentId = snapshot.id;
      await for (List<Review> reviews
          in getReviews(context: context, documentID: documentId)) {
        allReviews.addAll(reviews);
      }
    }

    yield allReviews;
  }

  Future<void> like(
      {required BuildContext context,
      required String recipeId,
      required List<String> likers}) async {
    final result = await bloc.like(recipeId, likers);
    return result.fold(
      (l) => l,
      (r) => r,
    );
  }

  Future<void> follow(
      {required BuildContext context,
      required String chefId,
      required List<String> followers,
      required List<String> token}) async {
    final result = await chefBloc.follow(chefId, followers, token);
    return result.fold(
      (l) => l,
      (r) => r,
    );
  }

  Stream<int> retrieveFollowersCount(
      {required BuildContext context, required String chefId}) async* {
    while (true) {
      final result = await chefBloc.retrieve(chefId);
      yield result.fold(
        (l) {
          return 0;
        },
        (r) => r.followers.length,
      );
    }
  }

  Future<double> getAverageReviewsRating(
      String recipeId, BuildContext context) async {
    double sum = 0;
    int count = 0;
    await for (var reviews in fetchReviewsByRecipeID(context, recipeId)) {
      for (var review in reviews) {
        sum += review.rating;
        count++;
      }
    }
    return count != 0 ? sum / count : 0;
  }

  Future<Chef> retrieve(
      {required BuildContext context, required String chefId}) async {
    final result = await chefBloc.retrieve(chefId);
    return result.fold(
      (l) {
        return Chef.initial();
      },
      (r) => r,
    );
  }

  Future<List<String>> getCurrentUsersFollowers(
      BuildContext context, String currentChefId) async {
    try {
      Chef currentChef =
          await retrieve(context: context, chefId: currentChefId);
      return currentChef.followers;
    } catch (e) {
      return [];
    }
  }

  Stream<Chef> retrieveChefStream(
      {required BuildContext context, required String chefId}) async* {
    final result = await chefBloc.retrieve(chefId);
    yield* result.fold(
      (l) {
        return const Stream.empty();
      },
      (r) => Stream.value(r),
    );
  }
}