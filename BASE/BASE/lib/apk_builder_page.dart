import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ApkBuilderPage extends StatefulWidget {
  const ApkBuilderPage({super.key});

  @override
  State<ApkBuilderPage> createState() => _ApkBuilderPageState();
}

class _ApkBuilderPageState extends State<ApkBuilderPage> {
  String _appName = '';
  File? _selectedIcon;
  String _selectedPermission = 'Full'; // Default: Full

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedIcon = File(pickedFile.path);
      });
    }
  }

  void _buildApk() {
    // Di sini nanti lu nembak API ke server Node.js lu
    // buat ngirim data (Nama, Icon, Permission)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Build APK sedang diproses di server...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEEFB), // Sesuaikan tema lu
      appBar: AppBar(
        title: const Text('SYAM Builder', style: TextStyle(fontFamily: 'Astral')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Bagian Nama Aplikasi, Icon, dll sesuai screenshot lu)
            
            // Contoh Input Nama
            const Text('Nama Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              onChanged: (val) => _appName = val,
              decoration: const InputDecoration(
                hintText: 'Cth: Undangan Pernikahan...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tombol Build
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _buildApk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                ),
                child: const Text('🚀 BUILD APK SEKARANG', style: TextStyle(fontFamily: 'Astral')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}