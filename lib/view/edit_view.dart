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

  // [BARU] List Controller untuk menangani input dinamis
  List<TextEditingController> ingredientsCtrls = [];
  List<TextEditingController> stepsCtrls = [];

  final List<String> categories = ["Breakfast", "Lunch", "Dinner", "Favorite"];
  final List<String> difficulties = ["Mudah", "Sedang", "Sulit"];

  @override
  void initState() {
    super.initState();
    // 1. Load data dasar (Judul, Waktu, Gambar, Kategori)
    _controller.loadExistingData(widget.recipe);

    // 2. [BARU] Load & Pecah data Bahan menjadi list controller
    _initListFromText(widget.recipe.bahan, ingredientsCtrls);

    // 3. [BARU] Load & Pecah data Langkah menjadi list controller
    _initListFromText(widget.recipe.langkah, stepsCtrls);

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  // Helper untuk memecah teks database (\n) menjadi List Controller
  void _initListFromText(String content, List<TextEditingController> list) {
    if (content.isEmpty) {
      list.add(TextEditingController());
    } else {
      List<String> splitData = content.split('\n');
      for (var item in splitData) {
        if (item.trim().isNotEmpty) {
          list.add(TextEditingController(text: item.trim()));
        }
      }
      // Jaga-jaga jika hasil split kosong semua
      if (list.isEmpty) list.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Bersihkan controller list manual
    for (var c in ingredientsCtrls) c.dispose();
    for (var c in stepsCtrls) c.dispose();
    super.dispose();
  }

  void _handleSave() async {
    // 1. [BARU] Gabungkan List Controller kembali menjadi String
    String joinedBahan = ingredientsCtrls
        .map((e) => e.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');

    String joinedLangkah = stepsCtrls
        .map((e) => e.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');

    // 2. Masukkan ke controller utama sebelum update
    _controller.bahanController.text = joinedBahan;
    _controller.langkahController.text = joinedLangkah;

    // 3. Jalankan proses update
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

            // --- TINGKAT KESULITAN ---
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
            const SizedBox(height: 20),

            // --- BAHAN (DYNAMIC LIST) ---
            const Text(
              "Bahan - Bahan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            ..._dynamicList(ingredientsCtrls, "Tambah Bahan"),

            const SizedBox(height: 24),

            // --- LANGKAH (DYNAMIC LIST) ---
            const Text(
              "Langkah - Langkah",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            ..._dynamicList(stepsCtrls, "Tambah Langkah"),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

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

  // [BARU] Widget untuk Input Dinamis (Sama seperti TambahView)
  List<Widget> _dynamicList(
    List<TextEditingController> list,
    String buttonLabel,
  ) {
    return [
      ...list.asMap().entries.map(
        (e) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 8),
                child: Text(
                  "${e.key + 1}.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: e.value,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Tulis disini...",
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // Tombol Hapus (Merah)
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  if (list.length > 1) {
                    setState(() => list.removeAt(e.key));
                  } else {
                    e.value.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Minimal harus ada satu baris data"),
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),

      // Tombol Tambah Baris Baru
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextButton.icon(
          onPressed: () {
            setState(() => list.add(TextEditingController()));
          },
          icon: const Icon(Icons.add_circle_outline, color: primaryGreen),
          label: Text(
            buttonLabel,
            style: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ];
  }
}
