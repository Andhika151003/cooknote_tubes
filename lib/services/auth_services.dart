import 'package:firebase_auth/firebase_auth.dart';
import '../models/usersModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //fungsi login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  //fungsi register
  Future<User?> register(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      //sinkronasi dari model user
      if (user != null) {
        Users newUser = Users(
          idUser: user.uid,
          name: name,
          email: email,
          password: password,
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(user.uid).set(newUser.toJson());

        return user;
      }
    } catch (e) {
      print("Error Register: $e");
      return null;
    }
    return null;
  }
}
