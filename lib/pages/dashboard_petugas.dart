import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../pages/halaman_login.dart';

class HalamanDashboardPetugas extends StatefulWidget {
  final String nama;
  const HalamanDashboardPetugas({super.key, required this.nama});

  @override
  State<HalamanDashboardPetugas> createState() =>
      _HalamanDashboardPetugasState();
}

class _HalamanDashboardPetugasState extends State<HalamanDashboardPetugas> {
  final MobileScannerController kameraController = MobileScannerController();
  bool _sedangMemproses = false;

  Future<void> prosesCariBarang(String kode) async {
    if (_sedangMemproses) return;

    setState(() => _sedangMemproses = true);
    await kameraController.stop();

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('barang')
          .doc(kode)
          .get();

      if (docSnapshot.exists) {
        final dataBarang = docSnapshot.data()!;
        dataBarang['kode_barang'] = kode;

        if (!mounted) return;
        bukaDialogInputFisik(dataBarang);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Barang dengan kode $kode tidak terdaftar!")),
        );
        await kameraController.start();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data dari Firestore: $e")),
      );
      await kameraController.start();
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  void bukaDialogInputFisik(Map<String, dynamic> barang) {
    final TextEditingController inputFisikController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(barang['nama_barang'] ?? "Barang"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kode Barang: ${barang['kode_barang']}"),
              const SizedBox(height: 8),
              Text("Stok Buku Sistem: ${barang['stok_sistem']}"),
              const SizedBox(height: 15),
              TextField(
                controller: inputFisikController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah Nyata di Lapangan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                kameraController.start();
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final text = inputFisikController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jumlah fisik wajib diisi!")),
                  );
                  return;
                }

                final int? stokFisik = int.tryParse(text);
                if (stokFisik == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jumlah stok harus berupa angka!")),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                simpanKeDatabase(
                  barang['kode_barang'],
                  int.parse(barang['stok_sistem'].toString()),
                  stokFisik,
                );
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> simpanKeDatabase(String kode, int stokSis, int stokFis) async {
    try {
      await FirebaseFirestore.instance.collection('opname').add({
        'kode_barang': kode,
        'stok_sistem': stokSis,
        'stok_fisik': stokFis,
        'petugas': widget.nama,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hasil opname berhasil disimpan ke Firestore!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data opname: $e")),
      );
    } finally {
      await kameraController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Petugas Gudang (Scanner)"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              kameraController.stop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: kameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? kode = barcodes.first.rawValue;
                if (kode != null && kode.isNotEmpty) {
                  prosesCariBarang(kode);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Petugas: ${widget.nama}\nArahkan kamera ke Barcode / QR Code",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_sedangMemproses)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    kameraController.dispose();
    super.dispose();
  }
}
