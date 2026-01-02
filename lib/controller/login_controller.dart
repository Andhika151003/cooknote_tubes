//Andhika

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

class LoginController extends ChangeNotifier {
  final AuthServices _authServices = AuthServices();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login() async {
    // 1. Validasi Dulu
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = "Email dan Password tidak boleh kosong.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // Panggil service
      User? user = await _authServices.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _setLoading(false);

      if (user != null) {
        _clearControllers();
        return true;
      }
      return false;
    } catch (e) {
      // 2. Tangkap pesan error ASLI dari Firebase (misal: "No user found", "Network error")
      _setLoading(false);
      _errorMessage = e.toString(); // Pesan error jadi lebih akurat
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
