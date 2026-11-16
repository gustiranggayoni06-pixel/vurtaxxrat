import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:video_player/video_player.dart';
import 'api_config.dart';
import 'login_page.dart';
import 'animasi_jendela.dart';
// ─── ROLE HELPERS (SINKRON DENGAN DASHBOARD PAGE) ────────────────────────
const List<String> allRoles = [
  'developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin', 'reseller', 'vip', 'member'
];

const Map<String, int> roleLevel = {
  'developer': 10,
  'founder': 9,
  'kingz': 8,
  'high owner': 7,
  'owner': 6,
  'tk': 5,
  'admin': 4,
  'reseller': 3,
  'vip': 2,
  'member': 1,
};

const Map<String, String> roleDisplayName = {
  'developer': 'Developer',
  'founder': 'Founder',
  'kingz': 'Kingz',
  'high owner': 'High Owner',
  'owner': 'Owner',
  'tk': 'TK',
  'admin': 'Admin',
  'reseller': 'Reseller',
  'vip': 'VIP',
  'member': 'Member',
};

const Map<String, IconData> roleIcon = {
  'developer': Icons.code_rounded,
  'founder': Icons.workspace_premium_rounded,
  'kingz': Icons.emoji_events,
  'high owner': Icons.stars_rounded,
  'owner': Icons.workspace_premium_rounded,
  'tk': Icons.security_rounded,
  'admin': Icons.admin_panel_settings_rounded,
  'reseller': Icons.storefront_rounded,
  'vip': Icons.star_rounded,
  'member': Icons.person_rounded,
};

const Map<String, Color> roleColor = {
  'developer': Color(0xFF1565C0),
  'founder': Color(0xFF1565C0),
  'kingz': Color(0xFF1565C0),
  'high owner': Color(0xFF1565C0),
  'owner': Color(0xFF1565C0),
  'tk': Color(0xFF1565C0),
  'admin': Color(0xFF1565C0),
  'reseller': Color(0xFF1565C0),
  'vip': Color(0xFF1565C0),
  'member': Color(0xFF1565C0),
};

String getRoleDisplayName(String role) {
  return roleDisplayName[role.toLowerCase()] ?? role.toUpperCase();
}

IconData getRoleIcon(String role) {
  return roleIcon[role.toLowerCase()] ?? Icons.person_rounded;
}

Color getRoleColor(String role) {
  return roleColor[role.toLowerCase()] ?? Color(0xFF1565C0);
}

int getRoleLevel(String role) {
  return roleLevel[role.toLowerCase()] ?? 0;
}

bool isHighRole(String role) {
  final level = getRoleLevel(role);
  return level >= 6;
}

bool isOwnerRole(String role) {
  final highRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner'];
  return highRoles.contains(role.toLowerCase());
}

bool isAdminRole(String role) {
  final adminRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin'];
  return adminRoles.contains(role.toLowerCase());
}

// ============================================================================
// LANDING PAGE
// ============================================================================

class _C {
  static const bgTop       = Color(0xFFDCEEFB);  // biru muda lembut
  static const bgBottom    = Color(0xFFF0F7FF);  // biru sangat pucat
  static const cardBg      = Color(0xFFFFFFFF);  // putih
  static const cardBorder  = Color(0xFF42A5F5);  // biru cerah
  static const primaryBlue = Color(0xFF1565C0);  // biru tua accent
  static const cyanAccent  = Color(0xFF1565C0);
  static const textMain    = Color(0xFF000000);  // hitam 87%
  static const textSub     = Color(0x8A000000);  // hitam 54%
  static const textDim     = Color(0x61000000);  // hitam 38%
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {

  late VideoPlayerController _videoController;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();

  //  _videoController = VideoPlayerController.asset('assets/videos/background.mp4')
    //  ..initialize().then((_) {
   //     setState(() {});
     //   _videoController.setLooping(true);
   //     _videoController.play();
   //   });

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
  //  _videoController.dispose();
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgTop,
      body: Stack(
        children: [
          // ====== BACKGROUND GAMBAR (GANTI DI SINI) ======
Positioned.fill(
  child: Image.asset(
    'assets/images/bg_jdm.jpg', // <--- GANTI DENGAN NAMA FILE GAMBAR TUAN
    fit: BoxFit.cover,
  ),
),
          // ====== OVERLAY PUTIH ======
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.0),
            ),
          ),
          // ====== KONTEN ======
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildLogoBox(),
                      const SizedBox(height: 20),
                      _buildTitleHeader(),
                      const SizedBox(height: 24),
                      _buildFeatureCards(),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 12),
                      _buildBuyAksesButton(),
                      const SizedBox(height: 12),
                      _buildContactSupportButton(),
                      const SizedBox(height: 24),
                      _buildSocialSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildLogoBox() {
  return AnimatedBuilder(
    animation: _floatCtrl,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(0, 4 * _floatCtrl.value),
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildTitleHeader() {
    return Column(
      children: [
        Text(
          'VURTAX X RAT',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Genetic',
            color: _C.textMain,
            fontSize: 35,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'APK Dengan Design Yang Menarik Dan Mempunyai Banyak Fitur Yang Work.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Astral',
            color: _C.textSub,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSingleFeatureCard(
              icon: Icons.smartphone_rounded,
              title: 'RAT',
              subtitle: 'Fitur yang dapat mengontrol device',
            ),
          ),
          Container(width: 1, height: 50, color: _C.cardBorder),
          Expanded(
            child: _buildSingleFeatureCard(
              icon: Icons.verified_rounded,
              title: 'Terupdate',
              subtitle: 'Server Lebih Optimal',
            ),
          ),
          Container(width: 1, height: 50, color: _C.cardBorder),
          Expanded(
            child: _buildSingleFeatureCard(
              icon: FontAwesomeIcons.whatsapp,
              title: 'BUG',
              subtitle: 'Bug Nomor Whatsapp',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: _C.cyanAccent, size: 26),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Astral',
            color: _C.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Astral',
            color: _C.textSub,
            fontSize: 9,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AnimasiJendela(nextPage: LoginPage()),
    ),
  )),
  borderRadius: BorderRadius.circular(14),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.login_rounded, color: Colors.white, size: 20),
      SizedBox(width: 8),
      Text(
        'MASUK',
        style: TextStyle(
          fontFamily: 'Astral',
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ],
  ),
),
  }

  Widget _buildBuyAksesButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showBuyAksesSheet,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shopping_bag_outlined, color: _C.cyanAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'BUY ACCESS',
                style: TextStyle(
                  fontFamily: 'Astral',
                  color: _C.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSupportButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openUrl('https://t.me/ranzz_offc'),
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.headset_mic_outlined, color: _C.cyanAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'CONTACT SUPPORT',
                style: TextStyle(
                  fontFamily: 'Astral',
                  color: _C.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialCircleItem(
                icon: FontAwesomeIcons.telegram,
                label: 'Telegram',
                onTap: () => _openUrl('https://t.me/ranzz_offc'),
              ),
              _buildSocialCircleItem(
                icon: FontAwesomeIcons.tiktok,
                label: 'TikTok',
                onTap: () => _openUrl('https://tiktok.com/@r4nzz_offc'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Powered By @ranzz_offc',
            style: TextStyle(
              fontFamily: 'Astral',
              color: _C.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCircleItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: _C.cyanAccent.withOpacity(0.2), width: 1),
            ),
            child: Center(
              child: FaIcon(icon, color: _C.cyanAccent, size: 20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Astral',
              color: _C.textSub,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyAksesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BuyAksesSheet(
        onBuy: (url) async {
          Navigator.pop(context);
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}

// ============================================================
// ====== BUY AKSES SHEET (DENGAN ROLE BARU) ======
// ============================================================
class _BuyAksesSheet extends StatefulWidget {
  final Future<void> Function(String url) onBuy;
  const _BuyAksesSheet({required this.onBuy});

  @override
  State<_BuyAksesSheet> createState() => _BuyAksesSheetState();
}

class _BuyAksesSheetState extends State<_BuyAksesSheet> {
  int _selectedPackage = 0;
  String _selectedRole = 'member';

  final Map<String, Map<String, dynamic>> _packages = {
    'member': {
      'label': 'MEMBER',
      'desc': 'Akses dasar member',
      'color': const Color(0xFF1565C0),
      'level': 1,
      'plans': [
        {'name': 'Trial Sehari',  'price': 'Rp 2.000',  'icon': Icons.access_time_rounded},
        {'name': 'Trial Sebulan', 'price': 'Rp 15.000', 'icon': Icons.calendar_month_rounded},
        {'name': 'Permanen',      'price': 'Rp 20.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'vip': {
      'label': 'VIP',
      'desc': 'Akses VIP lebih cepat',
      'color': const Color(0xFF1565C0),
      'level': 2,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 25.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'reseller': {
      'label': 'RESELLER',
      'desc': 'Bisa create akun Member & VIP',
      'color': const Color(0xFF1565C0),
      'level': 3,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 30.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'admin': {
      'label': 'ADMIN',
      'desc': 'Bisa create sampai Reseller',
      'color': const Color(0xFF1565C0),
      'level': 4,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 35.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'tk': {
      'label': 'TK',
      'desc': 'Bisa create sampai Admin',
      'color': const Color(0xFF1565C0),
      'level': 5,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 40.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'owner': {
      'label': 'OWNER',
      'desc': 'Bisa create sampai TK',
      'color': const Color(0xFF1565C0),
      'level': 6,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 50.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'high owner': {
      'label': 'HIGH OWNER',
      'desc': 'Bisa create sampai Owner',
      'color': const Color(0xFF1565C0),
      'level': 7,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 60.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'kingz': {
      'label': 'KINGZ',
      'desc': 'Bisa create sampai High Owner',
      'color': const Color(0xFF1565C0),
      'level': 8,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 75.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'founder': {
      'label': 'FOUNDER',
      'desc': 'Bisa create sampai Kingz',
      'color': const Color(0xFF1565C0),
      'level': 9,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 100.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'developer': {
      'label': 'DEVELOPER',
      'desc': 'Akses penuh semua fitur',
      'color': const Color(0xFF1565C0),
      'level': 10,
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 150.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
  };

  List<String> get _roleOrder => [
    'member',
    'vip',
    'reseller',
    'admin',
    'tk',
    'owner',
    'high owner',
    'kingz',
    'founder',
    'developer',
  ];

  @override
  Widget build(BuildContext context) {
    final pkg = _packages[_selectedRole]!;
    final plans = pkg['plans'] as List;
    final color = pkg['color'] as Color;
    final level = pkg['level'] as int;
    final totalLevel = _roleOrder.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF42A5F5))),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Icon(Icons.shopping_bag_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BELI AKSES',
                        style: TextStyle(
                          fontFamily: 'Astral',
                          color: Color(0xFF000000),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Level $level dari $totalLevel',
                        style: const TextStyle(
                          fontFamily: 'Astral',
                          color: Color(0x8A000000),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Lv.$level',
                    style: TextStyle(
                      fontFamily: 'Astral',
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _roleOrder.map((roleKey) {
                final isSelected = _selectedRole == roleKey;
                final roleData = _packages[roleKey]!;
                final c = roleData['color'] as Color;
                final lv = roleData['level'] as int;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedRole = roleKey;
                    _selectedPackage = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? c.withOpacity(0.2) : const Color(0x1A000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? c : const Color(0x33000000),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lv.$lv',
                          style: TextStyle(
                            fontFamily: 'Astral',
                            color: isSelected ? c : const Color(0x8A000000),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          roleData['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Astral',
                            color: isSelected ? c : const Color(0x8A000000),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.workspace_premium_rounded, color: color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Astral',
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                pkg['desc'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Astral',
                                  color: Color(0x8A000000),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedRole == 'member') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.4)),
                            ),
                            child: const Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                fontFamily: 'Astral',
                                color: Color(0xFF1565C0),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...plans.asMap().entries.map((entry) {
                    final i = entry.key;
                    final plan = entry.value as Map;
                    final isSelected = _selectedPackage == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPackage = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.1) : const Color(0x1A000000),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : const Color(0x33000000),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? color : const Color(0x33000000),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check_rounded, color: color, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Icon(plan['icon'] as IconData, color: isSelected ? color : const Color(0x8A000000), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              plan['name'] as String,
                              style: TextStyle(
                                fontFamily: 'Astral',
                                color: isSelected ? Color(0xFF000000) : const Color(0x8A000000),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              plan['price'] as String,
                              style: TextStyle(
                                fontFamily: 'Astral',
                                color: isSelected ? color : const Color(0x8A000000),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x1A000000),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x33000000)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ROLE HIERARCHY',
                          style: TextStyle(
                            fontFamily: 'Astral',
                            color: Color(0x8A000000),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _roleOrder.map((roleKey) {
                            final roleData = _packages[roleKey]!;
                            final c = roleData['color'] as Color;
                            final lv = roleData['level'] as int;
                            final isActive = lv <= level;
                            return Column(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive ? c : Colors.transparent,
                                    border: Border.all(
                                      color: isActive ? c : const Color(0x33000000),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isActive
                                      ? Icon(Icons.check, color: Colors.white, size: 12)
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lv.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Astral',
                                    color: isActive ? c : const Color(0x33000000),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _roleOrder.map((roleKey) {
                            final roleData = _packages[roleKey]!;
                            final lv = roleData['level'] as int;
                            final isActive = lv <= level;
                            return Text(
                              (lv % 2 == 0) ? (lv ~/ 2).toString() : '',
                              style: TextStyle(
                                fontFamily: 'Astral',
                                color: isActive ? Colors.black54 : const Color(0x33000000),
                                fontSize: 7,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: GestureDetector(
              onTap: () {
                final plan = plans[_selectedPackage];
                final msg = 'Halo, saya mau beli akses ${pkg['label']} - ${plan['name']} (${plan['price']})';
                final url = 'https://t.me/ranzz_offc_stur?text=${Uri.encodeComponent(msg)}';
                widget.onBuy(url);
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'CONTACT & BUY AKSES',
                      style: TextStyle(
                        fontFamily: 'Astral',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}