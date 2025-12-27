import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipes_model.dart';
import 'package:flutter/foundation.dart';

class RecipesServices {
  // Referensi ke koleksi 'recipes'
  final CollectionReference _recipeCollection = FirebaseFirestore.instance
      .collection('recipes');

  // Referensi tambahan untuk mengambil data User dan Kategori
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference _categoryCollection = FirebaseFirestore.instance
      .collection('categories');

  // 1. GET RECIPES (Tetap sama, tidak perlu ubah)
  Stream<List<Recipes>> getRecipes() {
    return _recipeCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id_Recipes'] = doc.id;
        return Recipes.fromJson(data);
      }).toList();
    });
  }

  // 2. TAMBAH RESEP BARU (INI YANG KITA PERBAIKI)
  // Logika: Ambil ID -> Cari Namanya di tabel lain -> Gabungkan -> Simpan
  Future<void> addRecipe(Recipes recipe) async {
    try {
      // A. Ambil Nama User dari tabel 'users' berdasarkan user_Id
      DocumentSnapshot userDoc = await _userCollection.doc(recipe.userId).get();
      String namaUser = userDoc.exists
          ? (userDoc.data() as Map)['name']
          : 'Unknown User';

      // B. Ambil Nama Kategori dari tabel 'categories' berdasarkan categories_Id
      DocumentSnapshot catDoc = await _categoryCollection
          .doc(recipe.categoriesId)
          .get();
      String namaKategori = catDoc.exists
          ? (catDoc.data() as Map)['name']
          : 'Umum';

      // C. Siapkan data gabungan
      // Kita ambil JSON asli dari model, lalu tambahkan field nama secara manual
      Map<String, dynamic> dataSimpan = recipe.toJson();
      dataSimpan['user_name'] = namaUser; // Menambah field baru
      dataSimpan['category_name'] = namaKategori; // Menambah field baru

      // D. Simpan data lengkap ke Firestore
      await _recipeCollection.add(dataSimpan);
    } catch (e) {
      debugPrint("Error tambah resep: $e");
      rethrow;
    }
  }

  // 3. EDIT / UPDATE Resep (Kita perbaiki juga agar nama kategori ikut update)
  Future<void> updateRecipe(Recipes recipe) async {
    try {
      // Kita cek lagi nama kategorinya, takutnya user mengubah kategori resep
      DocumentSnapshot catDoc = await _categoryCollection
          .doc(recipe.categoriesId)
          .get();
      String namaKategori = catDoc.exists
          ? (catDoc.data() as Map)['name']
          : 'Umum';

      Map<String, dynamic> dataUpdate = recipe.toJson();
      dataUpdate['category_name'] = namaKategori; // Update namanya juga

      await _recipeCollection.doc(recipe.idRecipes).update(dataUpdate);
    } catch (e) {
      debugPrint("Error update resep: $e");
      rethrow;
    }
  }

  // 4. HAPUS RESEP (Tetap sama)
  Future<void> deleteRecipe(Recipes recipe) async {
    try {
      await _recipeCollection.doc(recipe.idRecipes).delete();
    } catch (e) {
      debugPrint("Error delete resep: $e");
      rethrow;
    }
  }
}
