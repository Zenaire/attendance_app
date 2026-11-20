import 'package:flutter/material.dart';

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi diperlukan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Firebase belum dikonfigurasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Langkah:'),
            const Text('1. Pasang Firebase CLI'),
            const Text('2. Jalankan firebase login'),
            const Text('3. dart pub global activate flutterfire_cli'),
            const Text('4. flutterfire configure --project=ID_PROJECT_ANDA'),
            const Text('5. Jalankan ulang aplikasi'),
            const SizedBox(height: 24),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
