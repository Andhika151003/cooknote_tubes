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
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
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
        final docData = snapshot.data!.data() as Map<String, dynamic>;
        docData['id_Recipes'] = snapshot.data!.id; // Pastikan ID terbawa

        // Buat objek resep baru yang datanya paling fresh
        final liveRecipe = Recipes.fromJson(docData);

        // Cek apakah user yang login adalah pemilik resep ini
        final bool isOwner = controller.isOwner(liveRecipe.idUser);

        // --- LOGIKA SMART DISPLAY KATEGORI ---
        String displayKategori = liveRecipe.categoryName ?? '-';
        if (displayKategori == 'Umum' || displayKategori.isEmpty) {
          displayKategori = liveRecipe.categoriesId;
        }

        return Scaffold(
          backgroundColor: Colors.white,

          // FAB (Edit & Delete) - Hanya muncul jika pemilik
          floatingActionButton: isOwner
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'edit_btn',
                      backgroundColor: const Color(0xFF4CAF50),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditView(recipe: liveRecipe),
                          ),
                        );
                      },
                      child: const Icon(Icons.edit, color: Colors.black),
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
                backgroundColor: const Color(0xFF4CAF50),
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
                      // Judul Resep
                      Text(
                        liveRecipe.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Kategori (Posisi di bawah Judul)
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            displayKategori,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 40),

                      // Info Row (Waktu & Kesulitan)
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

                      // --- BAHAN - BAHAN (Tampilan Baru) ---
                      _buildTitle("Bahan - Bahan"),
                      const SizedBox(height: 12),
                      _buildStepList(liveRecipe.bahan),

                      const SizedBox(height: 25),

                      // --- LANGKAH - LANGKAH (Tampilan Baru) ---
                      _buildTitle("Langkah - Langkah"),
                      const SizedBox(height: 12),
                      _buildStepList(liveRecipe.langkah),

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
          Icon(icon, color: const Color(0xFF4CAF50)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // [BARU] Widget untuk membuat daftar langkah/bahan yang rapi
  Widget _buildStepList(String rawText) {
    // 1. Pecah teks berdasarkan Enter (\n)
    List<String> items = rawText.split('\n');

    // 2. Hapus baris kosong (jika ada user yang enter 2x)
    items = items.where((item) => item.trim().isNotEmpty).toList();

    if (items.isEmpty) {
      return const Text("-", style: TextStyle(color: Colors.grey));
    }

    // 3. Tampilkan sebagai List
    return Column(
      children: List.generate(items.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lingkaran Nomer
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), // Warna oranye tema
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Kotak Teks (Mirip TextField)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // Background agak abu terang
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ), // Garis tepi halus
                  ),
                  child: Text(
                    items[index].trim(),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
