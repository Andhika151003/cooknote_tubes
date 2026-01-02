//Andhika

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

class RegisterController extends ChangeNotifier {
  final AuthServices _authServices = AuthServices();

  // Controller untuk 3 Input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fungsi Register
  Future<bool> register() async {
    // 1. Validasi Input Awal (Hemat Kuota)
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _errorMessage = "Semua kolom (Nama, Email, Password) wajib diisi.";
      notifyListeners();
      return false;
    }

    if (passwordController.text.trim().length < 6) {
      _errorMessage = "Password minimal 6 karakter.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // 2. Panggil Service Register
      User? user = await _authServices.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _setLoading(false);

      if (user != null) {
        // Sukses
        _clearControllers();
        return true;
      } else {
        // Gagal tanpa error spesifik (biasanya email sudah ada)
        _errorMessage = "Gagal mendaftar. Kemungkinan email sudah dipakai.";
        return false;
      }
    } catch (e) {
      // 3. Tangkap Error
      _setLoading(false);
      _errorMessage = e.toString();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
