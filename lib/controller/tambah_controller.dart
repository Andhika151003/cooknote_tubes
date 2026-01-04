//Andhika
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/recipes_services.dart';
import '../services/auth_services.dart';
import '../models/recipes_model.dart';

class AddRecipeController extends ChangeNotifier {
  final RecipesServices _recipesServices = RecipesServices();
  final AuthServices _authServices = AuthServices();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController langkahController = TextEditingController();

  String selectedCategory = "Breakfast";
  String selectedDifficulty = "Mudah";

  File? imageFile;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        imageFile = File(picked.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<String> _uploadImage() async {
    if (imageFile == null) return "https://via.placeholder.com/150";

    try {
      final fileName = 'resep_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('images')
          .upload(fileName, imageFile!);

      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception("Gagal upload ke Supabase: $e");
    }
  }

  Future<bool> saveRecipe() async {
    if (titleController.text.isEmpty ||
        bahanController.text.isEmpty ||
        langkahController.text.isEmpty ||
        waktuController.text.isEmpty) {
      _errorMessage = "Semua kolom teks wajib diisi.";
      notifyListeners();
      return false;
    }

    if (imageFile == null) {
      _errorMessage = "Harap masukkan foto resep.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      firebase_auth.User? currentUser = _authServices.getCurrentUser();
      if (currentUser == null) {
        _errorMessage = "Sesi habis. Silakan login ulang.";
        _setLoading(false);
        return false;
      }

      String imageUrl = await _uploadImage();
      Recipes newRecipe = Recipes(
        idRecipes: '',
        idUser: currentUser.uid,
        title: titleController.text,
        categoriesId: selectedCategory,
        bahan: bahanController.text,
        langkah: langkahController.text,
        waktu: waktuController.text,
        kesulitan: selectedDifficulty,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        uploadedAt: DateTime.now(),
        userName: currentUser.displayName,
      );

      await _recipesServices.addRecipe(newRecipe);

      _setLoading(false);
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

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setDifficulty(String value) {
    selectedDifficulty = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    waktuController.dispose();
    bahanController.dispose();
    langkahController.dispose();
    super.dispose();
  }
}
