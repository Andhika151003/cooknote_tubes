//tera

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
    final controller = Provider.of<DetailRecipeController>(context);
    final bool isOwner = controller.isOwner(recipe.idUser);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isOwner 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'edit_btn',
                  backgroundColor: const Color(0xFFFF8A00),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditView(recipe: recipe)),
                    );
                  },
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'delete_btn',
                  backgroundColor: Colors.red,
                  onPressed: () => _showDeleteConfirmation(context, controller),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              ],
            )
          : null,
      body: CustomScrollView(
        slivers: [
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
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
          ),

          //Konten Detail Resep//
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("oleh: ${recipe.userName ?? 'User'}", 
                           style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const Divider(height: 40),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoTile(Icons.access_time, "Waktu", recipe.waktu),
                      _buildInfoTile(Icons.restaurant_menu, "Kesulitan", recipe.kesulitan),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildTitle("Bahan - Bahan"),
                  const SizedBox(height: 12),
                  _buildContentBox(recipe.bahan),

                  const SizedBox(height: 25),

                  _buildTitle("Langkah - Langkah"),
                  const SizedBox(height: 12),
                  _buildContentBox(recipe.langkah),
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: Color.fromARGB(255, 0, 0, 0)
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

  void _showDeleteConfirmation(BuildContext context, DetailRecipeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Resep?"),
        content: const Text("Tindakan ini tidak bisa dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              bool ok = await controller.deleteRecipe(recipe);
              if (ok && context.mounted) {
                Navigator.pop(context); 
                Navigator.pop(context); 
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}