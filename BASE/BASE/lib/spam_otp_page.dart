import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ TAMBAHAN BUAT AMBIL KEY
import 'dart:convert';
import 'dart:math';

class SpamOtpPage extends StatefulWidget {
  const SpamOtpPage({super.key});

  @override
  State<SpamOtpPage> createState() => _SpamOtpPageState();
}

class _SpamOtpPageState extends State<SpamOtpPage> {
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  bool _isLoading = false;

  // Fungsi nembak ke API Server Node.js (Baileys)
  Future<void> _mulaiSpam() async {
    if (_nomorController.text.isEmpty || _jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nomor dan jumlah dulu goblok!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // ⚠️ URL SERVER LU
    const String apiUrl = 'http://cp.zyrostore.id:3594/send-otp';
    
    // ✅ OTOMATIS AMBIL SESSION KEY DARI MEMORI HP (Sesuai login_page.dart)
    final prefs = await SharedPreferences.getInstance();
    final String sessionKey = prefs.getString('key') ?? ''; 

    // Cek kalau key kosong (berarti user belum login atau key kehapus)
    if (sessionKey.isEmpty) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session Key tidak ditemukan! Silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    int jumlahSpam = int.tryParse(_jumlahController.text) ?? 1;
    int sukses = 0;
    int gagal = 0;

    // Looping buat nembak berulang kali sesuai inputan user
    for (int i = 0; i < jumlahSpam; i++) {
      try {
        // Generate OTP 6 digit random
        String otp = (Random().nextInt(900000) + 100000).toString();
        
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'key': sessionKey, // ✅ PAKE KEY DARI MEMORI HP
            'nomor': _nomorController.text,
            'pesan': 'Kode OTP WhatsApp Anda adalah: $otp. JANGAN BERIKAN KODE INI KEPADA SIAPAPUN!',
          }),
        );

        final data = jsonDecode(response.body);
        
        if (data['valid'] == true && data['sent'] == true) {
          sukses++;
        } else {
          gagal++;
        }
      } catch (e) {
        gagal++;
      }
      
      // Jeda 1 detik biar server gak kewalahan (Rate Limit)
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selesai! Sukses: $sukses, Gagal: $gagal', style: const TextStyle(color: Colors.white)), 
          backgroundColor: sukses > 0 ? Colors.green : Colors.red
        ),
      );
      _nomorController.clear();
      _jumlahController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SPAM OTP WHATSAPP',
          style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.message, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            TextField(
              controller: _nomorController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor Target (Contoh: 628xxxx)',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Spam (Angka)',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _mulaiSpam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'START SPAM MODULE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}