// lib/controller/edit_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/recipes_services.dart';
import '../models/recipes_model.dart';

class EditRecipeController extends ChangeNotifier {
  final RecipesServices _recipesServices = RecipesServices();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController langkahController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();

  // Variabel Pilihan Dropdown/Chip
  String? selectedCategoryId;
  String selectedDifficulty = "Sedang"; // Default

  // Variabel Gambar & Data Asli
  File? newImageFile;
  String? oldImageUrl;
  DateTime? originalCreatedAt;
  String? originalUserName; // [PENTING] Simpan nama user asli

  // Status Loading & Error
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- FUNGSI 1: LOAD DATA SAAT MASUK HALAMAN EDIT ---
  void loadExistingData(Recipes recipe) {
    titleController.text = recipe.title;
    bahanController.text = recipe.bahan;
    langkahController.text = recipe.langkah;
    waktuController.text = recipe.waktu;

    selectedCategoryId = recipe.categoriesId;
    selectedDifficulty = recipe.kesulitan;

    oldImageUrl = recipe.imageUrl;
    originalCreatedAt = recipe.createdAt;

    // [PENTING] Simpan nama user dari data lama agar tidak hilang
    originalUserName = recipe.userName;

    notifyListeners();
  }

  // --- FUNGSI 2: PILIH GAMBAR DARI GALERI ---
  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        newImageFile = File(picked.path);
        notifyListeners(); // Update UI agar gambar baru muncul
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // --- FUNGSI 3: UPLOAD GAMBAR KE SUPABASE (Internal) ---
  Future<String> _uploadNewImage() async {
    // Jika user tidak memilih gambar baru, kembalikan URL lama
    if (newImageFile == null) return oldImageUrl ?? "";

    try {
      // Buat nama file unik
      final fileName =
          'resep_edit_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload ke bucket 'images'
      await Supabase.instance.client.storage
          .from('images')
          .upload(fileName, newImageFile!);

      // Ambil URL publik
      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception("Gagal upload gambar baru: $e");
    }
  }

  // --- FUNGSI 4: SIMPAN PERUBAHAN (UPDATE) ---
  Future<bool> updateRecipe(String recipeId, String userId) async {
    // 1. Validasi Input Kosong
    if (titleController.text.isEmpty ||
        bahanController.text.isEmpty ||
        langkahController.text.isEmpty ||
        waktuController.text.isEmpty) {
      _errorMessage = "Semua kolom teks wajib diisi.";
      notifyListeners();
      return false;
    }

    // 2. Validasi Kategori
    if (selectedCategoryId == null) {
      _errorMessage = "Kategori tidak valid.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      // 3. Tentukan URL Gambar Akhir
      String finalImageUrl = oldImageUrl ?? "";

      // Jika ada gambar baru, upload dulu lalu pakai URL barunya
      if (newImageFile != null) {
        finalImageUrl = await _uploadNewImage();
      }

      // 4. Buat Objek Resep Baru
      Recipes updatedRecipe = Recipes(
        idRecipes: recipeId,
        idUser: userId,
        title: titleController.text,
        categoriesId: selectedCategoryId!,
        bahan: bahanController.text,
        langkah: langkahController.text,
        waktu: waktuController.text,
        kesulitan: selectedDifficulty,
        imageUrl: finalImageUrl,

        // Jaga data tanggal asli & nama user asli
        createdAt: originalCreatedAt ?? DateTime.now(),
        uploadedAt: DateTime.now(), // Update waktu edit ke sekarang
        userName: originalUserName, // [PENTING] Masukkan kembali nama user asli
      );

      // 5. Kirim ke Firestore via Service
      await _recipesServices.updateRecipe(updatedRecipe);

      _setLoading(false);
      return true; // Berhasil
    } catch (e) {
      _errorMessage = "Gagal mengupdate: $e";
      _setLoading(false);
      return false; // Gagal
    }
  }

  // --- SETTER & HELPER ---

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    selectedCategoryId = value;
    notifyListeners();
  }

  void setDifficulty(String value) {
    selectedDifficulty = value;
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
