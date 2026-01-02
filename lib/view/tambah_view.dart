import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

const Color primaryGreen = Color(0xFF4CAF50);

class TambahView extends StatefulWidget {
  const TambahView({super.key});

  @override
  State<TambahView> createState() => _TambahViewState();
}

class _TambahViewState extends State<TambahView> {
  final _titleCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  String selectedCategory = "Breakfast";
  String selectedDifficulty = "Mudah";

  List<TextEditingController> ingredients = [];
  List<TextEditingController> steps = [];

  File? imageFile;

  @override
  void initState() {
    super.initState();
    ingredients.add(TextEditingController());
    steps.add(TextEditingController());
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> saveRecipe() async {
    if (_titleCtrl.text.isEmpty || imageFile == null) return;

    final imageRef = FirebaseStorage.instance.ref(
      'recipes/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await imageRef.putFile(imageFile!);
    final imageUrl = await imageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('recipes').add({
      'title': _titleCtrl.text,
      'image_url': imageUrl,
      'category': selectedCategory,
      'difficulty': selectedDifficulty,
      'time': _timeCtrl.text,
      'ingredients': ingredients.map((e) => e.text).toList(),
      'steps': steps.map((e) => e.text).toList(),
    });

    Navigator.pop(context); // balik ke dashboard
  }

  @override
  Widget build(BuildContext context) {
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
          TextButton(
            onPressed: saveRecipe,
            child: const Text("Simpan", style: TextStyle(color: primaryGreen)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// UPLOAD FOTO
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: imageFile != null
                      ? DecorationImage(
                          image: FileImage(imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageFile == null
                    ? const Center(child: Text("Kteuk untuk upload foto"))
                    : null,
              ),
            ),

            const SizedBox(height: 16),
            _input("Nama Resep", _titleCtrl),

            const SizedBox(height: 8),
            const Text("Kategori"),
            _chipGroup(
              ["Breakfast", "Lunch", "Dinner", "Favorite"],
              selectedCategory,
              (v) => setState(() => selectedCategory = v),
            ),

            const SizedBox(height: 8),
            const Text("Kesulitan"),
            _chipGroup(
              ["Mudah", "Sedang", "Sulit"],
              selectedDifficulty,
              (v) => setState(() => selectedDifficulty = v),
            ),

            _input("Waktu (contoh: 20 min)", _timeCtrl),

            const SizedBox(height: 12),
            const Text("Bahan - Bahan"),
            ..._dynamicList(ingredients, "Tambahkan Bahan"),

            const SizedBox(height: 12),
            const Text("Langkah - Langkah"),
            ..._dynamicList(steps, "Tambahkan Langkah"),
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

  Widget _chipGroup(
    List<String> items,
    String selected,
    Function(String) onTap,
  ) {
    return Wrap(
      spacing: 8,
      children: items.map((e) {
        final active = selected == e;
        return ChoiceChip(
          label: Text(e),
          selected: active,
          selectedColor: primaryGreen,
          onSelected: (_) => onTap(e),
          labelStyle: TextStyle(color: active ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }

  List<Widget> _dynamicList(
    List<TextEditingController> list,
    String buttonLabel,
  ) {
    return [
      ...list.asMap().entries.map(
        (e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: e.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() => list.removeAt(e.key));
                },
              ),
            ],
          ),
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          minimumSize: const Size(double.infinity, 44),
        ),
        onPressed: () {
          setState(() => list.add(TextEditingController()));
        },
        child: Text("+ $buttonLabel"),
      ),
    ];
  }
}
