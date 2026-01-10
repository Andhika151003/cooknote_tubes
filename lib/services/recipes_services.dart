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

  Future<String> _getCategoryNameSmart(String categoryInput) async {
    if (categoryInput.isEmpty) return 'Umum';

    try {
      DocumentSnapshot catDoc = await _categoryCollection
          .doc(categoryInput)
          .get();
      if (catDoc.exists) {
        return (catDoc.data() as Map)['name'] ?? 'Umum';
      }

      QuerySnapshot query = await _categoryCollection
          .where('name', isEqualTo: categoryInput)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return (query.docs.first.data() as Map)['name'];
      }

      return categoryInput;
    } catch (e) {
      debugPrint("Gagal fetch kategori: $e");
      return categoryInput;
    }
  }

  // 2. TAMBAH RESEP BARU
  Future<void> addRecipe(Recipes recipe) async {
    try {
      DocumentSnapshot userDoc = await _userCollection.doc(recipe.idUser).get();
      String namaUser = userDoc.exists
          ? (userDoc.data() as Map)['name']
          : 'Unknown User';
      String namaKategori = await _getCategoryNameSmart(recipe.categoriesId);

      DocumentReference docRef = _recipeCollection.doc();

      Map<String, dynamic> dataSimpan = recipe.toJson();
      dataSimpan['id_Recipes'] = docRef.id;
      dataSimpan['user_name'] = namaUser;
      dataSimpan['category_name'] = namaKategori;

      await docRef.set(dataSimpan);
    } catch (e) {
      debugPrint("Error tambah resep: $e");
      rethrow;
    }
  }

  // 3. EDIT / UPDATE Resep
  Future<void> updateRecipe(Recipes recipe) async {
    try {
      String namaKategori = await _getCategoryNameSmart(recipe.categoriesId);

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
