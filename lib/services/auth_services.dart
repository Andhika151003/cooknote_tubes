// Andhika
import 'package:firebase_auth/firebase_auth.dart';
import '../models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan User dari Firebase Auth
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fungsi untuk mendapatkan data profil lengkap dari Firestore
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
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Lempar error spesifik agar bisa ditangkap Controller
      throw e.message ?? "Terjadi kesalahan pada Auth";
    } catch (e) {
      throw "Terjadi kesalahan sistem";
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      // 1. Buat akun di Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 2. Buat objek model (Tanpa menyimpan password ke Firestore)
        Users newUser = Users(
          idUser: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        // 3. Simpan ke koleksi 'users' dengan ID Dokumen = UID User
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
