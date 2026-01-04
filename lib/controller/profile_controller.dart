//Andhika

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';
import '../models/users_model.dart';

class ProfileController extends ChangeNotifier {
  final AuthServices _authServices = AuthServices();

  Users? _userProfile;
  bool _isLoading = false;

  Users? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? currentUser = _authServices.getCurrentUser();
      if (currentUser != null) {
        _userProfile = await _authServices.getUserProfile(currentUser.uid);
      }
    } catch (e) {
      debugPrint("Gagal load profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authServices.logout();
    _userProfile = null;
    notifyListeners();
  }
}
