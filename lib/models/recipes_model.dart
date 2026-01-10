import 'package:cloud_firestore/cloud_firestore.dart';

class Recipes {
  final String idRecipes;
  final String idUser;
  final String title;
  final String categoriesId;
  final String bahan;
  final String langkah;
  final String waktu;
  final String kesulitan;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime uploadedAt;
  final String? userName;
  final String? categoryName;

  Recipes({
    required this.idRecipes,
    required this.idUser,
    required this.title,
    required this.categoriesId,
    required this.bahan,
    required this.langkah,
    required this.waktu,
    required this.kesulitan,
    required this.imageUrl,
    required this.createdAt,
    required this.uploadedAt,
    this.userName,
    this.categoryName,
  });

  factory Recipes.fromJson(Map<String, dynamic> json) {
    return Recipes(
      idRecipes: json['id_Recipes'] ?? '',
      // KITA SAMAKAN SEMUA KEY:
      idUser: json['id_User'] ?? '', // Huruf kecil semua & snake_case
      title: json['title'] ?? 'Tanpa Judul',
      categoriesId: json['categoriesId'] ?? '',
      bahan: json['bahan'] ?? '',
      langkah: json['langkah'] ?? '',
      waktu: json['waktu'] ?? '-',
      kesulitan: json['kesulitan'] ?? 'Sedang',
      imageUrl: json['imageUrl'] ?? '', // Gunakan camelCase (sesuai toJson)

      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      uploadedAt: json['uploadedAt'] is Timestamp
          ? (json['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),
      userName: json['user_name'] ?? 'User',
      categoryName: json['category_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_Recipes': idRecipes,
      'id_User': idUser, // Konsisten: id_User
      'title': title,
      'categoriesId': categoriesId,
      'bahan': bahan,
      'langkah': langkah,
      'waktu': waktu,
      'kesulitan': kesulitan,
      'imageUrl': imageUrl, // Konsisten: imageUrl
      'createdAt': createdAt,
      'uploadedAt': uploadedAt,
      'user_name': userName,
      'category_name': categoryName,
    };
  }
}
