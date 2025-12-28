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
      } else {
        _errorMessage = "Email atau Password salah.";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
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
