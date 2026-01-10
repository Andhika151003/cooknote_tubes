// Andhika
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger flow autentikasi
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User batal login

      // Dapatkan detail otentikasi
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Buat kredensial baru
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // Simpan data user ke Firestore jika belum ada (Auto-Register)
      if (user != null) {
        DocumentSnapshot doc = await _db
            .collection('users')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          Users newUser = Users(
            idUser: user.uid,
            name: user.displayName ?? "No Name",
            email: user.email ?? "No Email",
            createdAt: DateTime.now(),
          );
          await _db.collection('users').doc(user.uid).set(newUser.toJson());
        }
      }
      return user;
    } catch (e) {
      debugPrint("Error Google Sign In: $e");
      return null;
    }
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
    await _googleSignIn.signOut();
  }
}
