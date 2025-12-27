//Andhika

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categories_model.dart';
import 'package:flutter/foundation.dart';

class CategoriesServices {
  final CollectionReference _categoryCollection = FirebaseFirestore.instance
      .collection('categories');

  // 1. GET ALL CATEGORIES (Stream)
  // Dipakai untuk menampilkan list kategori di DropdownMenu atau Filter
  Stream<List<Categories>> getCategories() {
    return _categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        data['id'] = doc.id;

        return Categories.fromJson(data);
      }).toList();
    });
  }

  // 2. TAMBAH KATEGORI (Manual)
  Future<void> addCategory(String namaKategori) async {
    try {
      await _categoryCollection.add({
        'name': namaKategori,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error tambah kategori: $e");
      rethrow;
    }
  }

  // 3. AUTO-GENERATE KATEGORI (Fitur Spesial)
  Future<void> initDefaultCategories() async {
    try {
      var snapshot = await _categoryCollection.limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint("Database kategori kosong, membuat data default...");

        List<String> defaults = ["Breakfast", "Lunch", "Dinner", "Favorite"];

        for (String cat in defaults) {
          await _categoryCollection.add({
            'name': cat,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
        debugPrint("Selesai membuat kategori default!");
      } else {
        debugPrint("Kategori sudah ada, tidak perlu generate ulang.");
      }
    } catch (e) {
      debugPrint("Error init kategori: $e");
    }
  }
}
