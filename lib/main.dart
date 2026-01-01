import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahan import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'services/auth_services.dart';
import 'services/recipes_services.dart';
import 'services/categories_services.dart';
import 'models/recipes_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cooknote Relasi Fix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final AuthServices _authServices = AuthServices();
  final RecipesServices _recipesServices = RecipesServices();
  final CategoriesServices _categoriesServices = CategoriesServices();

  User? _currentUser;
  String _statusLog = "Siap.";
  bool _isLoading = false;

  // VAR PENTING: Untuk menyimpan ID asli dari Firestore (Foreign Key)
  String? _realCategoryId;
  String? _realCategoryName;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() => _currentUser = user);
    });
  }

  // 1. LOGIN
  Future<void> _runLogin() async {
    setState(() {
      _isLoading = true;
      _statusLog = "Sedang Login...";
    });

    // Login user dummy
    User? user = await _authServices.login(
      "test_user01@example.com",
      "password123",
    );
    if (user == null) {
      user = await _authServices.register(
        "User Relasi",
        "test_user01@example.com",
        "password123",
      );
    }

    setState(() {
      _isLoading = false;
      _statusLog = user != null ? "Login OK: ${user.email}" : "Login Gagal.";
    });
  }

  // 2. INIT & AMBIL ID KATEGORI (SOLUSI MASALAH ANDA)
  Future<void> _runInitAndFetchCategory() async {
    setState(() {
      _isLoading = true;
      _statusLog = "Mencari Kategori...";
    });

    try {
      // a. Pastikan kategori dibuat dulu
      await _categoriesServices.initDefaultCategories();

      // b. AMBIL SATU KATEGORI DARI DATABASE (Fetch Real ID)
      //    Kita cari kategori yg namanya 'Lunch' atau ambil yg pertama aja
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Ambil dokumen pertama sebagai contoh relasi
        var doc = snapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          // INI DIA FOREIGN KEY YANG ASLI
          _realCategoryId = doc.id;
          _realCategoryName = data['name'];

          _statusLog =
              "RELASI DITEMUKAN!\n\n"
              "Nama Kategori: $_realCategoryName\n"
              "ID Kategori (Foreign Key): $_realCategoryId\n\n"
              "Siap dipakai untuk input resep.";
        });
      } else {
        setState(
          () => _statusLog = "Aneh, kategori kosong padahal sudah di-init.",
        );
      }
    } catch (e) {
      setState(() => _statusLog = "Error Fetch Kategori: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. INPUT RESEP DENGAN RELASI YANG BENAR
  Future<void> _runInputData() async {
    if (_currentUser == null) {
      setState(() => _statusLog = "Belum Login!");
      return;
    }
    if (_realCategoryId == null) {
      setState(
        () => _statusLog = "STOP: Klik tombol 2 dulu untuk ambil ID Kategori.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusLog = "Menyimpan Resep...";
    });

    try {
      Recipes dummyRecipe = Recipes(
        idRecipes: "",
        idUser: _currentUser!.uid, // Foreign Key ke User (Otomatis dari Auth)
        title: "Sate Padang Relasi Valid",

        // DISINI KUNCINYA: Pakai ID asli yang kita ambil tadi
        categoriesId: _realCategoryId!,

        bahan: "Daging Sapi, Tepung Beras",
        langkah: "1. Bakar sate. 2. Siram kuah.",
        waktu: "45 Menit",
        kesulitan: "Sulit",
        imageUrl: "https://via.placeholder.com/150",
        createdAt: DateTime.now(),
        uploadedAt: DateTime.now(),
      );

      await _recipesServices.addRecipe(dummyRecipe);

      setState(
        () => _statusLog =
            "SUKSES SEMPURNA!\n"
            "Resep tersimpan dengan Relasi Foreign Key yang benar.\n\n"
            "Cek Firestore:\n"
            "1. categories_Id: $_realCategoryId\n"
            "2. category_name: $_realCategoryName (Bukan 'Umum' lagi)",
      );
    } catch (e) {
      setState(() => _statusLog = "Error Input: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLogin = _currentUser != null;
    bool isCategoryReady = _realCategoryId != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Test Relasi Foreign Key")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Box
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey[200],
              height: 150,
              child: SingleChildScrollView(child: Text(_statusLog)),
            ),
            const SizedBox(height: 20),

            // Tombol 1
            ElevatedButton(
              onPressed: _isLoading ? null : _runLogin,
              child: Text(isLogin ? "Sudah Login" : "1. Login User"),
            ),

            // Tombol 2
            ElevatedButton(
              onPressed: _isLoading ? null : _runInitAndFetchCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCategoryReady ? Colors.green[100] : null,
              ),
              child: const Text("2. Ambil ID Kategori Asli (Foreign Key)"),
            ),

            // Tombol 3
            ElevatedButton(
              onPressed: (_isLoading || !isCategoryReady)
                  ? null
                  : _runInputData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text("3. INPUT RESEP (Valid Relation)"),
            ),
          ],
        ),
      ),
    );
  }
}
