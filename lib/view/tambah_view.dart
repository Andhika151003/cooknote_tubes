//Tera(yang membuat ui)
//Andhika(yang menyambungkan ke database)

import 'dart:io';
import 'package:flutter/material.dart';
import '../controller/tambah_controller.dart';

const Color primaryGreen = Color(0xFF4CAF50);

class TambahView extends StatefulWidget {
  const TambahView({super.key});

  @override
  State<TambahView> createState() => _TambahViewState();
}

class _TambahViewState extends State<TambahView> {
  final AddRecipeController _controller = AddRecipeController();
  List<TextEditingController> ingredientsCtrls = [];
  List<TextEditingController> stepsCtrls = [];

  @override
  void initState() {
    super.initState();
    ingredientsCtrls.add(TextEditingController());
    stepsCtrls.add(TextEditingController());
  }

  @override
  void dispose() {
    _controller.dispose();

    for (var c in ingredientsCtrls) c.dispose();
    for (var c in stepsCtrls) c.dispose();

    super.dispose();
  }

  void _handleSave() async {
    if (_controller.imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap masukkan foto resep terlebih dahulu"),
        ),
      );
      return;
    }

    String bahanString = ingredientsCtrls
        .map((e) => e.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');

    String langkahString = stepsCtrls
        .map((e) => e.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');

    _controller.bahanController.text = bahanString;
    _controller.langkahController.text = langkahString;

    final success = await _controller.saveRecipe();

    if (mounted) {
      // Cek widget aktif di layar
      if (success) {
        // Jika sukses, kembali ke dashboard
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resep berhasil disimpan!")),
        );
      } else {
        // Jika gagal, tampilkan pesan error dari controller
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage ?? "Gagal menyimpan data"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            title: const Text("Tambah Resep"),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Tombol Simpan
              TextButton(
                onPressed: _controller.isLoading ? null : _handleSave,
                child: _controller.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
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
                GestureDetector(
                  onTap: () => _controller.pickImage(),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      // Jika gambar sudah dipilih, tampil sebagai background
                      image: _controller.imageFile != null
                          ? DecorationImage(
                              image: FileImage(_controller.imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    // Jika belum ada gambar, tampil ikon kamera
                    child: _controller.imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Ketuk untuk upload foto masakan",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 24),
                _input("Nama Resep", _controller.titleController),

                const SizedBox(height: 16),

                // Pilihan: Kategori
                const Text(
                  "Kategori",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _chipGroup(
                  ["Breakfast", "Lunch", "Dinner", "Favorite"],
                  _controller.selectedCategory,
                  (val) => _controller.setCategory(val),
                ),

                const SizedBox(height: 16),

                // Pilihan: Kesulitan
                const Text(
                  "Tingkat Kesulitan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _chipGroup(
                  ["Mudah", "Sedang", "Sulit"],
                  _controller.selectedDifficulty,
                  (val) => _controller.setDifficulty(val),
                ),

                const SizedBox(height: 16),

                // Input: Waktu Memasak
                _input(
                  "Estimasi Waktu (contoh: 30 menit)",
                  _controller.waktuController,
                ),

                const SizedBox(height: 24),

                // Input Dinamis: Bahan-bahan
                const Text(
                  "Bahan - Bahan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // const Text(
                //   "Masukkan bahan satu per satu",
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                ..._dynamicList(ingredientsCtrls, "Tambah Bahan"),

                const SizedBox(height: 24),

                // Input Dinamis: Langkah-langkah
                const Text(
                  "Langkah Memasak",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // const Text(
                //   "Jelaskan langkah demi langkah",
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                ..._dynamicList(stepsCtrls, "Tambah Langkah"),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER ---

  // Helper untuk TextField biasa
  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Helper untuk ChoiceChip (Pilihan Kategori/Kesulitan)
  Widget _chipGroup(
    List<String> items,
    String selected,
    Function(String) onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) {
        final active = selected == e;
        return ChoiceChip(
          label: Text(e),
          selected: active,
          selectedColor: primaryGreen,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: active ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
          onSelected: (_) => onTap(e),
          labelStyle: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
          elevation: active ? 2 : 0,
        );
      }).toList(),
    );
  }

  // Helper untuk List Dinamis (Tombol tambah/hapus baris)
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
