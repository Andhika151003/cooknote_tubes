//Andhika
import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String idUser;
  final String name;
  final String email;
  final DateTime createdAt;

  Users({
    required this.idUser,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      idUser: json['id_User'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
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
      'createdAt': createdAt,
    };
  }
}
