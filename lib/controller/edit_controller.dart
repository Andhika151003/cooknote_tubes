//Andhika

import 'package:flutter/material.dart';
import '../services/recipes_services.dart';
import '../models/recipes_model.dart';

class EditRecipeController extends ChangeNotifier {
  final RecipesServices _recipesServices = RecipesServices();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController langkahController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();

  String? selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadExistingData(Recipes recipe) {
    titleController.text = recipe.title;
    bahanController.text = recipe.bahan;
    langkahController.text = recipe.langkah;
    waktuController.text = recipe.waktu;
    selectedCategoryId = recipe.categoriesId;

    notifyListeners();
  }

  Future<bool> updateRecipe(String recipeId, String userId) async {
    if (titleController.text.isEmpty ||
        bahanController.text.isEmpty ||
        langkahController.text.isEmpty ||
        waktuController.text.isEmpty) {
      _errorMessage = "Semua kolom teks wajib diisi.";
      notifyListeners();
      return false;
    }

    if (selectedCategoryId == null) {
      _errorMessage = "Kategori tidak valid.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      Recipes updatedRecipe = Recipes(
        idRecipes: recipeId,
        idUser: userId,
        title: titleController.text,
        categoriesId: selectedCategoryId!,
        bahan: bahanController.text,
        langkah: langkahController.text,
        waktu: waktuController.text,
        kesulitan: "Sedang",
        imageUrl: "https://via.placeholder.com/150",
        createdAt: DateTime.now(),
        uploadedAt: DateTime.now(),
      );

      await _recipesServices.updateRecipe(updatedRecipe);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengupdate: $e";
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Setter Dropdown
  void setCategory(String? value) {
    selectedCategoryId = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    bahanController.dispose();
    langkahController.dispose();
    waktuController.dispose();
    super.dispose();
  }
}
