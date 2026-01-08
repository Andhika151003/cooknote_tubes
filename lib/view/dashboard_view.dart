// Tera(Membuat tampilan dashboard)
// Andhika(Menyambungkan kedalam controller)
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // --- FUNGSI UTAMA: MENAMPILKAN DAFTAR RESEP ---
  Widget _buildRecipeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              "Masak apa hari ini?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recipes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Saat Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Jika Error
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // 3. Jika Data Kosong
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada resep. Yuk tambah!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // 4. Jika Data Ada -> Tampilkan Grid
                final dataDocs = snapshot.data!.docs;

                return GridView.builder(
                  itemCount: dataDocs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    // AMBIL ID DOKUMEN AGAR BISA DIHAPUS/EDIT
                    // Kita gunakan Map.from agar aman memodifikasi data
                    final docData = Map<String, dynamic>.from(
                      dataDocs[index].data() as Map<String, dynamic>,
                    );

                    docData['id_Recipes'] = dataDocs[index].id;

                    final recipe = Recipes.fromJson(docData);

                    return GestureDetector(
                      onTap: () {
                        // [PERBAIKAN UTAMA DI SINI]
                        // Kita pasang Provider di sini agar DetailView tidak error
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
                                        // Tampilan jika URL kosong
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
      ),
    );
  }
}
