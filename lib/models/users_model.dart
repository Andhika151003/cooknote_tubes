// === Andhika ===
import 'package:cloud_firestore/cloud_firestore.dart';

//Atribut data
class Users {
  final String idUser;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;

  //Konstruktor
  Users({
    required this.idUser,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  //Method
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      idUser: json['id_User'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_User': idUser,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt,
    };
  }
}
