//Andhika

import 'package:flutter/material.dart';
import '../services/recipes_services.dart';
import '../models/recipes_model.dart';

class EditRecipeController extends ChangeNotifier {
  final RecipesServices _recipesServices = RecipesServices();

  // Text Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController langkahController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();

  // Variabel Dropdown
  String? selectedCategoryId;

  // State
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. FUNGSI LOAD DATA (KUNCI UTAMA EDIT)
  // Fungsi ini dipanggil begitu halaman Edit dibuka untuk mengisi form dengan data lama
  void loadExistingData(Recipes recipe) {
    titleController.text = recipe.title;
    bahanController.text = recipe.bahan;
    langkahController.text = recipe.langkah;
    waktuController.text = recipe.waktu;
    selectedCategoryId = recipe.categoriesId;

    notifyListeners();
  }

  // 2. FUNGSI UPDATE RESEP
  Future<bool> updateRecipe(String recipeId, String userId) async {
    // Validasi Input
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
      // Buat Objek Resep Baru dengan ID yang SAMA (Penting!)
      // Kita pakai ID lama (recipeId) agar Firestore tahu data mana yang ditimpa
      Recipes updatedRecipe = Recipes(
        idRecipes: recipeId, // ID Dokumen Lama
        idUser: userId, // ID Pemilik Lama
        title: titleController.text,
        categoriesId: selectedCategoryId!,
        bahan: bahanController.text,
        langkah: langkahController.text,
        waktu: waktuController.text,
        kesulitan: "Sedang", // Atau buat dropdown jika mau diubah
        imageUrl:
            "https://via.placeholder.com/150", // Gambar tetap (atau update jika ada fitur upload)
        createdAt:
            DateTime.now(), // Field ini biasanya diabaikan/tidak diupdate, tapi required di model
        uploadedAt: DateTime.now(), // Update waktu upload terakhir
      );

      // Panggil Service Update
      await _recipesServices.updateRecipe(updatedRecipe);

      _setLoading(false);
      return true; // Sukses
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
