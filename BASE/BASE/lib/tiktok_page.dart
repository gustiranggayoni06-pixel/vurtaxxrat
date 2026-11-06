import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TiktokPage extends StatefulWidget {
  const TiktokPage({super.key});

  @override
  State<TiktokPage> createState() => _TiktokPageState();
}

class _TiktokPageState extends State<TiktokPage>
    with TickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _showError = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────
  static const Color _bgColor = Color(0xFFDCEEFB);  // biru muda lembut
  static const Color _cardColor = Color(0xFFFFFFFF);  // putih
  static const Color _textColor = Color(0xFF000000);  // hitam 87%
  static const Color _textMuted = Color(0x8A000000);  // hitam 54%
  static const Color _textDim = Color(0x61000000);  // hitam 38%
  static const Color _accentColor = Color(0xFF1565C0);  // biru tua accent
  static const Color _accentLight = Color(0xFF42A5F5);  // biru cerah

  final List<String> _loadingTexts = [
    'Menghubungkan ke TikTok...',
    'Mempersiapkan feed video...',
    'Hampir selesai, sabar ya...',
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _cycleLoadingText();
    _checkInternet();
  }

  void _cycleLoadingText() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading && mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
        _cycleLoadingText();
      }
    });
  }

  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;
    if (result == ConnectivityResult.none) {
      setState(() {
        _hasInternet = false;
        _isLoading = false;
      });
    } else {
      _initWebView();
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36')
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _isLoading = false);
            });
          },
          onWebResourceError: (error) {
            Future.delayed(const Duration(seconds: 5), () {
              if (_isLoading && mounted) {
                setState(() {
                  _isLoading = false;
                  _showError = true;
                });
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://m.tiktok.com'));
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _hasInternet = true;
      _showError = false;
      _currentTextIndex = 0;
    });
    _cycleLoadingText();
    await _checkInternet();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (_hasInternet && !_showError)
              WebViewWidget(controller: _controller),

            if (_isLoading)
              Container(
                color: _bgColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 50,
                            color: _accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'TIKTOK',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Astral',
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _loadingTexts[_currentTextIndex],
                          key: ValueKey(_currentTextIndex),
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 13,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return _BouncingDot(delay: index * 200);
                        }),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_hasInternet || _showError)
              Container(
                color: _bgColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: _textDim.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 44,
                            color: _textDim,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Koneksi Terputus',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'TikTok tidak bisa dimuat. Coba klik tombol di bawah untuk menyegarkan halaman.',
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 13,
                            height: 1.5,
                            fontFamily: 'Astral',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Astral',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (!_isLoading)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: _textColor, size: 20),
                    onPressed: () async {
                      if (await _controller.canGoBack()) {
                        _controller.goBack();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF1565C0),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}