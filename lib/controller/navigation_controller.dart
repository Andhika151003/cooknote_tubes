// Andhika

import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // Fungsi untuk mengganti halaman
  void changePage(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
