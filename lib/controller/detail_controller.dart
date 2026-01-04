//Andhika

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/recipes_services.dart';
import '../services/auth_services.dart';
import '../models/recipes_model.dart';

class DetailRecipeController extends ChangeNotifier {
  final RecipesServices _recipesServices = RecipesServices();
  final AuthServices _authServices = AuthServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isOwner(String idPembuatResep) {
    User? currentUser = _authServices.getCurrentUser();
    if (currentUser == null) return false;

    return currentUser.uid == idPembuatResep;
  }

  Future<bool> deleteRecipe(Recipes recipe) async {
    _setLoading(true);

    try {
      await _recipesServices.deleteRecipe(recipe);

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Gagal menghapus resep: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
