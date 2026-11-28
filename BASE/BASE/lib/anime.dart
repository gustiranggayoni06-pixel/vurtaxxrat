import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeAnimePage extends StatefulWidget {
  const HomeAnimePage({super.key});

  @override
  State<HomeAnimePage> createState() => _HomeAnimePageState();
}

class _HomeAnimePageState extends State<HomeAnimePage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ GANTI URL INI SAMA WEBSITE ANIME FAVORIT LU
    // Contoh: https://otakudesu.cloud atau https://samehadaku.email
    const String animeUrl = 'https://otakudesu.cloud'; 

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFCED4DA)) // Sesuaikan warna tema lu
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Loading bar
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error
          },
        ),
      )
      ..loadRequest(Uri.parse(animeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCED4DA),
      appBar: AppBar(
        title: const Text(
          'Tempat Wibu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.black87),
            ),
        ],
      ),
    );
  }
}