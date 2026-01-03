// Andhika
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

  Future<Users?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return Users.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Error Get Profile: $e");
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("Login berhasil: ${result.user?.email}");
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Email tidak terdaftar";
          break;
        case 'wrong-password':
          errorMessage = "Password salah";
          break;
        case 'invalid-email':
          errorMessage = "Format email tidak valid";
          break;
        case 'invalid-credential':
          errorMessage = "Email atau password salah";
          break;
        case 'user-disabled':
          errorMessage = "Akun telah dinonaktifkan";
          break;
        case 'too-many-requests':
          errorMessage = "Terlalu banyak percobaan login. Coba lagi nanti";
          break;
        case 'network-request-failed':
          errorMessage = "Tidak ada koneksi internet";
          break;
        default:
          errorMessage = e.message ?? "Terjadi kesalahan pada Auth";
      }
      throw errorMessage;
    } catch (e) {
      debugPrint("Error Login: $e");
      throw "Terjadi kesalahan sistem";
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        Users newUser = Users(
          idUser: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        await _db.collection('users').doc(user.uid).set(newUser.toJson());

        return user;
      }
    } catch (e) {
      debugPrint("Error Register: $e");
      return null;
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
