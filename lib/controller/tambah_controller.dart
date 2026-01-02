//Andhika

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/recipes_services.dart';
import '../services/auth_services.dart';
import '../models/recipes_model.dart';

class AddRecipeController extends ChangeNotifier {
  final RecipesServices _recipesServices = RecipesServices();
  final AuthServices _authServices = AuthServices();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController langkahController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();

  String? selectedCategoryId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearForm() {
    titleController.clear();
    bahanController.clear();
    langkahController.clear();
    waktuController.clear();
    selectedCategoryId = null;
    notifyListeners();
  }

  // Fungsi Utama: Simpan Resep
  Future<bool> saveRecipe() async {
    // 1. Validasi Input
    if (titleController.text.isEmpty ||
        bahanController.text.isEmpty ||
        langkahController.text.isEmpty ||
        waktuController.text.isEmpty) {
      _errorMessage = "Semua kolom teks wajib diisi.";
      notifyListeners();
      return false;
    }

    if (selectedCategoryId == null) {
      _errorMessage = "Harap pilih kategori resep.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      // 2. Ambil User yang sedang Login
      User? currentUser = _authServices.getCurrentUser();
      if (currentUser == null) {
        _errorMessage = "Sesi habis. Silakan login ulang.";
        _setLoading(false);
        return false;
      }

      // 3. Buat Object Recipes
      Recipes newRecipe = Recipes(
        idRecipes: '',
        idUser: currentUser.uid,
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

      // 4. Panggil Service
      await _recipesServices.addRecipe(newRecipe);

      _setLoading(false);
      clearForm();
      return true;
    } catch (e) {
      _errorMessage = "Gagal menyimpan: $e";
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Setter untuk Dropdown (Dipanggil UI saat user pilih kategori)
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
