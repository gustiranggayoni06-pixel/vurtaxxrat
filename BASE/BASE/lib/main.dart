import 'package:flutter/material.dart';
import 'dart:io';
import 'app_theme.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'admin_page.dart';
import 'developer_page.dart';
import 'creator_page.dart';        // ✅ SUDAH ADA
import 'kingz_page.dart';          // ✅ TAMBAHKAN
import 'owner_page.dart';          // ✅ TAMBAHKAN
import 'landing.dart';
import 'public_chat_page.dart';
// import 'api_config.dart';       // ✅ DIKOMENTAR
import 'animasi_jendela.dart'; // ✅ TAMBAHIN INI
import 'spam_otp_page.dart'; // ← Sesuaikan sama nama file elu

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeColors>(
      valueListenable: AppThemeController.notifier,
      builder: (context, colors, _) => MaterialApp(
      theme: colors.toTheme(ThemeData.light()),
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (colors.wallpaperPath != null && colors.wallpaperPath!.isNotEmpty)
              Image.file(
                File(colors.wallpaperPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(color: colors.background),
              )
            else
              ColoredBox(color: colors.background),
            if (child != null) child,
          ],
        );
      },

      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
  return MaterialPageRoute(
    builder: (_) => const AnimasiJendela(nextPage: LandingPage()),
  );

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DashboardPage(
                username: args['username'],
                password: args['password'],
                role: (args['role'] ?? '').toString(),
                sessionKey: args['key'],
                expiredDate: args['expiredDate'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                listDoos: List<Map<String, dynamic>>.from(args['listDoos'] ?? []),
                news: List<Map<String, dynamic>>.from(args['news'] ?? []),
              ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => HomePage(
                username: args['username'],
                password: args['password'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                role: (args['role'] ?? '').toString(),
                expiredDate: args['expiredDate'],
                sessionKey: args['sessionKey'],
              ),
            );

          case '/seller':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SellerPage(
                keyToken: args['keyToken'],
              ),
            );

          case '/admin':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AdminPage(
                sessionKey: args['sessionKey'],
              ),
            );

          // ─── DEVELOPER ──────────────────────────────────────────
          case '/developer':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DeveloperPage(
                sessionKey: args['sessionKey'],
              ),
            );

          // ─── CREATOR ────────────────────────────────────────────
          case '/creator':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CreatorPage(
                sessionKey: args['sessionKey'],
              ),
            );

          // ─── KINGZ ──────────────────────────────────────────────
          case '/kingz':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => KingzPage(
                sessionKey: args['sessionKey'],
              ),
            );

          // ─── OWNER ──────────────────────────────────────────────
          case '/owner':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => OwnerPage(
                sessionKey: args['sessionKey'],
                username: args['username'] ?? '',
              ),
            );

          // ─── CHAT ────────────────────────────────────────────────
          case '/chat':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PublicChatPage(
                sessionKey: args?['sessionKey'] ?? '',
                username: args?['username'] ?? 'User',
                role: args?['role'] ?? 'user',
              ),
            );

            // ─── SPAM OTP WHATSAPP ──────────────────────────────────
case '/spam_otp':
  return MaterialPageRoute(
    builder: (_) => const SpamOtpPage(), // Panggil class halaman baru elu
  );
            
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "404 - Halaman Tidak Ditemukan",
                    style: TextStyle(color: Color(0xFF000000), fontFamily: 'Astral'),
                  ),
                ),
              ),
            );
        }
      },
    ),
    );
  }
}