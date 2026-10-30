import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../firebase_options.dart';
import '../pages/halaman_login.dart';

class HalamanDashboardKadin extends StatelessWidget {
  final String nama;
  const HalamanDashboardKadin({super.key, required this.nama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoring Kadin"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yth. $nama",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 5),
            const Text("Jabatan: Kepala Dinas Kominfo"),
            const SizedBox(height: 30),
            const Card(
              color: Colors.purple,
              child: ListTile(
                leading: Icon(Icons.assessment, color: Colors.white, size: 40),
                title: Text(
                  "Status Keberadaan Barang Gudang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Semua data opname terekam realtime di Firestore.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.purple),
                title: const Text("Monitoring Stok Barang"),
                subtitle: const Text("Melihat hasil pemeriksaan stok barang."),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Menu monitoring stok")),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.purple),
                title: const Text("Riwayat Opname"),
                subtitle: const Text("Melihat riwayat pemeriksaan barang."),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Menu riwayat opname")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}