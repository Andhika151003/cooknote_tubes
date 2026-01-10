// Tera(Membuat tampilan dashboard)
// Andhika(Menyambungkan kedalam controller)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipes_model.dart';
import '../controller/navigation_controller.dart';
import '../controller/detail_controller.dart';
import 'detail_view.dart';
import 'tambah_view.dart';
import 'profile_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final NavigationController _navController = NavigationController();

  // [BARU] Variabel untuk Filter Kategori
  // Default 'Semua' agar muncul semua di awal
  String selectedCategory = "Semua";

  // Daftar kategori yang tersedia (Pastikan sama dengan di Tambah/Edit)
  final List<String> categories = [
    "Semua",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Favorite",
  ];

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,

          // AppBar
          appBar: _navController.selectedIndex == 0
              ? AppBar(
                  title: const Text(
                    "Beranda Resep",
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                )
              : null,

          body: _navController.selectedIndex == 0
              ? _buildRecipeList()
              : const ProfileView(),

          floatingActionButton: _navController.selectedIndex == 0
              ? FloatingActionButton(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TambahView()),
                    );
                  },
                )
              : null,

          // Bottom Navigation
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _navController.selectedIndex,
            selectedItemColor: Colors.green,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
            onTap: (index) {
              _navController.changePage(index);
            },
          ),
        );
      },
    );
  }

  // --- WIDGET PILIHAN KATEGORI [BARU] ---
  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: Colors.green, // Warna saat dipilih
              backgroundColor: Colors.grey[100], // Warna saat tidak dipilih
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              // Hilangkan border default agar lebih bersih
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.green : Colors.transparent,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    selectedCategory = category;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- FUNGSI UTAMA: MENAMPILKAN DAFTAR RESEP ---
  Widget _buildRecipeList() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Silakan login terlebih dahulu"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Masak apa hari ini?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        // [BARU] Masukkan Widget Kategori di sini
        _buildCategorySelector(),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('recipes')
                .where('id_User', isEqualTo: user.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // Ambil semua dokumen
              var dataDocs = snapshot.data?.docs ?? [];

              // [LOGIKA FILTER CLIENT-SIDE]
              // Jika kategori bukan "Semua", kita saring datanya di sini
              if (selectedCategory != "Semua") {
                dataDocs = dataDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Pastikan field 'categoriesId' sama dengan yang dipilih
                  // Gunakan .toString() untuk jaga-jaga
                  return data['categoriesId'] == selectedCategory;
                }).toList();
              }

              // Jika Data Kosong (Setelah difilter atau memang kosong)
              if (dataDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedCategory == "Semua"
                            ? "Belum ada resep."
                            : "Tidak ada resep $selectedCategory.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dataDocs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final docData = Map<String, dynamic>.from(
                    dataDocs[index].data() as Map<String, dynamic>,
                  );

                  docData['id_Recipes'] = dataDocs[index].id;

                  final recipe = Recipes.fromJson(docData);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => DetailRecipeController(),
                            child: DetailView(recipe: recipe),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar Resep
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: recipe.imageUrl.isNotEmpty
                                  ? Image.network(
                                      recipe.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                progress.expectedTotalBytes !=
                                                    null
                                                ? progress.cumulativeBytesLoaded /
                                                      progress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          // Judul & Kategori
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe.waktu,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
