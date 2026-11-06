import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart';
import 'ddos_panel.dart';
import 'nik_check.dart';
import 'tiktok_page.dart';
import 'instagram_page.dart';
import 'qr_gen.dart';
import 'domain_page.dart';
import 'spam_ngl.dart';
import 'phone_lookup.dart';
import 'email_osint.dart';
import 'ip_scanner.dart';
import 'port_scanner.dart';
import 'dracin_page.dart';
import 'anime.dart';
import 'hentai.dart';

// ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFFDCEEFB);
  static const surface   = Color(0xFFFFFFFF);
  static const card      = Color(0xFFF0F7FF);
  static const cardInner = Color(0xFFE3F2FD);
  static const border    = Color(0xFF42A5F5);
  
  static const neonBlue   = Color(0xFF1565C0);
  static const neonRed    = Color(0xFFEF4444);
  static const neonPurple = Color(0xFF1565C0);

  static const text      = Color(0xFF000000);
  static const textSub   = Color(0x8A000000);

  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF64B5F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ─── ROLE COLOR HELPER ──────────────────────────────────────────────────
Color _getRoleColor(String role) {
  switch (role.toLowerCase()) {
    case 'developer': return const Color(0xFFFF6B6B);
    case 'founder':   return const Color(0xFFFFD93D);
    case 'kingz':     return const Color(0xFFFFD700);
    case 'high owner':return const Color(0xFFFF6B6B);
    case 'owner':     return const Color(0xFFFF6B6B);
    case 'tk':        return const Color(0xFF4FC3F7);
    case 'admin':     return const Color(0xFF4FC3F7);
    case 'reseller':  return const Color(0xFF81C784);
    case 'vip':       return const Color(0xFFFFD700);
    case 'member':    return const Color(0xFF90A4AE);
    default:          return _C.neonBlue;
  }
}

// ─── AiAssistantWidget ───────────────────────────────────────────────────
class AiAssistantWidget extends StatelessWidget {
  const AiAssistantWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.neonBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: _C.neonBlue.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _C.neonBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.neonBlue, width: 2),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: _C.neonBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Assistant',
                style: TextStyle(
                  color: _C.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Astral',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.neonBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.neonBlue, width: 1),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: _C.neonBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Astral',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tanya apa saja tentang keamanan siber, hacking, atau tools VURTAX X RAT',
            style: TextStyle(
              color: _C.textSub,
              fontSize: 13,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: 1),
                  ),
                  child: Text(
                    'Tanyakan sesuatu...',
                    style: TextStyle(color: _C.textSub, fontSize: 13, fontFamily: 'Astral'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _C.neonBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tool Category Data ──────────────────────────────────────────────────
class _ToolCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _ToolCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

const _categories = [
  _ToolCategory(id: 'ddos', title: 'Panel', subtitle: 'Attack & Server', icon: Icons.flash_on_rounded, accent: _C.neonBlue),
  _ToolCategory(id: 'network', title: 'Network', subtitle: 'WiFi & Spam', icon: Icons.wifi_rounded, accent: _C.neonPurple),
  _ToolCategory(id: 'osint', title: 'OSINT', subtitle: 'Investigation', icon: Icons.search_rounded, accent: _C.neonRed),
  _ToolCategory(id: 'downloader', title: 'Downloader', subtitle: 'Social Media', icon: Icons.download_rounded, accent: _C.neonBlue),
  _ToolCategory(id: 'streaming', title: 'Streaming', subtitle: 'Motion & Telegram', icon: Icons.play_circle_rounded, accent: _C.neonPurple),
  _ToolCategory(id: 'ai', title: 'Ai Assistant', subtitle: 'Tanya A. Pintar', icon: Icons.auto_awesome_rounded, accent: _C.neonRed),
  _ToolCategory(id: 'generator', title: 'Generator', subtitle: 'Buat & Edit', icon: Icons.build_rounded, accent: _C.neonPurple),
  _ToolCategory(id: 'hosting', title: 'Hosting', subtitle: 'Panel & Ubot', icon: Icons.cloud_queue_rounded, accent: _C.neonRed),
];

// ─── Page Utama ──────────────────────────────────────────────────────────
class ToolsPage extends StatefulWidget {
  final String sessionKey;
  final String userRole;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
    required this.listDoos,
  });

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showAiAssistant = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _pageController = PageController(viewportFraction: 0.45);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _push(Widget page) => Navigator.push(context, _slideRoute(page));

  void _toggleAiAssistant() {
    setState(() {
      _showAiAssistant = !_showAiAssistant;
    });
  }

  void _onCategoryTap(String id) {
    if (id == 'ai') {
      _toggleAiAssistant();
      return;
    }
    
    switch (id) {
      case 'ddos': _showSheet(_ddosItems()); break;
      case 'network': _showSheet(_networkItems()); break;
      case 'osint': _showSheet(_osintItems()); break;
      case 'downloader': _showSheet(_downloaderItems()); break;
      case 'streaming': _showSheet(_streamingItems()); break;
      case 'generator': _showSheet(_generatorItems()); break;
      case 'hosting': _showComingSoon(); break;
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Coming Soon!', style: TextStyle(fontFamily: 'Astral')),
      backgroundColor: _C.neonBlue,
      behavior: SnackBarBehavior.floating,
    ));
  }

  List<_ToolItem> _ddosItems() => [
    _ToolItem(icon: Icons.flash_on_rounded, label: 'Attack Panel', accent: _C.neonBlue, onTap: () => _push(AttackPanel(sessionKey: widget.sessionKey, listDoos: widget.listDoos))),
    _ToolItem(icon: Icons.gavel_rounded, label: 'Stress Test', accent: _C.neonBlue, comingSoon: true, onTap: () {})
  ];

  List<_ToolItem> _networkItems() => [
    _ToolItem(icon: Icons.message_rounded, label: 'Spam NGL', accent: _C.neonRed, onTap: () => _push(NglPage())),
    _ToolItem(icon: Icons.wifi_off_rounded, label: 'WiFi Killer (Internal)', accent: _C.neonRed, onTap: () => _push(WifiKillerPage())),
    if (widget.userRole == 'vip' || widget.userRole == 'owner')
      _ToolItem(icon: Icons.router_rounded, label: 'WiFi Killer (External)', accent: _C.neonRed, onTap: () => _push(WifiInternalPage(sessionKey: widget.sessionKey))),
    _ToolItem(icon: Icons.sms_rounded, label: 'SMS Bomber', accent: _C.neonRed, comingSoon: true, onTap: () {})
  ];

  List<_ToolItem> _osintItems() => [
    _ToolItem(icon: Icons.badge_outlined, label: 'NIK Detail', accent: _C.neonPurple, onTap: () => _push(const NikCheckerPage())),
    _ToolItem(icon: Icons.travel_explore_rounded, label: 'Domain OSINT', accent: _C.neonPurple, onTap: () => _push(const DomainOsintPage())),
    _ToolItem(icon: Icons.person_search_rounded, label: 'Phone Lookup', accent: _C.neonPurple, onTap: () => _push(const PhoneLookupPage())),
    _ToolItem(icon: Icons.alternate_email_rounded, label: 'Email OSINT', accent: _C.neonPurple, onTap: () => _push(const EmailOsintPage())),
    _ToolItem(icon: Icons.fingerprint_rounded, label: 'Username Search', accent: _C.neonPurple, comingSoon: true, onTap: () {})
  ];

  List<_ToolItem> _downloaderItems() => [
    _ToolItem(icon: Icons.video_library_rounded, label: 'TikTok Video', accent: _C.neonBlue, onTap: () => _push(const TiktokPage())),
    _ToolItem(icon: Icons.camera_alt_rounded, label: 'Instagram Downloader', accent: _C.neonBlue, onTap: () => _push(const InstagramDownloaderPage())),
    _ToolItem(icon: Icons.music_note_rounded, label: 'YouTube Downloader', accent: _C.neonBlue, comingSoon: true, onTap: () {})
  ];

  List<_ToolItem> _streamingItems() => [
    _ToolItem(icon: Icons.animation_rounded, label: 'Anime', accent: _C.neonRed, onTap: () => _push(const HomeAnimePage())),
    _ToolItem(icon: Icons.play_circle_rounded, label: 'Dracin', accent: _C.neonRed, onTap: () => _push(const DracinPage())),
    _ToolItem(icon: Icons.telegram_rounded, label: 'Telegram Stream', accent: _C.neonRed, comingSoon: true, onTap: () {})
  ];

  List<_ToolItem> _generatorItems() => [
    _ToolItem(icon: Icons.qr_code_2_rounded, label: 'QR Generator', accent: _C.neonRed, onTap: () => _push(const QrGeneratorPage())),
    _ToolItem(icon: Icons.text_fields_rounded, label: 'Text Generator', accent: _C.neonRed, comingSoon: true, onTap: () {}),
    _ToolItem(icon: Icons.image_rounded, label: 'Image Editor', accent: _C.neonRed, comingSoon: true, onTap: () {})
  ];

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(widget.userRole);
    final roleDisplay = widget.userRole.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── BACKGROUND FULLSCREEN ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/profile_card_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: _C.bg);
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // ── Header "VURTAX X RAT TOOLS" ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage('https://ziperr-img.lovable.app/i/wtnkr4vl.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VURTAX X RAT TOOLS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontFamily: 'Astral',
                                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                              )),
                            Text('TOOLS GATEWAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Astral',
                                shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                              )),
                          ],
                        ),
                        const Spacer(),
                        
                        // ─── ROLE BADGE ────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: roleColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: roleColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                roleDisplay,
                                style: TextStyle(
                                  color: roleColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Astral',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Card Carousel 3D ──
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _currentIndex = index),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) => _buildCarouselCard(i, _categories[i]),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Teks Judul Aktif — PUTIH ──
                  Text(
                    _categories[_currentIndex].title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                      fontFamily: 'Astral',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _categories[_currentIndex].subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Astral',
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),

                  // ── Indicator Dots ──
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_categories.length, (i) {
                      bool active = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: active ? 16 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  // ── AI Assistant Widget ──
                  if (_showAiAssistant) ...[
                    const SizedBox(height: 10),
                    const AiAssistantWidget(),
                  ],

                  const Spacer(),

                  // ── Petunjuk Geser & Tombol Module ──
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        Text(
                          'Geser \u2022 Tap kartu untuk buka',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontFamily: 'Astral',
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () => _onCategoryTap(_categories[_currentIndex].id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.neonBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 5,
                            minimumSize: const Size(120, 40),
                          ),
                          child: Text(
                            'BUKA MODULE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                              fontFamily: 'Astral',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol Panah Navigasi ──
          Positioned(
            bottom: 65,
            left: 12,
            child: _ArrowButton(icon: Icons.arrow_back_ios_new, size: 35, onTap: () {
              if (_currentIndex > 0) _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            }),
          ),
          Positioned(
            bottom: 65,
            right: 12,
            child: _ArrowButton(icon: Icons.arrow_forward_ios, size: 35, onTap: () {
              if (_currentIndex < _categories.length - 1) _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            }),
          ),
        ],
      ),
    );
  }

  // Widget Kartu Carousel
  Widget _buildCarouselCard(int index, _ToolCategory cat) {
    bool isActive = index == _currentIndex;
    
    return GestureDetector(
      onTap: () => _onCategoryTap(cat.id),
      child: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          double value = 1.0;
          if (_pageController.position.haveDimensions) {
            value = _pageController.page! - index;
            value = (1 - (value.abs() * 0.3)).clamp(0.5, 1.0);
          }

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * 0.5)
              ..scale(value),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive ? _C.neonBlue : Colors.black.withOpacity(0.1),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: _C.neonBlue.withOpacity(0.2), blurRadius: 12, spreadRadius: 2)]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: cat.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cat.accent, width: 2),
                    ),
                    child: Icon(cat.icon, color: cat.accent, size: 24),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(cat.title,
                      textAlign: TextAlign.center,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _C.text, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Astral'),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(cat.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _C.textSub, fontSize: 10, fontFamily: 'Astral'),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: cat.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cat.accent),
                    ),
                    child: Text('OPEN', style: TextStyle(color: cat.accent, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Astral')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSheet(List<_ToolItem> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ToolSheet(items: items),
    );
  }
}

// ─── Tombol Panah Bulat ────────────────────────────────────────────────────
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _ArrowButton({required this.icon, required this.onTap, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }
}

// ─── Tool Sheet ──────────────────────────────────────────────────────────
class _ToolSheet extends StatelessWidget {
  final List<_ToolItem> items;
  const _ToolSheet({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: _C.neonBlue)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(width: 35, height: 4, decoration: BoxDecoration(color: _C.neonBlue, borderRadius: BorderRadius.circular(100))),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) => _HDToolRow(
                item: items[i],
                onTap: () {
                  Navigator.pop(ctx);
                  items[i].onTap();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tool Row ──────────────────────────────────────────────────────────────
class _HDToolRow extends StatefulWidget {
  final _ToolItem item;
  final VoidCallback onTap;
  const _HDToolRow({required this.item, required this.onTap});

  @override
  State<_HDToolRow> createState() => _HDToolRowState();
}

class _HDToolRowState extends State<_HDToolRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_pressed ? item.accent.withOpacity(0.15) : _C.card, _C.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _pressed ? item.accent : _C.border, width: _pressed ? 2.5 : 1.0),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [item.accent.withOpacity(0.2), item.accent.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.accent.withOpacity(0.4), width: 2),
            ),
            child: Icon(item.icon, color: item.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.label, style: TextStyle(color: _C.text, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Astral')),
            if (item.comingSoon) Text('Coming Soon', style: TextStyle(color: _C.textSub, fontSize: 10, fontFamily: 'Astral')),
          ])),
          item.comingSoon
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: item.accent, borderRadius: BorderRadius.circular(6)),
                  child: Text('SOON', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, fontFamily: 'Astral')),
                )
              : Icon(Icons.arrow_forward_ios_rounded, color: item.accent, size: 14),
        ]),
      ),
    );
  }
}

// ─── Page transition ──────────────────────────────────────────────────────
PageRoute _slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, anim, __, child) =>
          SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child),
    );

// ─── Data model ───────────────────────────────────────────────────────────
class _ToolItem {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool comingSoon;

  const _ToolItem({required this.icon, required this.label, required this.accent, required this.onTap, this.comingSoon = false});
}