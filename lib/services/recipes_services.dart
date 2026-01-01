//Andhika

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipes_model.dart';
import 'package:flutter/foundation.dart';

class RecipesServices {
  // Referensi ke koleksi 'recipes'
  final CollectionReference _recipeCollection = FirebaseFirestore.instance
      .collection('recipes');
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference _categoryCollection = FirebaseFirestore.instance
      .collection('categories');

  // 1. GET RECIPES
  Stream<List<Recipes>> getRecipes() {
    return _recipeCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id_Recipes'] = doc.id;
        return Recipes.fromJson(data);
      }).toList();
    });
  }

  // 2. TAMBAH RESEP BARU
  Future<void> addRecipe(Recipes recipe) async {
    try {
      // A. Ambil Nama User
      DocumentSnapshot userDoc = await _userCollection.doc(recipe.idUser).get();
      String namaUser = userDoc.exists
          ? (userDoc.data() as Map)['name']
          : 'Unknown User';

      // B. Ambil Nama Kategori
      DocumentSnapshot catDoc = await _categoryCollection
          .doc(recipe.categoriesId)
          .get();
      String namaKategori = catDoc.exists
          ? (catDoc.data() as Map)['name']
          : 'Umum';

      // --- PERUBAHAN UTAMA DI SINI ---

      // 1. Buat referensi dokumen baru (Pesan ID kosong dulu)
      DocumentReference docRef = _recipeCollection.doc();

      // 2. Siapkan data, dan masukkan ID yang barusan dibuat ke dalam field 'id_Recipes'
      Map<String, dynamic> dataSimpan = recipe.toJson();
      dataSimpan['id_Recipes'] = docRef.id; // <--- INI KUNCINYA
      dataSimpan['user_name'] = namaUser;
      dataSimpan['category_name'] = namaKategori;

      // 3. Simpan data menggunakan .set() bukan .add()
      await docRef.set(dataSimpan);
    } catch (e) {
      debugPrint("Error tambah resep: $e");
      rethrow;
    }
  }

  // 3. EDIT / UPDATE Resep
  Future<void> updateRecipe(Recipes recipe) async {
    try {
      DocumentSnapshot catDoc = await _categoryCollection
          .doc(recipe.categoriesId)
          .get();
      String namaKategori = catDoc.exists
          ? (catDoc.data() as Map)['name']
          : 'Umum';

      Map<String, dynamic> dataUpdate = recipe.toJson();
      dataUpdate['category_name'] = namaKategori;

      await _recipeCollection.doc(recipe.idRecipes).update(dataUpdate);
    } catch (e) {
      debugPrint("Error update resep: $e");
      rethrow;
    }
  }

  // 4. HAPUS RESEP
  Future<void> deleteRecipe(Recipes recipe) async {
    try {
      await _recipeCollection.doc(recipe.idRecipes).delete();
    } catch (e) {
      debugPrint("Error delete resep: $e");
      rethrow;
    }
  }
}
