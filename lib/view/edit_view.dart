// Andhika

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipes_model.dart';
import '../controller/edit_controller.dart';

const Color primaryGreen = Color(0xFF4CAF50);

class EditView extends StatefulWidget {
  final Recipes recipe;

  const EditView({super.key, required this.recipe});

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final EditRecipeController _controller = EditRecipeController();

  final List<String> categories = ["Breakfast", "Lunch", "Dinner", "Favorite"];
  // [BARU] Daftar pilihan kesulitan
  final List<String> difficulties = ["Mudah", "Sedang", "Sulit"];

  @override
  void initState() {
    super.initState();
    _controller.loadExistingData(widget.recipe);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() async {
    bool success = await _controller.updateRecipe(
      widget.recipe.idRecipes,
      widget.recipe.idUser,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resep berhasil diperbarui!")),
      );
    } else if (_controller.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Resep"),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              "Simpan",
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR ---
            GestureDetector(
              onTap: () => _controller.pickImage(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_controller.newImageFile != null)
                      Image.file(_controller.newImageFile!, fit: BoxFit.cover)
                    else if (_controller.oldImageUrl != null &&
                        _controller.oldImageUrl!.isNotEmpty)
                      Image.network(
                        _controller.oldImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    else
                      const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- NAMA RESEP ---
            _input("Nama Resep", _controller.titleController),
            const SizedBox(height: 8),

            // --- KATEGORI ---
            const Text(
              "Kategori",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                final isSelected = _controller.selectedCategoryId == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: primaryGreen,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (bool selected) {
                    if (selected) _controller.setCategory(cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- [BARU] TINGKAT KESULITAN ---
            const Text(
              "Tingkat Kesulitan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: difficulties.map((diff) {
                final isSelected = _controller.selectedDifficulty == diff;
                return ChoiceChip(
                  label: Text(diff),
                  selected: isSelected,
                  selectedColor: primaryGreen,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (bool selected) {
                    if (selected) _controller.setDifficulty(diff);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- WAKTU ---
            _input("Waktu (contoh: 20 min)", _controller.waktuController),
            const SizedBox(height: 12),

            // --- BAHAN ---
            const Text(
              "Bahan - Bahan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller.bahanController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Masukkan bahan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // --- LANGKAH ---
            const Text(
              "Langkah - Langkah",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller.langkahController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Masukkan langkah pembuatan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
