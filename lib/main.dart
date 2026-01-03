import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pastikan provider tetap ada (jika sudah ditambahkan sebelumnya)

// AKTIFKAN import ini:
import './view/login_view.dart';
// import './view/register_view.dart'; // Boleh biarkan atau matikan jika tidak dipakai di main
import 'controller/login_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // Bungkus root aplikasi dengan MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        // Daftarkan controller lain di sini jika diperlukan nanti
        // ChangeNotifierProvider(create: (_) => RegisterController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF5CB85C),
      ),
      // GANTI bagian ini:
      home: const LoginView(),
    );
  }
}
