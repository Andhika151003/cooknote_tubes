//Andhika

import 'package:firebase_auth/firebase_auth.dart';
import '../models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // fungsi login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("Error Login: $e");
      return null;
    }
  }

  // fungsi register
  Future<User?> register(String name, String email, String password) async {
    try {
      // 1. Buat akun di Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // 2. Simpan Biodata ke Firestore
      if (user != null) {
        Users newUser = Users(
          idUser: user.uid,
          name: name,
          email: email,
          password: password,
          createdAt: DateTime.now(),
        );

        // Simpan dengan ID yang sama dengan UID Auth
        await _db.collection('users').doc(user.uid).set(newUser.toJson());

        return user;
      }
    } catch (e) {
      debugPrint("Error Register: $e");
      return null;
    }
    return null;
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
