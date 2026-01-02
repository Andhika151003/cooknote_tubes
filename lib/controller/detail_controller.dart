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

  // 1. FUNGSI CEK PEMILIK (PENTING!)
  bool isOwner(String idPembuatResep) {
    User? currentUser = _authServices.getCurrentUser();
    if (currentUser == null) return false;

    return currentUser.uid == idPembuatResep;
  }

  // 2. FUNGSI HAPUS RESEP
  Future<bool> deleteRecipe(Recipes recipe) async {
    _setLoading(true);

    try {
      // Panggil Service untuk hapus data di Firestore
      await _recipesServices.deleteRecipe(recipe);

      _setLoading(false);
      return true; // Berhasil dihapus
    } catch (e) {
      debugPrint("Gagal menghapus resep: $e");
      _setLoading(false);
      return false; // Gagal
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
