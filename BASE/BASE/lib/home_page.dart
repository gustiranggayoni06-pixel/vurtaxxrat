import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'api_config.dart';

// ─── ROLE HELPERS ──────────────────────────────────────────────────
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

String _roleDisplayName(String role) {
  switch (role.toLowerCase()) {
    case 'developer': return 'Developer';
    case 'founder':   return 'Founder';
    case 'kingz':     return 'Kingz';
    case 'high owner':return 'High Owner';
    case 'owner':     return 'Owner';
    case 'tk':        return 'TK';
    case 'admin':     return 'Admin';
    case 'reseller':  return 'Reseller';
    case 'vip':       return 'VIP';
    case 'member':    return 'Member';
    default:          return role.toUpperCase();
  }
}

Color _roleColor(String role) {
  switch (role.toLowerCase()) {
    case 'developer': return const Color(0xFF1565C0);
    case 'founder':   return const Color(0xFF1565C0);
    case 'kingz':     return const Color(0xFF1565C0);
    case 'high owner':return const Color(0xFF1565C0);
    case 'owner':     return const Color(0xFF1565C0);
    case 'tk':        return const Color(0xFF1565C0);
    case 'admin':     return const Color(0xFF1565C0);
    case 'reseller':  return const Color(0xFF1565C0);
    case 'vip':       return const Color(0xFF1565C0);
    case 'member':    return const Color(0xFF1565C0);
    default:          return const Color(0xFF1565C0);
  }
}

IconData _roleIcon(String role) {
  switch (role.toLowerCase()) {
    case 'developer': return Icons.code_rounded;
    case 'founder':   return Icons.workspace_premium_rounded;
    case 'kingz':     return Icons.emoji_events;
    case 'high owner':return Icons.stars_rounded;
    case 'owner':     return Icons.workspace_premium_rounded;
    case 'tk':        return Icons.security_rounded;
    case 'admin':     return Icons.admin_panel_settings_rounded;
    case 'reseller':  return Icons.storefront_rounded;
    case 'vip':       return Icons.star_rounded;
    case 'member':    return Icons.person_rounded;
    default:          return Icons.person_rounded;
  }
}

bool _canAccessGlobalSender(String role) {
  final r = role.toLowerCase();
  return r == 'developer' ||
      r == 'founder' ||
      r == 'kingz' ||
      r == 'high owner' ||
      r == 'owner' ||
      r == 'tk' ||
      r == 'admin' ||
      r == 'vip';
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final String username;
  final String password;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final String role;
  final String expiredDate;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
    required this.sessionKey,
    required this.listBug,
    required this.role,
    required this.expiredDate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _resultCtrl;
  late Animation<double> _resultFade;
  late Animation<Offset> _resultSlide;

  final targetController = TextEditingController();
  final PageController _bugPageController = PageController(viewportFraction: 0.85);

  String? _selectedBugId;
  bool _isSending = false;
  String? _responseMessage;
  int _currentBugPage = 0;

  // ─── BUG GROUP ──────────────────────────────────────────────────────────
  String _selectedBugMode = "number";

  // ─── SENDER DATA ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _senderList = [];
  List<String> _globalSenders = [];
  bool _isLoadingSenders = false;
  int _privateSenderCount = 0;
  int _globalSenderCount = 0;
  bool _loadingSender = false;
  Timer? _senderTimer;

  String _selectedSender = 'private';
  bool get canAccessGlobalSender => _canAccessGlobalSender(widget.role);

  // Animasi
  Map<String, AnimationController> _bugAnimations = {};
  Map<String, double> _bugOffsets = {};

  // ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────
  static const Color _bgDark       = Color(0xFFDCEEFB);
  static const Color _bgCard       = Color(0xFFF0F7FF);
  static const Color _textWhite    = Color(0xFF000000);
  static const Color _textGrey     = Color(0x8A000000);
  static const Color _textMuted    = Color(0x61000000);
  static const Color _accent       = Color(0xFF1565C0);
  static const Color _accentLight  = Color(0xFF42A5F5);
  static const Color _accentDark   = Color(0xFF0D47A1);
  static const Color _green        = Color(0xFF22C55E);
  static const Color _red          = Color(0xFFEF4444);
  static const Color _amber        = Color(0xFFFFC34D);
  static const Color _glassColor   = Color(0x8AFFFFFF);
  static const Color _glassBorder  = Color(0x33000000);
  static const Color _glassBorderActive = Color(0x66000000);
  static const Color _blackColor   = Color(0x1A000000);

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/background.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(100);
        _videoController.play();
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _resultFade = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut);
    _resultSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutCubic));

    _fetchSenderData();
    
    // ✅ FIX: Timer refresh 30s
    _senderTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchSenderData();
      _fetchGlobalSenders();
    });

    if (widget.listBug.isNotEmpty) {
      final firstBug = widget.listBug[0];
      _selectedBugId = firstBug['bug_id'] as String? ?? '0';
    }

    for (var bug in widget.listBug) {
      final bugId = bug['bug_id'] as String? ?? '0';
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _bugAnimations[bugId] = controller;
      _bugOffsets[bugId] = 0.0;
      
      controller.addListener(() {
        setState(() {
          _bugOffsets[bugId] = controller.value;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _resultCtrl.dispose();
    targetController.dispose();
    _bugPageController.dispose();
    _senderTimer?.cancel();
    for (var controller in _bugAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ─── FETCH SENDER DATA ──────────────────────────────────────────
  Future<void> _fetchSenderData() async {
    if (_loadingSender) return;
    setState(() => _loadingSender = true);

    try {
      final url = "$baseUrl/mySender?key=${widget.sessionKey}";
      print('📡 [HOME] Fetching senders: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 [HOME] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['valid'] == true) {
          List<Map<String, dynamic>> senderList = [];
          
          if (data['connections'] != null) {
            if (data['connections'] is Map) {
              final connMap = data['connections'] as Map;
              if (connMap['private'] != null) {
                senderList = List<Map<String, dynamic>>.from(connMap['private']);
              } else if (connMap['global'] != null) {
                senderList = List<Map<String, dynamic>>.from(connMap['global']);
              }
            } else if (data['connections'] is List) {
              senderList = List<Map<String, dynamic>>.from(data['connections']);
            }
          } else if (data['senderList'] != null) {
            senderList = List<Map<String, dynamic>>.from(data['senderList']);
          } else if (data['data'] != null) {
            senderList = List<Map<String, dynamic>>.from(data['data']);
          }

          setState(() {
            _senderList = senderList;
            _privateSenderCount = senderList.length;
          });

          await _fetchGlobalSenders();

        } else {
          print('❌ [HOME] Invalid response: ${data['message']}');
        }
      } else {
        print('❌ [HOME] Server error: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ [HOME] Error fetching senders: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingSender = false);
      }
    }
  }

  // ─── FETCH GLOBAL SENDERS ────────────────────────────────────────
  Future<void> _fetchGlobalSenders() async {
    try {
      final url = "$baseUrl/getPublicSenders?key=${widget.sessionKey}";
      print('📡 [HOME] Fetching global senders: $url');

      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('📡 [HOME] Global response: $data');
        
        if (data['valid'] == true && data['senders'] != null) {
          final senders = List<dynamic>.from(data['senders']);
          
          // ✅ FIX: baca field 'session'
          final senderNames = senders
              .map((s) => s['session']?.toString()
                  ?? s['number']?.toString()
                  ?? s['sessionName']?.toString()
                  ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
          
          print('📡 [HOME] Parsed ${senderNames.length} global senders: $senderNames');
          
          if (mounted) {
            setState(() {
              _globalSenders = senderNames.cast<String>();
              _globalSenderCount = _globalSenders.length;
            });
          }
        } else {
          if (mounted) setState(() {
            _globalSenders = [];
            _globalSenderCount = 0;
          });
        }
      } else {
        if (mounted) setState(() {
          _globalSenders = [];
          _globalSenderCount = 0;
        });
      }
    } catch (e) {
      print('❌ [HOME] Error fetching global: $e');
      if (mounted) setState(() {
        _globalSenders = [];
        _globalSenderCount = 0;
      });
    }
  }

  // ─── FORMAT PHONE ─────────────────────────────────────────────────
  String? formatPhoneNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+') || cleaned.length < 8) return null;
    return cleaned;
  }

  bool isValidGroupLink(String input) {
    return input.contains('chat.whatsapp.com') && input.contains('https://');
  }

  void _setResponse(String type, String msg) {
    if (!mounted) return;
    setState(() => _responseMessage = '$type|$msg');
    _resultCtrl.forward(from: 0);
  }

  // ─── SEND BUG — ✅ FIX: KIRIM senderMode ───────────────────────
  Future<void> _sendBug() async {
    final rawInput = targetController.text.trim();
    final key = widget.sessionKey;

    if (_selectedBugMode == "group") {
      if (!isValidGroupLink(rawInput)) {
        _showAlert("❌ Link Tidak Valid",
            "Masukkan link grup WhatsApp yang valid.\nContoh: https://chat.whatsapp.com/...");
        return;
      }
    } else {
      if (formatPhoneNumber(rawInput) == null) {
        _showAlert("❌ Nomor Tidak Valid",
            "Gunakan format internasional.\nContoh: +62812xxxxxxxx");
        return;
      }
    }

    if (_selectedSender == 'global' && !canAccessGlobalSender) {
      _showAlert("❌ Akses Ditolak",
          "Sender Global hanya untuk Developer, Founder, Kingz, High Owner, Owner, TK, Admin & VIP!");
      return;
    }

    if (_selectedBugId == null || _selectedBugId!.isEmpty) {
      _showAlert("❌ No Bug Selected", "Pilih 1 bug untuk dikirim.");
      return;
    }

    if (_selectedSender == 'private' && _privateSenderCount == 0) {
      _showAlert("❌ No Private Sender", "Tidak ada private sender tersedia.\nTambahkan sender di Menu Bug Sender.");
      return;
    }
    if (_selectedSender == 'global' && _globalSenderCount == 0) {
      _showAlert("❌ No Global Sender", "Tidak ada global sender tersedia.");
      return;
    }

    setState(() {
      _isSending = true;
      _responseMessage = null;
    });
    _resultCtrl.reset();

    try {
      final encodedTarget = Uri.encodeComponent(rawInput);
      
      // ✅ FIX UTAMA: Kirim senderMode ke server
      final url = '$baseUrl/sendBug'
          '?key=$key'
          '&target=$encodedTarget'
          '&bug=${_selectedBugId}'
          '&senderMode=$_selectedSender';
      
      print('📤 [HOME] Sending bug: $url');
      print('📤 [HOME] Mode: $_selectedSender | Bug: $_selectedBugId | Target: $rawInput');
      
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      final data = jsonDecode(res.body);

      if (data['valid'] == false) {
        _setResponse('error', 'Session key tidak valid. Silakan login ulang.');
      } else if (data['cooldown'] == true) {
        final wait = data['wait'] ?? 0;
        _setResponse('warning', 'Cooldown aktif! Tunggu $wait detik lagi.');
      } else if (data['sended'] == true) {
        final role = data['role'] ?? widget.role;
        _setResponse('success', 'Bug berhasil dikirim ke $rawInput! [${_roleDisplayName(role)}]');
        targetController.clear();
      } else {
        _setResponse('error', data['message'] ?? 'Gagal mengirim. Coba lagi.');
      }
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        _setResponse('error', 'Request timeout. Periksa koneksi internet.');
      } else {
        _setResponse('error', 'Koneksi error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: _glassBorderActive, width: 1.5),
          ),
          title: Text(title,
              style: TextStyle(
                  color: _textWhite,
                  fontFamily: 'Astral',
                  fontWeight: FontWeight.bold)),
          content: Text(msg, style: TextStyle(color: _textGrey, fontFamily: 'Astral')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK",
                  style: TextStyle(
                      color: _accent, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
            ),
          ],
        ),
      ),
    );
  }

  // ─── WIDGET BUILD ─────────────────────────────────────────────────
  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    BorderRadius? borderRadius,
    Color? borderColor,
    double blurSigma = 12,
    Color? bgColor,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor ?? _glassColor,
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: Border.all(
              color: borderColor ?? _glassBorder,
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _glassColor,
              border: Border.all(color: _glassBorderActive, width: 1.5),
            ),
            child: Icon(Icons.shield_rounded, color: _textWhite, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'VURTAX X RAT',
            style: TextStyle(
              color: _textWhite,
              fontFamily: 'Astral',
              fontWeight: FontWeight.w900,
              fontSize: 19,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _glassBorderActive, width: 1.5),
              color: _glassColor,
            ),
            child: Text(
              'v1.0',
              style: TextStyle(
                color: _textWhite,
                fontFamily: 'Astral',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return _glassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _glassBorderActive, width: 2.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.person, color: _textWhite, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username.toUpperCase(),
                      style: const TextStyle(
                        color: _textWhite,
                        fontFamily: 'Astral',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _roleDisplayName(widget.role).toUpperCase(),
                      style: TextStyle(
                        color: _roleColor(widget.role),
                        fontFamily: 'Astral',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _glassColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, color: _textGrey, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      widget.expiredDate,
                      style: TextStyle(
                        color: _textWhite,
                        fontFamily: 'Astral',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              color: _blackColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _glassBorder),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  Icons.bug_report_rounded, 
                  _accent,
                  '${widget.listBug.length}', 
                  'Total Bugs'
                ),
                _buildStatDivider(),
                _buildStatItem(
                  Icons.bolt_rounded, 
                  _accentDark,
                  'GACOR', 
                  'Success Rate'
                ),
                _buildStatDivider(),
                _buildStatItem(
                  Icons.check_circle_rounded, 
                  _accentLight,
                  'ACTIVE', 
                  'Status'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  color: _textWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  fontFamily: 'Astral')),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(
                  color: _textGrey, fontSize: 9, fontFamily: 'Astral')),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 52, color: _glassBorder);
  }

  // ─── BUILD TARGET INPUT DENGAN MODE GROUP ────────────────────────
  Widget _buildNomorDanBugPanel() {
    return _glassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android_rounded, color: _textWhite, size: 18),
              const SizedBox(width: 8),
              Text(
                'TARGET',
                style: TextStyle(
                  color: _textWhite,
                  fontFamily: 'Astral',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _blackColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _glassBorder),
                ),
                child: Row(
                  children: [
                    _buildModeTab('NOMOR', _selectedBugMode == 'number'),
                    const SizedBox(width: 4),
                    _buildModeTab('GROUP', _selectedBugMode == 'group'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: _glassColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _glassBorder, width: 1),
                ),
                child: TextField(
                  controller: targetController,
                  style: TextStyle(color: _textWhite, fontFamily: 'Astral', fontSize: 15),
                  cursorColor: _textWhite,
                  keyboardType: _selectedBugMode == "number" ? TextInputType.phone : TextInputType.url,
                  decoration: InputDecoration(
                    hintText: _selectedBugMode == "number" 
                        ? '62xxxxxxxxxx' 
                        : 'https://chat.whatsapp.com/...',
                    hintStyle: TextStyle(color: _textGrey.withOpacity(0.5), fontFamily: 'Astral'),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        _selectedBugMode == "number" 
                            ? Icons.language_rounded 
                            : Icons.link_rounded,
                        color: _textGrey,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Icon(Icons.bug_report, color: _textWhite, size: 20),
              const SizedBox(width: 8),
              Text(
                'PILIH BUG',
                style: TextStyle(
                  color: _textWhite,
                  fontFamily: 'Astral',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.listBug.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final bug = widget.listBug[index];
                final bugId = bug['bug_id'] as String? ?? '$index';
                final bugName = bug['bug_name'] as String? ?? 'BUG';
                final isSelected = _selectedBugId == bugId;

                final offsetY = _bugOffsets[bugId] ?? 0.0;

                return Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final controller = _bugAnimations[bugId];
                      if (controller != null) {
                        controller.forward(from: 0).then((_) {
                          controller.reverse();
                        });
                      }
                      
                      setState(() {
                        _selectedBugId = bugId;
                      });
                    },
                    child: Transform.translate(
                      offset: Offset(0, -offsetY * 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 200,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? _accent.withOpacity(0.3)
                                  : _accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? _accent 
                                    : _accent.withOpacity(0.3),
                                width: isSelected ? 2 : 1.2,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: _accent.withOpacity(0.3), 
                                  blurRadius: 25, 
                                  spreadRadius: 3
                                )
                              ] : [],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  color: isSelected ? _textWhite : _textGrey,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        bugName,
                                        style: TextStyle(
                                          color: isSelected ? _textWhite : _textGrey,
                                          fontFamily: 'Astral',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.visible,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        bugId.toLowerCase(),
                                        style: TextStyle(
                                          color: isSelected 
                                              ? _textWhite.withOpacity(0.7) 
                                              : _textGrey,
                                          fontFamily: 'Astral',
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: _green,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.listBug.length, (i) {
              final bug = widget.listBug[i];
              final bugId = bug['bug_id'] as String? ?? '$i';
              final isActive = _selectedBugId == bugId;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: isActive ? 18 : 6,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? _accent : _glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBugMode = label == 'NOMOR' ? 'number' : 'group';
          targetController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _accent.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isSelected 
              ? Border.all(color: _accent.withOpacity(0.5)) 
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _textWhite : _textGrey,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Astral',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSenderPanel() {
    return _glassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: _textWhite, size: 18),
              const SizedBox(width: 6),
              Text(
                'PILIH SENDER',
                style: TextStyle(
                  color: _textWhite,
                  fontFamily: 'Astral',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _fetchSenderData();
                },
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _glassColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _glassBorder),
                  ),
                  child: (_isLoadingSenders || _loadingSender)
                      ? Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: _textWhite),
                        )
                      : Icon(Icons.refresh_rounded, color: _textGrey, size: 14),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _glassBorderActive),
                  color: _glassColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _textWhite,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _loadingSender
                          ? '-- sender online'
                          : '${_privateSenderCount + _globalSenderCount} sender online',
                      style: TextStyle(
                          color: _textWhite,
                          fontFamily: 'Astral',
                          fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // ✅ FIX: Reset response message saat ganti sender
                    setState(() {
                      _selectedSender = 'private';
                      _responseMessage = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 120,
                    decoration: BoxDecoration(
                      color: _glassColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedSender == 'private'
                            ? _glassBorderActive
                            : _glassBorder,
                        width: 1.5,
                      ),
                      boxShadow: _selectedSender == 'private'
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: _selectedSender == 'private'
                              ? _textWhite
                              : _textGrey,
                          size: 30,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pribadi',
                          style: TextStyle(
                            color: _selectedSender == 'private'
                                ? _textWhite
                                : _textGrey,
                            fontFamily: 'Astral',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _privateSenderCount == 0
                            ? Text(
                                '✕ Kosong',
                                style: TextStyle(
                                  color: _selectedSender == 'private'
                                      ? _textGrey
                                      : _red,
                                  fontFamily: 'Astral',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              )
                            : Text(
                                '$_privateSenderCount sender',
                                style: TextStyle(
                                  color: _selectedSender == 'private'
                                      ? _textWhite
                                      : _textWhite,
                                  fontFamily: 'Astral',
                                  fontSize: 10,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!canAccessGlobalSender) {
                      _showAlert('❌ Akses Ditolak',
                          'Sender Global hanya untuk Developer, Founder, Kingz, High Owner, Owner, TK, Admin & VIP!');
                      return;
                    }
                    // ✅ FIX: Reset response message saat ganti sender
                    setState(() {
                      _selectedSender = 'global';
                      _responseMessage = null;
                    });
                    _fetchGlobalSenders();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 120,
                    decoration: BoxDecoration(
                      color: _glassColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedSender == 'global'
                            ? _glassBorderActive
                            : _glassBorder,
                        width: 1.5,
                      ),
                      boxShadow: _selectedSender == 'global'
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: double.infinity),
                            Icon(
                              Icons.public_rounded,
                              color: _selectedSender == 'global'
                                  ? _textWhite
                                  : _textGrey,
                              size: 30,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Global',
                              style: TextStyle(
                                color: _selectedSender == 'global'
                                    ? _textWhite
                                    : _textGrey,
                                fontFamily: 'Astral',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _globalSenderCount == 0
                                ? Text(
                                    '✕ Kosong',
                                    style: TextStyle(
                                      color: _selectedSender == 'global'
                                          ? _textGrey
                                          : _red,
                                      fontFamily: 'Astral',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  )
                                : Text(
                                    '$_globalSenderCount sender',
                                    style: TextStyle(
                                      color: _selectedSender == 'global'
                                          ? _textWhite
                                          : _textWhite,
                                      fontFamily: 'Astral',
                                      fontSize: 10,
                                    ),
                                  ),
                          ],
                        ),
                        if (!canAccessGlobalSender)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _amber,
                                border: Border.all(
                                    color: Colors.black26, width: 1.2),
                              ),
                              child: const Icon(Icons.lock_rounded,
                                  color: Colors.white, size: 10),
                            ),
                          ),
                        if (_selectedSender == 'global' && _globalSenderCount > 0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _textWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ON',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Astral',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_selectedSender == 'global' && _globalSenders.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _glassColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.format_list_bulleted_rounded,
                        color: _textGrey, size: 13),
                    const SizedBox(width: 6),
                    Text('${_globalSenders.length} sender aktif',
                        style: TextStyle(
                            color: _textGrey,
                            fontSize: 11,
                            fontFamily: 'Astral',
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  ...(_globalSenders.take(5).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _accent)),
                          const SizedBox(width: 8),
                          Text(s,
                              style: TextStyle(
                                  color: _textWhite,
                                  fontSize: 11,
                                  fontFamily: 'Astral')),
                        ]),
                      ))),
                  if (_globalSenders.length > 5)
                    Text('+ ${_globalSenders.length - 5} lainnya...',
                        style: TextStyle(color: _textGrey, fontSize: 10, fontFamily: 'Astral')),
                ],
              ),
            )
          else
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: _textGrey, size: 13),
                const SizedBox(width: 6),
                Text(
                  'Sender global: unlimited (PEMULA)',
                  style: TextStyle(
                      color: _green,
                      fontFamily: 'Astral',
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                _glassColor,
                _glassColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white
                    .withOpacity(0.02 + _pulseController.value * 0.05),
                blurRadius: 12 + _pulseController.value * 6,
                spreadRadius: 0.5,
              ),
            ],
            border: Border.all(
              color: _glassBorder,
              width: 1.2,
            ),
          ),
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendBug,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isSending
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: _textWhite, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_rounded,
                          color: _textWhite, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'KIRIM BUG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          fontFamily: 'Astral',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildResponseMessage() {
    if (_responseMessage == null) return const SizedBox.shrink();

    final parts = _responseMessage!.split('|');
    final type = parts[0];
    final msg = parts.length > 1 ? parts[1] : '';

    Color color;
    IconData icon;
    String title;
    switch (type) {
      case 'success':
        color = _green;
        icon = Icons.check_circle_outline;
        title = 'Berhasil';
        break;
      case 'warning':
        color = _amber;
        icon = Icons.warning_rounded;
        title = 'Peringatan';
        break;
      default:
        color = _red;
        icon = Icons.error_outline;
        title = 'Gagal';
    }

    return FadeTransition(
      opacity: _resultFade,
      child: SlideTransition(
        position: _resultSlide,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _glassColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _glassBorderActive),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.12)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                color: color,
                                fontFamily: 'Astral',
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(msg,
                            style: TextStyle(
                                color: _textGrey,
                                fontFamily: 'Astral',
                                fontSize: 12,
                                height: 1.4)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _responseMessage = null);
                      _resultCtrl.reset();
                    },
                    child: Icon(Icons.close_rounded, color: _textGrey, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _videoController.value.isInitialized
                ? VideoPlayer(_videoController)
                : Container(color: _bgDark),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(),
                Container(height: 1, color: _glassBorder),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 14),
                        _buildNomorDanBugPanel(),
                        const SizedBox(height: 14),
                        _buildSenderPanel(),
                        const SizedBox(height: 20),
                        _buildSendButton(),
                        _buildResponseMessage(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}