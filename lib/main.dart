import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../pages/halaman_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Aktifkan jika menggunakan flutterfire configure
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HalamanLogin(),
    ),
  );
}