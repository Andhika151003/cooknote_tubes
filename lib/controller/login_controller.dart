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
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = "Email dan Password tidak boleh kosong.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
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
      _setLoading(false);
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      User? user = await _authServices.signInWithGoogle();

      _setLoading(false);

      if (user != null) {
        _clearControllers(); // Opsional: bersihkan form email/pass
        return true;
      }
      return false; // User cancel atau gagal
    } catch (e) {
      _setLoading(false);
      _errorMessage = "Gagal masuk dengan Google";
      notifyListeners();
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
