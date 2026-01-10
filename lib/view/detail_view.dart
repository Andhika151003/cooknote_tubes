// tera

import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib ada untuk StreamBuilder
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipes_model.dart';
import '../controller/detail_controller.dart';
import 'edit_view.dart';

class DetailView extends StatelessWidget {
  final Recipes recipe;

  const DetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Ambil controller
    final controller = Provider.of<DetailRecipeController>(context);

    // [PENTING] Gunakan StreamBuilder agar tampilan selalu update otomatis
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipe.idRecipes)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Tampilan saat Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8A00)),
            ),
          );
        }

        // 2. Tampilan jika Data Terhapus / Tidak Ditemukan
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text("Detail Resep")),
            body: const Center(child: Text("Resep ini telah dihapus.")),
          );
        }

        // 3. KONVERSI DATA TERBARU (LIVE)
        // Kita abaikan data lama 'recipe', kita pakai data baru dari snapshot
        final docData = snapshot.data!.data() as Map<String, dynamic>;
        docData['id_Recipes'] = snapshot.data!.id; // Pastikan ID terbawa

        // Buat objek resep baru yang datanya paling fresh
        final liveRecipe = Recipes.fromJson(docData);

        // Cek apakah user yang login adalah pemilik resep ini
        final bool isOwner = controller.isOwner(liveRecipe.idUser);

        return Scaffold(
          backgroundColor: Colors.white,

          // FAB (Edit & Delete) - Hanya muncul jika pemilik
          floatingActionButton: isOwner
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'edit_btn',
                      backgroundColor: const Color(0xFFFF8A00),
                      onPressed: () {
                        // Buka halaman Edit dengan data terbaru (liveRecipe)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditView(recipe: liveRecipe),
                          ),
                        );
                      },
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'delete_btn',
                      backgroundColor: Colors.red,
                      onPressed: () => _showDeleteConfirmation(
                        context,
                        controller,
                        liveRecipe,
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ],
                )
              : null,

          body: CustomScrollView(
            slivers: [
              // --- GAMBAR HEADER ---
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFFFF8A00),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: const BackButton(color: Colors.white),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    liveRecipe.imageUrl.isNotEmpty
                        ? liveRecipe.imageUrl
                        : "https://via.placeholder.com/300",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              ),

              // --- KONTEN DETAIL ---
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        liveRecipe.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nama Pembuat
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "oleh: ${liveRecipe.userName ?? 'User'}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 40),

                      // Info Waktu & Kesulitan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoTile(
                            Icons.access_time,
                            "Waktu",
                            liveRecipe.waktu,
                          ),
                          _buildInfoTile(
                            Icons.restaurant_menu,
                            "Kesulitan",
                            liveRecipe.kesulitan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Bahan
                      _buildTitle("Bahan - Bahan"),
                      const SizedBox(height: 12),
                      _buildContentBox(liveRecipe.bahan),

                      const SizedBox(height: 25),

                      // Langkah
                      _buildTitle("Langkah - Langkah"),
                      const SizedBox(height: 12),
                      _buildContentBox(liveRecipe.langkah),

                      const SizedBox(
                        height: 100,
                      ), // Spasi bawah agar tidak tertutup FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF8A00)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContentBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
    );
  }

  // Dialog Konfirmasi Hapus
  void _showDeleteConfirmation(
    BuildContext context,
    DetailRecipeController controller,
    Recipes recipeToDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Resep?"),
        content: const Text("Tindakan ini tidak bisa dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              // Hapus resep
              bool ok = await controller.deleteRecipe(recipeToDelete);
              if (ok && context.mounted) {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context); // Kembali ke Dashboard
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
