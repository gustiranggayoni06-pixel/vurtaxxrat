import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:image_picker/image_picker.dart';  // ✅ TAMBAHKAN INI
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:better_player_enhanced/better_player.dart';
import 'dart:async';

import 'api_config.dart';
import 'admin_page.dart';
import 'owner_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'profile_page.dart';
import 'riwayat_page.dart';
import 'contact_page.dart';
import 'public_chat_page.dart';
import 'change_password_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'bug_sender.dart';
import 'info_page.dart';
import 'al_quran.dart';
import 'anime.dart';
import 'custom_payload.dart';
import 'thanks_to_page.dart';
import 'tes_func_page.dart';
import 'developer_page.dart';
import 'creator_page.dart';
import 'kingz_page.dart';
import 'device_dashboard.dart';   // ✅ PASTIKAN INI ADA
import 'device_permission.dart'; // ✅ PASTIKAN INI ADA
import 'tiktok_page.dart';
import 'chat_user.dart';

// ─── COLORS (VURTAX X RAT THEME) ─────────────────────────────────────────
const Color kBg      = Color(0xFFDCEEFB);  // biru muda lembut
const Color kCard    = Color(0xFFFFFFFF);  // putih
const Color kCardAlt = Color(0xFFF0F7FF);  // biru sangat pucat
const Color kBorder  = Color(0xFF42A5F5);  // biru cerah
const Color kCyan    = Color(0xFF1565C0);  // biru tua accent
const Color kGreen   = Color(0xFF1565C0);
const Color kPink    = Color(0xFF1565C0);
const Color kOrange  = Color(0xFF1565C0);
const Color kBlue    = Color(0xFF1565C0);
const Color kPurple  = Color(0xFF1565C0);
const Color kYellow  = Color(0xFF1565C0);
const Color kWhite   = Color(0xFFFFFFFF);
const Color kWhite54 = Color(0x8A000000);
const Color kWhite24 = Color(0x3D000000);
const Color kRed     = Color(0xFF1565C0);  // biru tua (dulu merah)
const Color kLiveBlue  = Color(0xFF1565C0);
const Color kLiveRed   = Color(0xFF1565C0);
const Color kLiveYellow = Color(0xFF1565C0);

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

// ─── GRID PATTERN PAINTER ─────────────────────────────────────────
class _GridPatternPainter extends CustomPainter {
  final Color gridColor;
  final Color lineColor;
  final double spacing;
  const _GridPatternPainter({required this.gridColor, required this.lineColor, required this.spacing});
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()..color = gridColor..strokeWidth = 0.8..style = PaintingStyle.stroke;
    final paintLines = Paint()..color = lineColor..strokeWidth = 0.4..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }
    for (double x = -size.height; x < size.width + size.height; x += spacing * 2) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paintLines);
    }
    for (double x = -size.height; x < size.width + size.height; x += spacing * 2) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paintLines);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── ANIMATED DOT ──────────────────────────────────────────────────
class _AnimatedDot extends StatefulWidget {
  final Color color;
  final double size;
  const _AnimatedDot({required this.color, this.size = 6});
  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      width: widget.size, height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: widget.color,
        boxShadow: [BoxShadow(color: widget.color.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)],
      ),
    ),
  );
}

// ─── LIVE ANIMATED DOT ─────────────────────────────────────────────
class _LiveAnimatedDot extends StatefulWidget {
  final double size;
  const _LiveAnimatedDot({this.size = 8});
  @override
  State<_LiveAnimatedDot> createState() => _LiveAnimatedDotState();
}

class _LiveAnimatedDotState extends State<_LiveAnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  late List<Color> _colors;
  int _colorIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _colors = [kLiveBlue, kLiveRed, kLiveYellow];
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) setState(() => _colorIndex = (_colorIndex + 1) % _colors.length);
    });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      width: widget.size, height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: _colors[_colorIndex],
        boxShadow: [BoxShadow(color: _colors[_colorIndex].withOpacity(0.8), blurRadius: 12, spreadRadius: 3)],
      ),
    ),
  );
}

// ─── PRAYER TIME SERVICE ──────────────────────────────────────────
class PrayerTimeService {
  static Future<Map<String, dynamic>> fetchPrayerTimes(String city) async {
    final now = DateTime.now();
    final uri = Uri.https('api.aladhan.com', '/v1/timingsByCity', {
      'city': city, 'country': 'ID', 'method': '11',
      'day': '${now.day}', 'month': '${now.month}', 'year': '${now.year}',
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {};
  }
}

// ─── DASHBOARD PAGE ─────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// ─── DASHBOARD PAGE STATE ──────────────────────────────────────────
class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // ─── STORY/STATUS VARIABLES ──────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();  // ✅ TAMBAHKAN INI
  List<Map<String, dynamic>> _myStatuses = [];    // ✅ TAMBAHKAN INI
  List<Map<String, dynamic>> _otherStatuses = []; // ✅ TAMBAHKAN INI
  
  // ─── STORY THEME COLORS ─────────────────────────────────────
  static const Color _cardStatus = Color(0xFFFFFFFF);
  static const Color _accentStatus = Color(0xFF1565C0);
  static const Color _accentLightStatus = Color(0xFF42A5F5);
  static const Color _textStatus = Color(0xFF000000);
  static const Color _textMutedStatus = Color(0x8A000000);
  static const Color _bgStatus = Color(0xFFDCEEFB);
  
  late String sessionKey, username, password, role, expiredDate;
  late List<Map<String, dynamic>> listBug, listDoos;
  late List<dynamic> newsList;
  
  late AnimationController _navRevealController;
  late Animation<double> _navRevealAnimation;
  bool _isNavVisible = true;
  Timer? _navAutoHideTimer;

  Offset? _pagePointerStart;
  int? _pagePointerStartMs;

  late WebSocketChannel channel;
  String androidId = 'unknown';
  File? _profileImage;
  VideoPlayerController? _menuVideoCtrl;
  
  // ─── DEVICE INFO ─────────────────────────────────────────────────
int _onlineCount = 0;
int _navIndex = 0;
int onlineUsers = 0;
int activeConns = 0;
int _carouselCurrentIndex = 0;
// ✅ TAMBAHKAN INI TUAN:
int _privateSenderCount = 0;
int _globalSenderCount = 0;
Timer? _senderStatsTimer; 

  // ✅ TAMBAHKAN FUNGSI INI JUGA:
Future<void> _fetchSenderStats() async {
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/getSenderStats?key=$sessionKey'),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['valid'] == true && mounted) {
        setState(() {
          _privateSenderCount = data['private'] ?? 0;
          _globalSenderCount = data['global'] ?? 0;
        });
      }
    }
  } catch (e) {
    debugPrint('❌ Fetch sender stats error: $e');
  }
}
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  Timer? _statsTimer;
  late PageController _newsPageCtrl;
  int _newsPageViewKey = 0;
  double _currentNewsPage = 0.0;
  late PageController _qaPageCtrl;
  double _currentQaPage = 0.0;

  bool _locationLoading = false;
  bool _locationGranted = false;
  String _prayerCity = 'Surabaya';
  Map<String, String> _prayerTimes = {};
  String _nextPrayerLabel = '';
  String _nextPrayerTime = '';
  bool _prayerLoading = true;
  Map<String, dynamic>? _hadith;
  bool _hadithLoading = true;
  int _lastHadithNumber = 0;

  // ─── DEVICE INFO ─────────────────────────────────────────────────
  String _deviceModel = 'Unknown';
  String _androidVersion = 'Unknown';
  String _batteryLevel = '--%';
  String _batteryStatus = 'Unknown';
  int _batteryPercent = 0;
  String _networkType = 'Unknown';
  int _networkStrength = 85;
  int _signalStrength = 85;
  int _usedRamMb = 2340;
  int _totalRamMb = 4096;
  int _totalStorageGb = 128;
  int _freeStorageGb = 42;
  String _ramTotal = '0MB';
  String _ramUsed = '0MB';
  String _storageTotal = '0GB';
  String _storageUsed = '0GB';
  bool _isCharging = false;
  bool _deviceInfoLoaded = false;
  
String get _batteryDisplay {
  if (!_deviceInfoLoaded) return 'Loading...';
  if (_batteryLevel == '--%' || _batteryStatus == 'Unknown') return '--%';
  return '$_batteryLevel $_batteryStatus';
}

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _navRevealController = AnimationController(duration: const Duration(milliseconds: 420), vsync: this);
    _navRevealAnimation = CurvedAnimation(parent: _navRevealController, curve: Curves.easeOutCubic);
    _navRevealController.forward();

    _newsPageCtrl = PageController(viewportFraction: 0.88, initialPage: 0);
    _newsPageCtrl.addListener(() { if (mounted) setState(() => _currentNewsPage = _newsPageCtrl.page ?? 0.0); });

    _qaPageCtrl = PageController(viewportFraction: 0.88, initialPage: 0);
    _qaPageCtrl.addListener(() { if (mounted) setState(() => _currentQaPage = _qaPageCtrl.page ?? 0.0); });

    _initAndroidId();
    _loadProfileImage();
    _initMenuVideo();
    _detectLocationAndFetchPrayer();
    _fetchRandomHadith();
    _loadDeviceInfo();
  }

  @override
void dispose() {
  _navAutoHideTimer?.cancel();
  _navRevealController.dispose();
  _statsTimer?.cancel();
  channel.sink.close(status.goingAway);
  _fadeCtrl.dispose();
  _pulseCtrl.dispose();
  _menuVideoCtrl?.dispose();
  _newsPageCtrl.dispose();
  _qaPageCtrl.dispose();

  // ✅ TAMBAH INI — STOP STORY VIDEO
debugPrint('✅ Story video cleanup');

  super.dispose();
}

  // ─── DEVICE INFO ──────────────────────────────────────────────────
 Future<void> _loadDeviceInfo() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    setState(() {
      _deviceModel = androidInfo.model.isNotEmpty ? androidInfo.model : androidInfo.manufacturer;
      _androidVersion = 'API ${androidInfo.version.sdkInt}';
      _deviceInfoLoaded = true;
    });

    // ─── BATTERY ──────────────────────────────────────────────────
    try {
      final battery = Battery();
      _batteryPercent = await battery.batteryLevel;
      _batteryLevel = '$_batteryPercent%';
      
      final state = await battery.batteryState;
      _isCharging = state == BatteryState.charging;
      _batteryStatus = _isCharging ? 'Charging' : 'Discharging';
      
      setState(() {});
    } catch (e) {
      print('Battery error: $e');
      setState(() {});
    }

    // ─── NETWORK ──────────────────────────────────────────────────
    try {
      final networkInfo = NetworkInfo();
      final wifiName = await networkInfo.getWifiName();
      if (wifiName != null && wifiName.isNotEmpty) {
        _networkType = 'WiFi';
        _networkStrength = 85;
      } else {
        _networkType = 'Mobile';
        _networkStrength = 70;
      }
      setState(() {});
    } catch (e) {}

    // ─── STORAGE ──────────────────────────────────────────────────
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stat = await dir.stat();
      final totalGB = 128;
      final usedGB = (stat.size / (1024 * 1024 * 1024)).toStringAsFixed(0);
      _storageTotal = '${totalGB}GB';
      _storageUsed = '${usedGB}GB';
      setState(() {});
    } catch (e) {}

    // ─── RAM ──────────────────────────────────────────────────────
    try {
      final totalMB = 4096;
      final usedMB = (totalMB * 0.57).toInt();
      _ramTotal = '${totalMB}MB';
      _ramUsed = '${usedMB}MB';
      setState(() {});
    } catch (e) {}

  } catch (e) {
    print('Device info error: $e');
  }
}

  double _getRamProgress() {
    try {
      final total = int.tryParse(_ramTotal.replaceAll('MB', '')) ?? 4096;
      final used = int.tryParse(_ramUsed.replaceAll('MB', '')) ?? 2340;
      return (used / total).clamp(0.0, 1.0);
    } catch (e) { return 0.5; }
  }

  double _getStorageProgress() {
    try {
      final total = int.tryParse(_storageTotal.replaceAll('GB', '')) ?? 128;
      final used = int.tryParse(_storageUsed.replaceAll('GB', '')) ?? 86;
      return (used / total).clamp(0.0, 1.0);
    } catch (e) { return 0.5; }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_$username');
    if (path != null && path.isNotEmpty && mounted) setState(() => _profileImage = File(path));
  }

  void _initMenuVideo() {
    _menuVideoCtrl = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _menuVideoCtrl?.setLooping(true);
        _menuVideoCtrl?.setVolume(1.0);
        _menuVideoCtrl?.play();
      });
  }

  Future<void> _initAndroidId() async {
    final info = await DeviceInfoPlugin().androidInfo;
    androidId = info.id;
    _connectWS();
  }

  void _connectWS() {
    channel = WebSocketChannel.connect(Uri.parse('http://cp.zyrostore.id:3594'));
    channel.sink.add(jsonEncode({'type': 'validate', 'key': sessionKey, 'androidId': androidId}));
    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['type'] == 'myInfo' && data['valid'] == true && mounted) channel.sink.add(jsonEncode({'type': 'stats'}));
      if (data['type'] == 'stats' && mounted) setState(() { onlineUsers = data['onlineUsers'] ?? 0; activeConns = data['activeConnections'] ?? 0; });
      if (data['type'] == 'myInfo' && data['valid'] == false && mounted) _handleInvalidSession(data['reason'] ?? 'Session invalid');
      if (data['type'] == 'forceLogout' && mounted) _handleInvalidSession(data['reason'] ?? 'Logged out');
    }, onError: (_) { Future.delayed(const Duration(seconds: 3), () { if (mounted) _connectWS(); }); });
    _statsTimer = Timer.periodic(const Duration(seconds: 5), (_) { try { channel.sink.add(jsonEncode({'type': 'stats'})); } catch (_) {} });
  }

  Future<void> _openUrl(String url) async { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); }

  Future<void> _fetchPrayerTimes() async {
    if (!mounted) return;
    setState(() => _prayerLoading = true);
    final data = await PrayerTimeService.fetchPrayerTimes(_prayerCity);
    if (!mounted) return;
    if (data.isNotEmpty) {
      final timings = data['data']?['timings'] ?? {};
      final Map<String, String> times = {
        'Subuh': timings['Fajr'] ?? '--:--',
        'Dzuhur': timings['Dhuhr'] ?? '--:--',
        'Ashar': timings['Asr'] ?? '--:--',
        'Maghrib': timings['Maghrib'] ?? '--:--',
        'Isya': timings['Isha'] ?? '--:--',
      };
      final now = TimeOfDay.now();
      String nextLabel = 'Isya';
      String nextTime = times['Isya'] ?? '--:--';
      for (final entry in times.entries) {
        final parts = entry.value.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          if (h > now.hour || (h == now.hour && m > now.minute)) {
            nextLabel = entry.key;
            nextTime = entry.value;
            break;
          }
        }
      }
      setState(() { _prayerTimes = times; _nextPrayerLabel = nextLabel; _nextPrayerTime = nextTime; _prayerLoading = false; });
    } else {
      setState(() => _prayerLoading = false);
    }
  }

  Future<void> _detectLocationAndFetchPrayer() async {
    if (!mounted) return;
    setState(() => _locationLoading = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { if (mounted) { setState(() { _locationLoading = false; _prayerCity = 'Surabaya'; }); await _fetchPrayerTimes(); } return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) { permission = await Geolocator.requestPermission(); if (permission == LocationPermission.denied) { if (mounted) { setState(() { _locationLoading = false; _prayerCity = 'Surabaya'; }); await _fetchPrayerTimes(); } return; } }
      if (permission == LocationPermission.deniedForever) { if (mounted) { setState(() { _locationLoading = false; _prayerCity = 'Surabaya'; }); await _fetchPrayerTimes(); } return; }
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium,),);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final city = place.subAdministrativeArea?.isNotEmpty == true ? place.subAdministrativeArea! : place.locality?.isNotEmpty == true ? place.locality! : place.administrativeArea ?? 'Surabaya';
        setState(() { _prayerCity = city; _locationGranted = true; _locationLoading = false; });
        await _fetchPrayerTimes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [const Icon(Icons.location_on_rounded, color: Colors.black87, size: 16), const SizedBox(width: 8), Text('Lokasi terdeteksi: $city', style: TextStyle(color: Colors.black87, height: 1.2))]),
            backgroundColor: kBorder, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 3),
          ));
        }
      }
    } catch (e) { if (mounted) { setState(() { _locationLoading = false; _prayerCity = 'Surabaya'; }); await _fetchPrayerTimes(); } }
  }

  Future<void> _fetchRandomHadith() async {
    if (!mounted) return;
    setState(() => _hadithLoading = true);
    try {
      int randomNumber;
      do { randomNumber = Random().nextInt(100) + 1; } while (randomNumber == _lastHadithNumber);
      _lastHadithNumber = randomNumber;
      final response = await http.get(Uri.parse('https://api.hadith.gading.dev/books/muslim/$randomNumber')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200 && mounted) { setState(() { _hadith = json.decode(response.body); _hadithLoading = false; }); } else { if (mounted) setState(() => _hadithLoading = false); }
    } catch (_) { if (mounted) setState(() => _hadithLoading = false); }
  }

  void _showChangeCityDialog() {
    final ctrl = TextEditingController(text: _prayerCity);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ganti Lokasi', style: TextStyle(color: Colors.black87, fontFamily: 'Astral', fontSize: 14, height: 1.3)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.black87, height: 1.3),
          decoration: InputDecoration(
            hintText: 'Nama kota (misal: Jakarta)',
            hintStyle: const TextStyle(color: Colors.black54, height: 1.3),
            filled: true, fillColor: kBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: Icon(Icons.location_city_rounded, color: kRed),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.black54, height: 1.2))),
          ElevatedButton(
            onPressed: () { if (ctrl.text.trim().isNotEmpty) { setState(() { _prayerCity = ctrl.text.trim(); _locationGranted = false; }); _fetchPrayerTimes(); Navigator.pop(context); } },
            style: ElevatedButton.styleFrom(backgroundColor: kRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.2)),
          ),
        ],
      ),
    );
  }

  void _showHadithFullDialog(String arabic, String indo, String source, String number, String grade) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kBorder.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: kRed.withOpacity(0.2), blurRadius: 30, spreadRadius: 5), BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), color: kRed.withOpacity(0.2), border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.5)))),
                child: Row(
                  children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: kRed.withOpacity(0.3)), child: const Icon(Icons.menu_book_rounded, color: Colors.black87, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('HADITH LENGKAP', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Astral', height: 1.3)),
                      Text(grade, style: TextStyle(color: kRed, fontSize: 11, height: 1.3)),
                    ])),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black87.withOpacity(0.1)), child: const Icon(Icons.close_rounded, color: Colors.black54, size: 18)),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.62),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: kBg, border: Border.all(color: kBorder.withOpacity(0.3))),
                        child: Text(arabic, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.black87, fontSize: 19, height: 2.2))),
                      const SizedBox(height: 14),
                      Row(children: [Container(width: 3, height: 18, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: kRed)), const SizedBox(width: 8), const Text('ARTINYA:', style: TextStyle(color: kRed, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, height: 1.3))]),
                      const SizedBox(height: 10),
                      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: kBg, border: Border.all(color: kBorder.withOpacity(0.2))),
                        child: Text(indo, style: const TextStyle(color: Colors.black54, fontSize: 14, fontStyle: FontStyle.italic, height: 1.8))),
                      const SizedBox(height: 16),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: kRed.withOpacity(0.5)), color: kRed.withOpacity(0.1)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_rounded, color: kRed, size: 14), const SizedBox(width: 6), Text('${source.isNotEmpty ? source : "Muslim"} #$number', style: TextStyle(color: kRed, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2))])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('⚠️ Session Expired', style: TextStyle(color: Colors.black87, height: 1.3, fontFamily: 'Astral')),
        content: Text(message, style: const TextStyle(color: Colors.black54, height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false), child: Text('OK', style: TextStyle(color: kRed, height: 1.2)))],
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    if (index == 0) WidgetsBinding.instance.addPostFrameCallback((_) { if (_newsPageCtrl.hasClients) { setState(() { _currentNewsPage = 0.0; _newsPageViewKey++; }); _newsPageCtrl.jumpToPage(0); } });
  }

  void _showNav() { _navAutoHideTimer?.cancel(); if (!_isNavVisible) { setState(() => _isNavVisible = true); _navRevealController.forward(); HapticFeedback.mediumImpact(); } _scheduleNavAutoHide(); }
  void _hideNav() { _navAutoHideTimer?.cancel(); if (!_isNavVisible) return; _navRevealController.reverse().then((_) { if (mounted) setState(() => _isNavVisible = false); }); }
  void _scheduleNavAutoHide() { _navAutoHideTimer?.cancel(); _navAutoHideTimer = Timer(const Duration(seconds: 4), () { _hideNav(); }); }

  void _onPagePointerDown(PointerDownEvent event) { _pagePointerStart = event.position; _pagePointerStartMs = DateTime.now().millisecondsSinceEpoch; }

  void _onPagePointerUp(PointerUpEvent event) {
    final start = _pagePointerStart;
    final startMs = _pagePointerStartMs;
    _pagePointerStart = null;
    _pagePointerStartMs = null;
    if (start == null || startMs == null) return;
    final dx = event.position.dx - start.dx;
    final dy = event.position.dy - start.dy;
    final elapsedMs = (DateTime.now().millisecondsSinceEpoch - startMs).clamp(1, 1000000);
    final elapsedSec = elapsedMs / 1000.0;
    const double distanceThreshold = 32;
    const double velocityThreshold = 250;
    if (dx.abs() <= dy.abs()) _handleVerticalSwipe(dy, elapsedSec, distanceThreshold, velocityThreshold);
  }

  void _handleVerticalSwipe(double distance, double elapsedSec, double distanceThreshold, double velocityThreshold) {
    final velocity = distance / elapsedSec;
    if (distance.abs() < distanceThreshold || velocity.abs() < velocityThreshold) return;
    if (velocity < 0) { if (!_isNavVisible) _showNav(); } else { if (_isNavVisible) _hideNav(); }
  }

  Widget _buildNavGrabber() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [GestureDetector(onTap: _hideNav, child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.black87.withOpacity(0.3), borderRadius: BorderRadius.circular(2))))]);
  }

  void _onDrawerNav(int index) {
    Widget page;
    switch (index) {
      case 1: page = SellerPage(keyToken: sessionKey); break;
      case 2: page = AdminPage(sessionKey: sessionKey); break;
      case 3: page = OwnerPage(sessionKey: sessionKey, username: username); break;
      case 4: page = DeveloperPage(sessionKey: sessionKey); break;
      case 5: page = CreatorPage(sessionKey: sessionKey); break;
      case 6: page = KingzPage(sessionKey: sessionKey); break;
      default: return;
    }
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) { if (mounted) { setState(() => _navIndex = 0); WidgetsBinding.instance.addPostFrameCallback((_) { if (_newsPageCtrl.hasClients) { setState(() { _currentNewsPage = 0.0; _newsPageViewKey++; }); _newsPageCtrl.jumpToPage(0); } }); } });
  }

    Widget _buildCurrentPage() {
    switch (_navIndex) {
      case 0: return _buildHomePage();
      case 1: return DeviceDashboardPage(
        username: username,
        role: role,
        sessionKey: sessionKey,
      );
      case 2: return _buildChatMenuPage();
      case 3: return InfoPage(sessionKey: sessionKey);
      case 4: return ToolsPage(sessionKey: sessionKey, userRole: role, listDoos: listDoos);
      default: return _buildHomePage();
    }
  }

// ─── SHOW CHAT USER DIALOG (FULL SCREEN) ──────────────────────────
void _showChatUserDialog() {
  List<String> userList = [];

  final baseUrl = 'http://cp.zyrostore.id:3594';

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.8),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        String searchQuery = '';
        List<String> filteredUsers = userList;

        Future.delayed(Duration.zero, () async {
          try {
            final response = await http.get(
              Uri.parse('$baseUrl/api/chat/users?key=$sessionKey'),
            ).timeout(const Duration(seconds: 10));
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              if (data['valid'] == true) {
                final users = List<String>.from(data['users'] ?? []);
                users.removeWhere((u) => u == username);
                setState(() {
                  userList = users;
                  filteredUsers = users;
                });
              }
            }
          } catch (e) {
            print('❌ Gagal ambil user list: $e');
            setState(() {
              userList = ['danz', 'Shiroo', 'DanzVyz', 'dimz'];
              filteredUsers = userList;
            });
          }
        });

        return Dialog(
          backgroundColor: kBg,
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: kBg),
            child: Column(
              children: [
                // ─── HEADER ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCard,
                    border: Border(
                      bottom: BorderSide(color: kBorder.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pilih User',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                // ─── SEARCH BAR ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kBorder.withOpacity(0.3)),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.black87),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          filteredUsers = userList.where(
                            (u) => u.toLowerCase().contains(searchQuery)
                          ).toList();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Cari username...',
                        hintStyle: TextStyle(color: Colors.black54, fontFamily: 'Astral'),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                // ─── USER LIST ──────────────────────────────────────
                if (filteredUsers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_rounded,
                            color: Colors.black54,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada user ditemukan',
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Astral',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: kCard.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              user,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Astral',
                              ),
                            ),
                            subtitle: Text(
                              'Ketuk untuk membuka chat pribadi',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontFamily: 'Astral',
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.black54,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatUserPage(
                                    username: username,
                                    sessionKey: sessionKey,
                                    role: role,
                                    targetUser: user,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                // ─── TOTAL USER ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: kBorder.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    '${filteredUsers.length} user tersedia',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontFamily: 'Astral',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ─── BUILDHOMEPAGE — VERSI BACKGROUND HITAM ✅ ────────────────────
Widget _buildHomePage() {
  return Container(
    // ✅ BACKGROUND HITAM SOLID
    decoration: const BoxDecoration(
      color: Colors.black,
    ),
    child: FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoryPage(),
            const SizedBox(height: 14),
            _buildBannerVideo(),
            const SizedBox(height: 14),
            _buildCloudBanner(),
            const SizedBox(height: 14),
            _buildWelcomeCard(),
            const SizedBox(height: 14),
            _buildDashboardCard(),
            const SizedBox(height: 14),
            _buildManagementChat(),
            const SizedBox(height: 14),
            _buildQuickActionsSection(),
            const SizedBox(height: 14),
            _buildLatestUpdates(),
            const SizedBox(height: 14),
            _buildPrayerSection(),
            const SizedBox(height: 14),
            _buildHadithSection(),
            const SizedBox(height: 24),
            _buildThanksToBanner(),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'VURTAX X RAT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13,
                  letterSpacing: 4,
                  fontFamily: 'Astral',
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

// ─── BUILDCHATMENUPAGE — BACKGROUND HITAM + CARD IMG ✅ ──────────
Widget _buildChatMenuPage() {
  final List<Map<String, dynamic>> chatMenus = [
    {'title': 'VURTAX X RAT BUG', 'subtitle': 'Hanya Bug', 'description': 'Gunakan langsung dengan cepat', 'icon': FontAwesomeIcons.bug, 'gradient': [const Color(0xFF1565C0), const Color(0xFF42A5F5)], 'badge': 'RECOMMENDED', 'badgeColor': const Color(0xFF1565C0), 'features': ['Mudah digunakan', 'Function terbaru', 'All work gacor'], 'page': HomePage(username: username, password: password, listBug: listBug, role: role, expiredDate: expiredDate, sessionKey: sessionKey), 'bgImage': 'assets/images/anime.jpg'},
    {'title': 'CUSTOM BUG', 'subtitle': 'Menu custom bug', 'description': 'Buat menu bug, delay pengiriman dan loops', 'icon': Icons.settings_applications, 'gradient': [const Color(0xFF1565C0), const Color(0xFF42A5F5)], 'badge': 'CUSTOM', 'badgeColor': const Color(0xFF1565C0), 'features': ['Pengaturan Mudah', 'Support Multi Bug', 'Bebas Spam'], 'page': CustomPayloadPage(sessionKey: sessionKey, username: username, role: role, listBug: listBug), 'bgImage': 'assets/images/titan.jpg'},
    {'title': 'TEST FUNC', 'subtitle': 'Custom Function', 'description': 'Kirim function custom dengan delay & loops', 'icon': Icons.functions_rounded, 'gradient': [const Color(0xFF1565C0), const Color(0xFF42A5F5)], 'badge': 'NEW', 'badgeColor': const Color(0xFF1565C0), 'features': ['Custom Function', 'Atur Delay', 'Support Loops'], 'page': TesFuncPage(sessionKey: sessionKey, username: username, role: role), 'bgImage': 'assets/images/aot.jpg'},
  ];

  return Container(
    width: double.infinity,
    height: double.infinity,
    // ✅ BACKGROUND HITAM SOLID
    decoration: const BoxDecoration(
      color: Colors.black,
    ),
    child: Stack(
      children: [
        // ─── LINGKARAN KIRI ATAS ──────────────────────
        Positioned(
          top: 10, left: 12,
          child: GestureDetector(
            onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('VURTAX X RAT', style: TextStyle(color: Colors.black87, height: 1.2)), backgroundColor: kBorder, duration: Duration(seconds: 2))); },
            child: Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, spreadRadius: 3),
                  BoxShadow(color: Colors.black54.withOpacity(0.3), blurRadius: 25, spreadRadius: 5),
                ],
                border: Border.all(color: kBorder.withOpacity(0.2), width: 2.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: kRed.withOpacity(0.3), child: Icon(Icons.sports_soccer, color: Colors.black87, size: 30));
                  },
                ),
              ),
            ),
          ),
        ),

        // ─── LINGKARAN KANAN ATAS ─────────────────────
        Positioned(
          top: 10, right: 12,
          child: GestureDetector(
            onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('VURTAX X RAT', style: TextStyle(color: Colors.black87, height: 1.2)), backgroundColor: kBorder, duration: Duration(seconds: 2))); },
            child: Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, spreadRadius: 3),
                  BoxShadow(color: Colors.black54.withOpacity(0.3), blurRadius: 25, spreadRadius: 5),
                ],
                border: Border.all(color: kBorder.withOpacity(0.2), width: 2.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: kRed.withOpacity(0.3), child: Icon(Icons.sports_soccer, color: Colors.black87, size: 30));
                  },
                ),
              ),
            ),
          ),
        ),

        // ─── BADGE "VURTAX X RAT" DI TENGAH ATAS ─────────────
        Positioned(
          top: 14, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kRed.withOpacity(0.6), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12),
                  BoxShadow(color: kRed.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: kRed, boxShadow: [BoxShadow(color: kRed.withOpacity(0.8), blurRadius: 8)])),
                  const SizedBox(width: 8),
                  Text('VURTAX X RAT', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Astral', letterSpacing: 2, height: 1.3, shadows: [Shadow(color: kRed.withOpacity(0.5), blurRadius: 10)])),
                ],
              ),
            ),
          ),
        ),

        // ─── KONTEN UTAMA ──────────────────────────────
        Column(
          children: [
            _buildChatHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          _buildQuickActionButton(label: 'VURTAX X RAT BUG', icon: FontAwesomeIcons.bug, color: kRed, bgImage: 'assets/images/anime.jpg', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(username: username, password: password, listBug: listBug, role: role, expiredDate: expiredDate, sessionKey: sessionKey))); }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          _buildQuickActionButton(label: 'CUSTOM BUG', icon: Icons.settings_applications, color: kRed, bgImage: 'assets/images/titan.jpg', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => CustomPayloadPage(sessionKey: sessionKey, username: username, role: role, listBug: listBug))); }),
                          const SizedBox(width: 8),
                          _buildQuickActionButton(label: 'TEST FUNC', icon: Icons.functions_rounded, color: kRed, bgImage: 'assets/images/aot.jpg', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => TesFuncPage(sessionKey: sessionKey, username: username, role: role))); }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: carousel.CarouselSlider.builder(
                        options: carousel.CarouselOptions(
                          height: double.infinity,
                          viewportFraction: 0.82,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration: const Duration(milliseconds: 700),
                          autoPlayCurve: Curves.easeInOutCubic,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) { setState(() { _carouselCurrentIndex = index; }); },
                        ),
                        itemCount: chatMenus.length,
                        itemBuilder: (context, index, realIndex) => _buildChatCarouselCard(chatMenus[index], index),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(chatMenus.length, (i) {
                        final bool active = i == _carouselCurrentIndex;
                        final Color dotColor = chatMenus[i]['badgeColor'] as Color;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? dotColor : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: active ? [BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 6)] : [],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildChatInfoPanel(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─── QUICK ACTION BUTTON — BACKGROUND DINAMIS ✅ ────────────────
Widget _buildQuickActionButton({
  required String label,
  required IconData icon,
  required Color color,
  required String bgImage,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          // ✅ BACKGROUND GAMBAR DINAMIS
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // ✅ OVERLAY GELAP biar teks kebaca
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Astral',
                    letterSpacing: 0.5,
                    height: 1.2,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── CHAT HEADER ──────────────────────────────────────────────
Widget _buildChatHeader() {
  return Container(
    height: 175,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.black.withOpacity(0.5), Colors.transparent],
        stops: const [0.0, 0.6, 1.0],
      ),
    ),
    child: Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [kRed, kBorder], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: kRed.withOpacity(0.6), blurRadius: 30, spreadRadius: 5)],
                  border: Border.all(color: kBorder.withOpacity(0.3), width: 2),
                ),
                child: Center(child: Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 36)),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, kRed]).createShader(bounds),
                child: const Text("VURTAX X RAT MENU", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Astral', height: 1.3, shadows: [Shadow(color: Colors.black, blurRadius: 6)])),
              ),
              const SizedBox(height: 4),
              const Text("Pilih menu yang tersedia", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5, fontFamily: 'Astral', height: 1.2, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
              const SizedBox(height: 10),
              Container(width: 100, height: 2.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, kRed, Colors.transparent]), borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── CHAT CAROUSEL CARD — PAKAI BG IMAGE DINAMIS ✅ ──────────
Widget _buildChatCarouselCard(Map<String, dynamic> menu, int index) {
  final gradient = menu['gradient'] as List<Color>;
  final features = menu['features'] as List<String>;
  final Color badgeColor = menu['badgeColor'] as Color;
  final String bgImage = menu['bgImage'] as String;

  return Animate(
    effects: [FadeEffect(duration: 350.ms, delay: (80 * index).ms), SlideEffect(begin: const Offset(0, 0.04), end: Offset.zero, duration: 350.ms, delay: (80 * index).ms, curve: Curves.easeOut)],
    child: GestureDetector(
      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => menu['page'])); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          // ✅ BACKGROUND GAMBAR DINAMIS
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
            opacity: 0.95,
          ),
          boxShadow: [
            BoxShadow(color: badgeColor.withOpacity(0.5), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, 12)),
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // ─── OVERLAY GRADIENT ─────────────────────
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        gradient.first.withOpacity(0.7),
                        gradient.last.withOpacity(0.4),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
              // ─── WATERMARK ────────────────────────────
              Positioned(
                bottom: -10, right: -10,
                child: Opacity(opacity: 0.06, child: const Text("VURTAX X RAT", style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Astral', height: 1))),
              ),
              // ─── KONTEN ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)), child: Center(child: Icon(menu['icon'], color: Colors.white, size: 26))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5)), child: Text(menu['badge'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontFamily: 'Astral', height: 1.2))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(menu['title'], style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 0.8, fontFamily: 'Astral', height: 1.2, shadows: [Shadow(color: Colors.black, blurRadius: 6)])),
                    const SizedBox(height: 3),
                    Text(menu['subtitle'], style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.5, fontWeight: FontWeight.w400, letterSpacing: 0.3, fontFamily: 'Astral', height: 1.3, shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
                    const SizedBox(height: 10),
                    Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.05)]))),
                    const SizedBox(height: 10),
                    Text(menu['description'], style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12.5, height: 1.6, letterSpacing: 0.2, fontFamily: 'Astral', shadows: const [Shadow(color: Colors.black, blurRadius: 4)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: features.take(3).map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.3))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(f, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500, height: 1.2)),
                        ]),
                      )).toList(),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5)),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => menu['page'])); },
                          splashColor: Colors.white.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("START MODULE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2, fontFamily: 'Astral', height: 1.2)),
                                const SizedBox(width: 8),
                                Container(width: 22, height: 22, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12)),
                              ],
                            ),
                          ),
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
    ),
  );
}

// ─── CHAT INFO PANEL ─────────────────────────────────────────
Widget _buildChatInfoPanel() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kRed.withOpacity(0.5), width: 1.5),
    ),
    child: Row(
      children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: kRed.withOpacity(0.3), shape: BoxShape.circle), child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Semua funct bug telah di tes dan work 100%", style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500, fontFamily: 'Astral', height: 1.5, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
              const SizedBox(height: 4),
              Row(children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: kRed, boxShadow: [BoxShadow(color: kRed.withOpacity(0.7), blurRadius: 5)])),
                const SizedBox(width: 6),
                Text("ZET TEAM", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontFamily: 'Astral', height: 1.2)),
              ]),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ─── BUILDBANNERVIDEO — VERSI TANPA OVERLAY PUTIH ✅ ─────────────
Widget _buildBannerVideo() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kCard,
          border: Border.all(color: kRed.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: kRed.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── VIDEO FULL (TANPA OVERLAY) ────────────
            if (_menuVideoCtrl != null && _menuVideoCtrl!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _menuVideoCtrl!.value.size.width,
                  height: _menuVideoCtrl!.value.size.height,
                  child: VideoPlayer(_menuVideoCtrl!),
                ),
              )
            else
              Container(color: kCard),

            // ❌ OVERLAY GRADIENT DIHAPUS (biar video keliatan full)

            // ─── TEXT OVERLAY (TETAP ADA) ──────────────
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ─── LIVE BADGE ────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),   // ✅ hitam transparan biar kebaca
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kRed.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LiveAnimatedDot(size: 8),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,           // ✅ putih biar kebaca
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontFamily: 'Astral',
                            height: 1.2,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ─── TEKS "VURTAX X RAT" ──────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, kRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'VURTAX X RAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Astral',
                        letterSpacing: 3,
                        height: 1.3,
                        shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ─── SUBTITLE ──────────────────────────
                  Text(
                    'Shinzo Wa Sasageyoo!',
                    style: TextStyle(
                      color: Colors.white,           // ✅ putih biar kebaca
                      fontSize: 11,
                      letterSpacing: 1,
                      fontFamily: 'Astral',
                      height: 1.3,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  
// ============================================================================
// BAGIAN STORY / STATUS — VURTAX X RAT (VERSI LENGKAP & FULL FIXED)
// + MIME TYPE SUPPORT + VALIDASI SIZE 10MB & DURASI 1 MENIT
// ============================================================================

 

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: DETECT MIME TYPE (LENGKAP)
// ═══════════════════════════════════════════════════════════════════════════
String _getMimeType(String filePath) {
  // ─── TRY DENGAN LIBRARY MIME DULU ─────────────────────────────
  String? mimeFromLib = lookupMimeType(filePath);
  if (mimeFromLib != null && mimeFromLib.isNotEmpty) {
    return mimeFromLib;
  }

  // ─── FALLBACK MANUAL BY EXTENSION ─────────────────────────────
  final path = filePath.toLowerCase();

  // ─── IMAGE FORMATS ────────────────────────────────────────────
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.gif')) return 'image/gif';
  if (path.endsWith('.webp')) return 'image/webp';
  if (path.endsWith('.bmp')) return 'image/bmp';
  if (path.endsWith('.heic')) return 'image/heic';
  if (path.endsWith('.heif')) return 'image/heif';
  if (path.endsWith('.tiff') || path.endsWith('.tif')) return 'image/tiff';
  if (path.endsWith('.svg')) return 'image/svg+xml';
  if (path.endsWith('.ico')) return 'image/x-icon';

  // ─── VIDEO FORMATS ────────────────────────────────────────────
  if (path.endsWith('.mp4')) return 'video/mp4';
  if (path.endsWith('.mov')) return 'video/quicktime';
  if (path.endsWith('.avi')) return 'video/x-msvideo';
  if (path.endsWith('.mkv')) return 'video/x-matroska';
  if (path.endsWith('.webm')) return 'video/webm';
  if (path.endsWith('.3gp')) return 'video/3gpp';
  if (path.endsWith('.flv')) return 'video/x-flv';
  if (path.endsWith('.wmv')) return 'video/x-ms-wmv';
  if (path.endsWith('.m4v')) return 'video/x-m4v';
  if (path.endsWith('.mpeg') || path.endsWith('.mpg')) return 'video/mpeg';
  if (path.endsWith('.ogv')) return 'video/ogg';

  // ─── DEFAULT ──────────────────────────────────────────────────
  return 'application/octet-stream';
}

// ═══════════════════════════════════════════════════════════════════════════
// BUILD STORY PAGE — TEKS PUTIH, BULATAN KECIL, TANPA BANNER PUTIH
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildStoryPage() {
  final allStatuses = [
    ..._myStatuses.map((s) => {...s, '_isMine': true}),
    ..._otherStatuses.map((s) => {...s, '_isMine': false}),
  ];

  allStatuses.sort((a, b) {
    final timeA = DateTime.tryParse(a['time']?.toString() ?? '') ?? DateTime.now();
    final timeB = DateTime.tryParse(b['time']?.toString() ?? '') ?? DateTime.now();
    return timeB.compareTo(timeA);
  });

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── HEADER (TANPA BACKGROUND, TEKS PUTIH) ─────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FontAwesomeIcons.instagram,
                color: Colors.white,
                size: 15,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "VURTAX X RAT STORY",
              style: TextStyle(
                color: Colors.white,                    // ✅ PUTIH
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Astral',
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
            const Spacer(),
            if (_myStatuses.isNotEmpty)
              TextButton(
                onPressed: _viewMyStatus,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Lihat Saya",
                  style: TextStyle(
                    color: Colors.white70,                  // ✅ PUTIH 70%
                    fontSize: 10,
                    fontFamily: 'Astral',
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              onPressed: _fetchStories,
              tooltip: 'Refresh Story',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 18,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ─── LIST STORY (TANPA BACKGROUND) ──────────────
        SizedBox(
          height: 74,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddStatusButton(),
              const SizedBox(width: 8),
              if (allStatuses.isNotEmpty)
                ...allStatuses.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildStatusCircle(s),
                )),
              if (allStatuses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Belum ada story.\nTap + untuk buat!',
                      style: TextStyle(
                        color: Colors.white70,               // ✅ PUTIH 70%
                        fontSize: 10,
                        fontFamily: 'Astral',
                        height: 1.4,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      textAlign: TextAlign.center,
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

// ═══════════════════════════════════════════════════════════════════════════
// 2. ADD STATUS BUTTON — BULATAN DIPERKECIL (52 → 42)
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildAddStatusButton() {
  return GestureDetector(
    onTap: _showAddStatusSheet,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.35),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 22,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Buat",
          style: TextStyle(
            color: _textStatus,
            fontSize: 9.5,
            fontFamily: 'Astral',
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. STATUS CIRCLE — BULATAN DIPERKECIL
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildStatusCircle(Map<String, dynamic> status) {
  final displayName = status['username']?.toString() ?? 'User';
  final content = status['content']?.toString() ?? '';
  final type = status['type'] ?? 'text';
  final isMine = status['_isMine'] ?? false;
  final mediaUrl = status['mediaUrl']?.toString() ??
                   status['url']?.toString() ??
                   content;

  return GestureDetector(
    onTap: () => _viewStatusDetail(status),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                isMine
                    ? _accentStatus.withOpacity(0.9)
                    : _accentStatus.withOpacity(0.7),
                isMine
                    ? _accentLightStatus.withOpacity(0.5)
                    : _accentLightStatus.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isMine ? Colors.white : Colors.white.withOpacity(0.7),
              width: isMine ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: type == 'video'
                ? (mediaUrl.startsWith('http')
                    ? Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _accentStatus,
                          child: const Icon(Icons.videocam,
                              color: Colors.white, size: 22),
                        ),
                      )
                    : Container(
                        color: _accentStatus,
                        child: const Icon(Icons.videocam,
                            color: Colors.white, size: 22),
                      ))
                : type == 'image'
                    ? (mediaUrl.startsWith('http')
                        ? Image.network(
                            mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.white, size: 22),
                          )
                        : const Icon(Icons.image,
                            color: Colors.white, size: 22))
                    : const Icon(Icons.text_fields,
                        color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 52,
          child: Text(
            displayName,
            style: TextStyle(
              color: _textStatus,
              fontSize: 9.5,
              fontWeight: isMine ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Astral',
              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. SHOW ADD STATUS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
void _showAddStatusSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Buat Story",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusOption("Teks", Icons.text_fields, () async {
                  Navigator.pop(context);
                  await _pickTextStatus();
                }),
                _buildStatusOption("Foto", Icons.photo, () async {
                  Navigator.pop(context);
                  await _pickMediaStatus(ImageSource.gallery, 'image');
                }),
                _buildStatusOption("Video", Icons.videocam, () async {
                  Navigator.pop(context);
                  await _pickMediaStatus(ImageSource.gallery, 'video');
                }),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. STATUS OPTION BUTTON
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildStatusOption(String title, IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _accentStatus.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _accentStatus, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
              color: Colors.black87, fontSize: 12, fontFamily: 'Astral'),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. PICK TEXT STATUS
// ═══════════════════════════════════════════════════════════════════════════
Future<void> _pickTextStatus() async {
  final controller = TextEditingController();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _accentLightStatus.withOpacity(0.3)),
      ),
      title: const Text("Buat Story Teks",
          style: TextStyle(color: Colors.black87, fontFamily: 'Astral')),
      content: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: Colors.black87, fontFamily: 'Astral'),
        decoration: InputDecoration(
          hintText: "Tulis storymu...",
          hintStyle: const TextStyle(color: Colors.black38, fontFamily: 'Astral'),
          filled: true,
          fillColor: _bgStatus,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal",
              style: TextStyle(color: Colors.black45, fontFamily: 'Astral')),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.isEmpty) return;
            final textContent = controller.text;
            Navigator.pop(context);

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40, height: 40,
                        child: CircularProgressIndicator(
                            color: Color(0xFF1565C0), strokeWidth: 3),
                      ),
                      SizedBox(height: 16),
                      Text('Membuat story...',
                          style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontFamily: 'Astral',
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );

            try {
              final res = await http.post(
                Uri.parse('$baseUrl/api/stories/text?key=$sessionKey'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'content': textContent}),
              ).timeout(const Duration(seconds: 10));

              if (mounted) Navigator.pop(context);

              final data = jsonDecode(res.body);
              if (data['valid'] == true && mounted) {
                setState(() {
                  _myStatuses.insert(0, data['story']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Story teks berhasil dibuat!',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Astral')),
                    backgroundColor: Colors.green,
                  ),
                );
                _fetchStories();
              } else {
                throw Exception(data['message'] ?? 'Gagal membuat story');
              }
            } catch (e) {
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal buat story: $e',
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Astral')),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentStatus,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Kirim",
              style: TextStyle(color: Colors.white, fontFamily: 'Astral')),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. PICK MEDIA STATUS (IMAGE / VIDEO)
// ═══════════════════════════════════════════════════════════════════════════
Future<void> _pickMediaStatus(ImageSource source, String type) async {
  try {
    XFile? pickedFile;

    if (type == 'video') {
      pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );
    } else {
      pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
    }

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ File tidak ditemukan!',
                style: TextStyle(color: Colors.white, fontFamily: 'Astral')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final fileSize = await file.length();
    final fileSizeMB = fileSize / (1024 * 1024);

    if (fileSizeMB > 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ File terlalu besar!\n'
              '📦 Ukuran: ${fileSizeMB.toStringAsFixed(2)} MB\n'
              '📏 Maksimal: 10 MB',
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'Astral', height: 1.5),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(
                      color: Color(0xFF1565C0), strokeWidth: 3),
                ),
                SizedBox(height: 16),
                Text('Mengupload...',
                    style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontFamily: 'Astral',
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    final mimeType = _getMimeType(pickedFile.path);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/stories/media?key=$sessionKey'),
    );

    request.fields['type'] = type;
    request.fields['size'] = fileSize.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'media',
        pickedFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 90));

    final responseData =
        await streamedResponse.stream.bytesToString().timeout(
              const Duration(seconds: 90),
            );

    final result = jsonDecode(responseData);

    if (mounted) Navigator.pop(context);

    if (result['valid'] == true && mounted) {
      setState(() {
        _myStatuses.insert(0, result['story']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${type == 'video' ? 'Video' : 'Foto'} story berhasil diupload!',
            style: const TextStyle(color: Colors.white, fontFamily: 'Astral'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      _fetchStories();
    } else if (mounted) {
      final errorMsg = result['message'] ?? 'Upload gagal, coba lagi!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMsg',
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'Astral')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (mounted) Navigator.pop(context);

    String errorMessage = e.toString().replaceFirst('Exception: ', '');

    if (errorMessage.contains('SocketConnection') ||
        errorMessage.contains('Connection reset')) {
      errorMessage =
          'Koneksi terputus!\n• Cek koneksi internet\n• File mungkin terlalu besar\n• Coba lagi';
    } else if (errorMessage.contains('TimeoutException')) {
      errorMessage =
          'Upload timeout!\n• Koneksi lambat\n• File terlalu besar\n• Coba lagi';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Gagal upload: $errorMessage',
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Astral', height: 1.5),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. FETCH STORIES
// ═══════════════════════════════════════════════════════════════════════════
Future<void> _fetchStories() async {
  try {
    final allRes = await http.get(
      Uri.parse('$baseUrl/api/stories?key=$sessionKey'),
    ).timeout(const Duration(seconds: 8));

    if (allRes.statusCode == 200) {
      final allData = jsonDecode(allRes.body);
      if (allData['valid'] == true && mounted) {
        final allStories =
            List<Map<String, dynamic>>.from(allData['stories'] ?? []);

        final my = allStories
            .where((s) => s['username'] == widget.username)
            .toList();
        final others = allStories
            .where((s) => s['username'] != widget.username)
            .toList();

        setState(() {
          _myStatuses = my;
          _otherStatuses = others;
        });
      }
    } else {
      await _fetchStoriesSeparate();
    }
  } catch (e) {
    debugPrint('❌ Fetch stories error: $e');
    await _fetchStoriesSeparate();
  }
}

Future<void> _fetchStoriesSeparate() async {
  try {
    final myRes = await http.get(
      Uri.parse('$baseUrl/api/stories/my?key=$sessionKey'),
    ).timeout(const Duration(seconds: 8));

    if (myRes.statusCode == 200) {
      final myData = jsonDecode(myRes.body);
      if (myData['valid'] == true && mounted) {
        setState(() {
          _myStatuses =
              List<Map<String, dynamic>>.from(myData['stories'] ?? []);
        });
      }
    }

    final othersRes = await http.get(
      Uri.parse('$baseUrl/api/stories/others?key=$sessionKey'),
    ).timeout(const Duration(seconds: 8));

    if (othersRes.statusCode == 200) {
      final othersData = jsonDecode(othersRes.body);
      if (othersData['valid'] == true && mounted) {
        setState(() {
          _otherStatuses =
              List<Map<String, dynamic>>.from(othersData['stories'] ?? []);
        });
      }
    }
  } catch (e) {
    debugPrint('❌ Fetch stories separate error: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 9. VIEW MY STATUS
// ═══════════════════════════════════════════════════════════════════════════
void _viewMyStatus() {
  if (_myStatuses.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Belum ada status kamu',
            style: TextStyle(fontFamily: 'Astral')),
        backgroundColor: Colors.blue,
      ),
    );
    return;
  }
  _viewStatusDetail(_myStatuses.first);
}

// ═══════════════════════════════════════════════════════════════════════════
// 10. VIEW STATUS DETAIL — FULLSCREEN + LIKE + COMMENT + VIEW
//     ✅ ANTI DOUBLE SOUND (pakai StatefulWidget _StoryViewerWidget)
// ═══════════════════════════════════════════════════════════════════════════
void _viewStatusDetail(Map<String, dynamic> status) {
  final type = status['type'] ?? 'text';
  final content = status['content']?.toString() ?? '';
  final mediaUrl = status['mediaUrl']?.toString() ??
                   status['url']?.toString() ??
                   content;
  final statusUsername = status['username']?.toString() ?? 'User';
  final isMine = status['_isMine'] ?? false;
  final storyId = status['id']?.toString() ?? '';

  // KIRIM VIEW
  if (storyId.isNotEmpty) {
    http
        .post(Uri.parse('$baseUrl/api/stories/$storyId/view?key=$sessionKey'))
        .timeout(const Duration(seconds: 5))
        .catchError((e) => http.Response('', 500));
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black,
    builder: (dialogContext) => _StoryViewerWidget(
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      statusUsername: statusUsername,
      isMine: isMine,
      storyId: storyId,
      sessionKey: sessionKey,
      baseUrl: baseUrl,
      onDeleteMine: (deletedId) {
        setState(() {
          _myStatuses.removeWhere((s) => s['id'] == deletedId);
        });
      },
    ),
  );
}

  // ─── BUILDTHANKSTOBANNER ────────────────────────────────────────
  Widget _buildThanksToBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: () { Navigator.push(context, _slideRoute(const ThanksToPage())); },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [kCard, kCardAlt], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: kRed.withOpacity(0.4)), boxShadow: [BoxShadow(color: kRed.withOpacity(0.2), blurRadius: 15)]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.people_alt_rounded, color: kRed, size: 28)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Thanks To", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Astral", height: 1.2)), SizedBox(height: 4), Text("Our Team & Contributors", style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.3))])),
                  Icon(Icons.chevron_right, color: kRed, size: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
// ═══════════════════════════════════════════════════════════════════
// BANNER HEADER — LOGO AWAN + TEKS "VURTAX X RAT" + GARIS PANJANG ✅
// ═══════════════════════════════════════════════════════════════════
Widget _buildCloudBanner() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ═══ GARIS PUTIH KIRI (PANJANG & JELAS) ═══
        Expanded(
          flex: 5,                            // ✅ lebih panjang
          child: Container(
            height: 1.5,                      // ✅ lebih tebal
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.8),  // ✅ lebih terang
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ─── LOGO AWAN KIRI ──────────────────
        const Icon(
          Icons.cloud_rounded,
          color: Colors.white,
          size: 15,                           // ✅ sedikit gede
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
        const SizedBox(width: 8),

        // ─── TEKS "VURTAX X RAT" ──────────────────
        Text(
          'VURTAX X RAT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,                     // ✅ sedikit gede
            fontWeight: FontWeight.bold,
            fontFamily: 'Astral',
            letterSpacing: 3,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
              Shadow(color: Colors.blue.withOpacity(0.6), blurRadius: 12),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ─── LOGO AWAN KANAN ────────────────
        const Icon(
          Icons.cloud_rounded,
          color: Colors.white,
          size: 15,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
        const SizedBox(width: 12),

        // ═══ GARIS PUTIH KANAN (PANJANG & JELAS) ═══
        Expanded(
          flex: 5,                            // ✅ lebih panjang
          child: Container(
            height: 1.5,                      // ✅ lebih tebal
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.8),  // ✅ lebih terang
                  Colors.white.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── WELCOME CARD — VERSI EREN.JPG + LOGO.PNG (LENGKAP) ────────────
Widget _buildWelcomeCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/eren.jpg'),
          fit: BoxFit.cover,
          opacity: 0.35,
        ),
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ❌ OVERLAY HITAM DIHAPUS (biar eren.jpg keliatan full)

          // ─── KONTEN ────────────────────────────────────
          Column(
            children: [
              // ─── ROW USERNAME + AVATAR ──────────────
              Row(
                children: [
                  // ─── AVATAR LOGO.PNG ────────────────
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kRed.withOpacity(0.6),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: kRed.withOpacity(0.3),
                            child: const Icon(Icons.security_rounded,
                              color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ─── USERNAME + ROLE ─────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'Astral',
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kCyan.withOpacity(0.8), width: 1.5),
                            color: kCyan.withOpacity(0.25),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontFamily: 'Astral',
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── TIMER ICON ──────────────────────
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kGreen.withOpacity(0.25),
                      border: Border.all(color: kGreen.withOpacity(0.8), width: 1.5),
                    ),
                    child: const Icon(Icons.timer_outlined,
                      color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── BANNER "DEVELOPER BY" — PENDEK ✅ ─
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: kCyan.withOpacity(0.8), width: 1.2),
                  color: Colors.black.withOpacity(0.35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedDot(color: kCyan, size: 5),
                    const SizedBox(width: 8),
                    const Text(
                      'Developer By @ranzz_offc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Astral',
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _AnimatedDot(color: kCyan, size: 5),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ─── STATS ROW ────────────────────────────
              Row(
  children: [
    _buildCircleStatItem(
      icon: Icons.people_alt_rounded,
      value: '$onlineUsers',
      label: 'Online Users',
      color: kGreen,
    ),
    _buildStatDivider(),
    _buildCircleStatItem(
      icon: Icons.person_rounded,
      value: '$_privateSenderCount',
      label: 'Private Sender',
      color: kBlue,
    ),
    _buildStatDivider(),
    _buildCircleStatItem(
      icon: Icons.public_rounded,
      value: '$_globalSenderCount',
      label: 'Global Sender',
      color: kOrange,
    ),
  ],
),
              const SizedBox(height: 12),

              // ─── LIVE BADGE ──────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGreen.withOpacity(0.8), width: 1.5),
                      color: Colors.black.withOpacity(0.35),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedDot(color: kGreen),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                            letterSpacing: 1,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: CIRCLE STAT ITEM (TETAP SAMA)
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildCircleStatItem({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
}) {
  return Expanded(
    child: Column(
      children: [
        Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.3),
            border: Border.all(color: color.withOpacity(0.9), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Astral',
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontFamily: 'Astral',
            shadows: [
              Shadow(color: Colors.black, blurRadius: 3),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: DIVIDER
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildStatDivider() => Container(
  width: 1,
  height: 60,
  color: Colors.white.withOpacity(0.3),
);
    
  // ─── DASHBOARD CARD ──────────────────────────────────────────────
  Widget _buildDashboardCard() {
    final now = DateTime.now();
    int accountDaysLeft = 0;
    double accountProgress = 0.0;
    String accountStatus = "ACTIVE";

    try {
      final expired = DateTime.parse(expiredDate);
      final difference = expired.difference(now);
      if (difference.inDays <= 0) { accountStatus = "EXPIRED"; accountDaysLeft = 0; accountProgress = 0.0; } else {
        accountDaysLeft = difference.inDays;
        final totalDays = 30;
        accountProgress = (accountDaysLeft / totalDays).clamp(0.0, 1.0);
        if (accountDaysLeft <= 3) { accountStatus = "CRITICAL"; } else if (accountDaysLeft <= 7) { accountStatus = "WARNING"; } else { accountStatus = "ACTIVE"; }
      }
    } catch (e) { accountStatus = "UNKNOWN"; accountDaysLeft = 0; accountProgress = 0.0; }

    Color statusColor;
    IconData statusIcon;
    switch (accountStatus) {
      case "ACTIVE": statusColor = kRed; statusIcon = Icons.check_circle_rounded; break;
      case "WARNING": statusColor = Colors.orange; statusIcon = Icons.warning_rounded; break;
      case "CRITICAL": statusColor = Colors.red; statusIcon = Icons.error_rounded; break;
      case "EXPIRED": statusColor = Colors.grey; statusIcon = Icons.cancel_rounded; break;
      default: statusColor = Colors.black54; statusIcon = Icons.help_rounded;
    }

    String formattedExpired = expiredDate;
    try { final date = DateTime.parse(expiredDate); formattedExpired = "${date.day}/${date.month}/${date.year}"; } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
          boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 2), BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kRed.withOpacity(0.5), width: 1.5), boxShadow: [BoxShadow(color: kRed.withOpacity(0.3), blurRadius: 10)]), child: ClipOval(child: Image.asset('assets/images/logo.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) { return Container(color: kRed.withOpacity(0.2), child: const Icon(Icons.flag_rounded, color: kRed, size: 18)); }))),
                    const Text("DASHBOARD", style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Astral', letterSpacing: 1, height: 1.3)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: statusColor.withOpacity(0.5), width: 1)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(statusIcon, color: statusColor, size: 12), const SizedBox(width: 4), Text(accountStatus, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2))]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Remaining Time", style: TextStyle(color: Colors.black54, fontSize: 9, fontFamily: 'Astral', height: 1.3)), Text("$accountDaysLeft Days Left", style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.3))]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: accountProgress, minHeight: 4, backgroundColor: Colors.black87.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(statusColor))),
            const SizedBox(height: 14),
            Row(children: [
              _buildWelcomeStatChip(icon: _roleIcon(role), label: "ROLE", value: _roleDisplayName(role).toUpperCase(), color: kRed),
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: Icons.calendar_month_rounded, label: "EXPIRED", value: formattedExpired, color: kRed),
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: Icons.people_alt_rounded, label: "ONLINE", value: "$onlineUsers Users", color: kRed),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _buildWelcomeStatChip(icon: Icons.devices_rounded, label: "DEVICE", value: _deviceInfoLoaded ? _deviceModel : "Android ${androidId.substring(0, 4).toUpperCase()}", color: kRed),
              const SizedBox(width: 6),
            _buildWelcomeStatChip(icon: _isCharging ?Icons.battery_charging_full_rounded : Icons.battery_full_rounded,
  label: "BATTERY",
  value: _batteryDisplay,
  color: _isCharging ? const Color(0xFF22C55E) : kRed), 
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: _networkType == 'WiFi' ? Icons.wifi_rounded : Icons.signal_cellular_alt_rounded, label: "NETWORK", value: _deviceInfoLoaded ? '$_networkType $_networkStrength%' : "WiFi 85%", color: kRed),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _buildWelcomeStatChip(icon: Icons.memory_rounded, label: "RAM", value: _deviceInfoLoaded ? '$_ramUsed / $_ramTotal' : "2340MB / 4096MB", color: kRed, showProgress: true, progressValue: _deviceInfoLoaded ? _getRamProgress() : 0.57, progressColor: kRed),
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: Icons.storage_rounded, label: "STORAGE", value: _deviceInfoLoaded ? '$_storageUsed / $_storageTotal' : "86GB / 128GB", color: kRed, showProgress: true, progressValue: _deviceInfoLoaded ? _getStorageProgress() : 0.67, progressColor: kRed),
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: Icons.android_rounded, label: "SYSTEM", value: _deviceInfoLoaded ? _androidVersion : "API 33", color: kRed),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _buildWelcomeStatChip(icon: Icons.link_rounded, label: "SESSION", value: sessionKey.substring(0, 8).toUpperCase(), color: kRed),
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: Icons.network_check_rounded, label: "CONN", value: "$activeConns Active", color: kRed),
              const SizedBox(width: 6),
              _buildWelcomeStatChip(icon: Icons.timer_outlined, label: "TIME", value: _formatClock(DateTime.now()), color: kRed),
            ]),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: kRed.withOpacity(0.6)), color: kRed.withOpacity(0.1)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [_LiveAnimatedDot(size: 8), const SizedBox(width: 6), const Text('LIVE', style: TextStyle(color: kRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Astral', height: 1.2))]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── WELCOME STAT CHIP ──────────────────────────────────────────
  Widget _buildWelcomeStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showProgress = false,
    double progressValue = 0.0,
    Color? progressColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 10), const SizedBox(width: 4), Text(label, style: TextStyle(color: Colors.black54, fontSize: 6.5, fontFamily: 'Astral', letterSpacing: 0.3, height: 1.2))]),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: Colors.black87, fontSize: 8.5, fontWeight: FontWeight.w600, fontFamily: 'Astral', height: 1.2), overflow: TextOverflow.ellipsis, maxLines: 1),
            if (showProgress) ...[
              const SizedBox(height: 3),
              ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: progressValue.clamp(0.0, 1.0), minHeight: 2.5, backgroundColor: Colors.black87.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? color))),
            ],
          ],
        ),
      ),
    );
  }

  String _formatClock(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
  
// ─── BUILDMANAGEMENTCHAT ─────────────────────────────────
Widget _buildManagementChat() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        // ─── CHAT USER ──────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showChatUserDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kRed.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kRed.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          "CHAT",
                          style: TextStyle(
                            color: kRed,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Private Chat",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Chat pribadi dengan semua user",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontFamily: 'Astral',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ─── CHAT GLOBAL ────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicChatPage(
                    sessionKey: widget.sessionKey,
                    username: widget.username,
                    role: widget.role,
                  ),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kRed.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kRed.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          "GLOBAL",
                          style: TextStyle(
                            color: kRed,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Chat Global",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Chat dengan semua user",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontFamily: 'Astral',
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

// ─── BUILDQUICKACTIONSSECTION ──────────────────────────────────
Widget _buildQuickActionsSection() {
  final actions = [
    _QuickActionData(
      icon: FontAwesomeIcons.whatsapp,
      bgIcon: FontAwesomeIcons.whatsapp,
      title: 'Manage Sender',
      subtitle: 'Manage your active sender',
      gradient: [kRed, kBorder],
      onTap: () => Navigator.push(context, _slideRoute(BugSenderPage(sessionKey: sessionKey, username: username, role: role))).then((_) { if (mounted && _newsPageCtrl.hasClients) { setState(() { _currentNewsPage = 0.0; _newsPageViewKey++; }); _newsPageCtrl.jumpToPage(0); } }),
    ),
    _QuickActionData(
      icon: FontAwesomeIcons.tiktok,
      bgIcon: FontAwesomeIcons.tiktok,
      title: 'TikTok',
      subtitle: 'Watch & Scroll TikTok',
      gradient: [const Color(0xFFFE2C55), const Color(0xFF25F4EE)],
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TiktokPage(),
        ),
      ),
    ),
    _QuickActionData(
      icon: FontAwesomeIcons.telegram,
      bgIcon: FontAwesomeIcons.telegram,
      title: 'Chat Developer',
      subtitle: 'Developer VURTAX X RAT',
      gradient: [kRed, kBorder],
      onTap: () => _openUrl('https://t.me/ranzz_offczaxx_stur'),
    ),
    _QuickActionData(
      icon: FontAwesomeIcons.bookQuran,
      bgIcon: FontAwesomeIcons.bookQuran,
      title: 'Al Quran',
      subtitle: 'Baca Al-Quran',
      gradient: [kRed, kBorder],
      onTap: () => Navigator.push(context, _slideRoute(AlQuranPage())),
    ),
    _QuickActionData(
      icon: FontAwesomeIcons.tv,
      bgIcon: FontAwesomeIcons.tv,
      title: 'Anime',
      subtitle: 'Discover & Watch Anime',
      gradient: [kRed, kBorder],
      onTap: () => Navigator.push(context, _slideRoute(HomeAnimePage())),
    ),
  ];

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(width: 44, height: 44, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kRed.withOpacity(0.4))), child: const Icon(Icons.bolt_rounded, color: kRed, size: 22)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('QUICK ACTIONS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Astral', letterSpacing: 1, height: 1.2)), Text('Fitur Cepat Akses', style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.3))]),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kRed.withOpacity(0.4))), child: Row(children: [Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: kRed)), const SizedBox(width: 5), const Text('VURTAX X RAT', style: TextStyle(color: kRed, fontSize: 11, fontWeight: FontWeight.bold, height: 1.2))])),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 180,
        child: PageView.builder(
          controller: _qaPageCtrl,
          itemCount: actions.length,
          onPageChanged: (index) { if (mounted) setState(() => _currentQaPage = index.toDouble()); },
          itemBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _buildAnimatedQuickActionCard(action: actions[index], index: index, currentPage: _currentQaPage)),
        ),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(actions.length, (index) {
        final bool isActive = _currentQaPage.round() == index;
        return AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: isActive ? 24 : 8, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: isActive ? kRed : Colors.black87.withOpacity(0.25)));
      })),
    ],
  );
}

  Widget _buildAnimatedQuickActionCard({
    required _QuickActionData action,
    required int index,
    required double currentPage,
  }) {
    bool _pressed = false;
    final double distance = (index - currentPage).abs();
    final double targetScale = distance <= 0.01 ? 1.0 : 0.85;
    final double targetOpacity = distance <= 0.01 ? 1.0 : 0.6;
    final Color borderColor = distance <= 0.01 ? kBorder.withOpacity(0.5) : Colors.transparent;
    final double shadowBlur = distance <= 0.01 ? 25 : 10;
    final double shadowSpread = distance <= 0.01 ? 4 : 1;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: targetScale, end: targetScale),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      builder: (context, scaleValue, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: targetOpacity, end: targetOpacity),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          builder: (context, opacityValue, child) {
            return Transform.scale(
              scale: scaleValue,
              child: Opacity(
                opacity: opacityValue,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(color: action.gradient.first.withOpacity(distance <= 0.01 ? 0.5 : 0.2), blurRadius: shadowBlur, spreadRadius: shadowSpread, offset: const Offset(0, 8)),
                      if (distance <= 0.01) BoxShadow(color: kBorder.withOpacity(0.05), blurRadius: 30, spreadRadius: 1, offset: const Offset(0, 0)),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return GestureDetector(
                        onTapDown: (_) => setState(() => _pressed = true),
                        onTapUp: (_) { setState(() => _pressed = false); action.onTap(); },
                        onTapCancel: () => setState(() => _pressed = false),
                        child: AnimatedScale(
                          scale: _pressed ? 0.92 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(colors: action.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: Stack(
                              children: [
                                Positioned(right: -12, bottom: -12, child: AnimatedOpacity(duration: const Duration(milliseconds: 350), opacity: distance <= 0.01 ? 0.12 : 0.06, child: Icon(action.bgIcon, color: Colors.white, size: 110))),
                                if (distance <= 0.01)
                                  Positioned(top: -20, right: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [action.gradient.first.withOpacity(0.3), Colors.transparent])))),
                                Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(duration: const Duration(milliseconds: 350), width: distance <= 0.01 ? 56 : 50, height: distance <= 0.01 ? 56 : 50,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(distance <= 0.01 ? 0.25 : 0.15), border: Border.all(color: Colors.white.withOpacity(distance <= 0.01 ? 0.3 : 0.1), width: distance <= 0.01 ? 2 : 1)),
                                        child: Icon(action.icon, color: Colors.white, size: distance <= 0.01 ? 28 : 24)),
                                      const Spacer(),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: AnimatedContainer(duration: const Duration(milliseconds: 350), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withOpacity(distance <= 0.01 ? 0.25 : 0.15), border: Border.all(color: Colors.white.withOpacity(distance <= 0.01 ? 0.3 : 0.1))),
                                          child: Text(distance <= 0.01 ? 'ACTIVE →' : 'Tap →', style: TextStyle(color: Colors.white, fontSize: distance <= 0.01 ? 12 : 11, fontWeight: FontWeight.bold, letterSpacing: distance <= 0.01 ? 1 : 0, height: 1.2))),
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 350), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: distance <= 0.01 ? 19 : 17, fontFamily: 'Astral', letterSpacing: distance <= 0.01 ? 1 : 0, height: 1.2), child: Text(action.title)),
                                      const SizedBox(height: 4),
                                      AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 350), style: TextStyle(color: Colors.white.withOpacity(distance <= 0.01 ? 0.9 : 0.7), fontSize: distance <= 0.01 ? 13 : 12, height: 1.3), child: Text(action.subtitle)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── BUILDLATESTUPDATES ─────────────────────────────────────────
  Widget _buildLatestUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: kRed.withOpacity(0.3), blurRadius: 12)]), child: const Icon(Icons.dashboard_customize_rounded, color: kRed, size: 18)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('LATEST UPDATES', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Astral', letterSpacing: 1.5, height: 1.2)), Text('Update terbaru dari VURTAX X RAT', style: TextStyle(color: Colors.black54, fontSize: 10, height: 1.3))]),
              const Spacer(),
              if (newsList.isNotEmpty)
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kRed.withOpacity(0.4), width: 1)), child: Row(mainAxisSize: MainAxisSize.min, children: [_AnimatedDot(color: kRed, size: 5), const SizedBox(width: 5), Text('${newsList.length} New', style: const TextStyle(color: kRed, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2))])),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (newsList.isNotEmpty)
          SizedBox(height: 220, child: ListView.builder(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 14), itemCount: newsList.length, itemBuilder: (ctx, i) => _buildNewsCardModern(newsList[i]))),
        if (newsList.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Container(height: 100, decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox_rounded, color: Colors.black87.withOpacity(0.08), size: 32), const SizedBox(height: 6), Text('Tidak ada update', style: TextStyle(color: Colors.black87.withOpacity(0.3), fontSize: 12, height: 1.3))]))),
      ],
    );
  }

  Widget _buildNewsCardModern(dynamic item) {
    final imgUrl = item['image']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'No Title';
    final date = item['date']?.toString() ?? item['created_at']?.toString() ?? '';
    final description = item['description']?.toString() ?? '';
    final cardWidth = (MediaQuery.of(context).size.width / 2) - 22;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: kCard, border: Border.all(color: kBorder.withOpacity(0.4), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)), BoxShadow(color: kRed.withOpacity(0.05), blurRadius: 30)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(height: 110, width: double.infinity, color: kCard,
                  child: imgUrl.isNotEmpty ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: kCard, child: Center(child: Icon(Icons.image_not_supported, color: Colors.black87.withOpacity(0.15), size: 32)))) : Container(color: kCard, child: Center(child: Icon(Icons.article_rounded, color: Colors.black87.withOpacity(0.1), size: 32)))),
                Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: kRed.withOpacity(0.5), blurRadius: 8)]), child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2)))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              if (description.isNotEmpty) ...[const SizedBox(height: 4), Text(description, style: TextStyle(color: Colors.black54, fontSize: 10, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)],
              const Spacer(),
              const SizedBox(height: 6),
              Row(children: [Icon(Icons.access_time_rounded, color: Colors.black87.withOpacity(0.25), size: 10), const SizedBox(width: 4), Text(date.isNotEmpty ? (date.length > 10 ? date.substring(0, 10) : date) : 'Baru saja', style: TextStyle(color: Colors.black87.withOpacity(0.25), fontSize: 9, fontFamily: 'Astral', height: 1.2)), const Spacer(), Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, color: kRed.withOpacity(0.1)), child: Icon(Icons.arrow_forward_ios_rounded, color: kRed.withOpacity(0.4), size: 9))]),
            ]),
          ),
        ],
      ),
    );
  }

  // ─── BUILDPRAYERSECTION ──────────────────────────────────────────
  Widget _buildPrayerSection() {
    final prayerColors = [kRed, kBorder, kRed, kBorder, kRed];
    final prayerIcons = [Icons.nights_stay_rounded, Icons.wb_sunny_rounded, Icons.cloud_rounded, Icons.wb_twilight_rounded, Icons.nightlight_round];
    final prayerKeys = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder.withOpacity(0.4), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10)), BoxShadow(color: kRed.withOpacity(0.05), blurRadius: 30)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(gradient: LinearGradient(colors: [kRed.withOpacity(0.2), kRed.withOpacity(0.08)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: kRed.withOpacity(0.4), width: 1.5)), child: const Center(child: Icon(Icons.mosque, color: kRed, size: 22))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('JADWAL SHOLAT', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Astral', letterSpacing: 1.5, height: 1.2)),
                  Row(children: [Icon(Icons.location_on_rounded, color: kRed.withOpacity(0.5), size: 10), const SizedBox(width: 4), Text(_prayerCity, style: TextStyle(color: Colors.black54, fontSize: 10, height: 1.3))]),
                ])),
                GestureDetector(
                  onTap: _locationLoading ? null : _detectLocationAndFetchPrayer,
                  child: Container(width: 36, height: 36, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(shape: BoxShape.circle, color: _locationGranted ? kRed.withOpacity(0.15) : kBg, border: Border.all(color: _locationGranted ? kRed.withOpacity(0.5) : kBorder.withOpacity(0.3), width: 1.5)),
                    child: _locationLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: kRed, strokeWidth: 2)) : Icon(_locationGranted ? Icons.my_location_rounded : Icons.location_searching_rounded, color: _locationGranted ? kRed : Colors.black54, size: 16)),
                ),
                GestureDetector(
                  onTap: _showChangeCityDialog,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kBorder]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: kRed.withOpacity(0.4), blurRadius: 10)]), child: const Row(children: [Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 12), SizedBox(width: 4), Text('GANTI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2))])),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_nextPrayerLabel.isNotEmpty)
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: kRed.withOpacity(0.3), width: 1)),
                child: Row(children: [
                  ScaleTransition(scale: _pulseAnim, child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: kRed, boxShadow: [BoxShadow(color: kRed.withOpacity(0.6), blurRadius: 8)]))),
                  const SizedBox(width: 10),
                  Text('Menuju $_nextPrayerLabel : $_nextPrayerTime', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Astral', height: 1.2)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: kRed.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: kRed.withOpacity(0.4), width: 1)), child: const Text('NOW', style: TextStyle(color: kRed, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2))),
                ])),
            const SizedBox(height: 14),
            if (_prayerLoading)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator(color: kRed, strokeWidth: 2)))
            else
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: prayerKeys.length,
                  itemBuilder: (ctx, i) {
                    final key = prayerKeys[i];
                    final time = _prayerTimes[key] ?? '--:--';
                    final color = prayerColors[i];
                    final icon = prayerIcons[i];
                    final isNext = key == _nextPrayerLabel;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.only(right: 8, bottom: isNext ? 0 : 6, top: isNext ? 0 : 6),
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: isNext ? [color, color.withOpacity(0.8)] : [color.withOpacity(0.6), color.withOpacity(0.3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: color.withOpacity(isNext ? 0.6 : 0.3), blurRadius: isNext ? 16 : 8, offset: const Offset(0, 4))],
                        border: isNext ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.5) : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(height: 4),
                          Text(key.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Astral', height: 1.2)),
                          const SizedBox(height: 4),
                          Text(time, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── BUILDHADITHSECTION ──────────────────────────────────────────
  Widget _buildHadithSection() {
    if (_hadithLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Container(
          height: 200,
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder.withOpacity(0.4), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
          child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: kRed, strokeWidth: 2), SizedBox(height: 12), Text('Memuat Hadith...', style: TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Astral', height: 1.3))])),
        ),
      );
    }

    final arabic = _hadith?['data']?['text']?['ar'] ?? 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى';
    final indo = _hadith?['data']?['text']?['id'] ?? 'Sesungguhnya setiap amalan tergantung pada niatnya.';
    final number = _hadith?['data']?['id']?.toString() ?? '1';
    final source = _hadith?['data']?['source']?.toString() ?? 'Muslim';
    final grade = _hadith?['data']?['grade']?.toString() ?? 'Sahih Muslim';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder.withOpacity(0.4), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10)), BoxShadow(color: kRed.withOpacity(0.05), blurRadius: 30)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(gradient: LinearGradient(colors: [kRed.withOpacity(0.2), kRed.withOpacity(0.08)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: kRed.withOpacity(0.4), width: 1.5)), child: const Center(child: Icon(Icons.menu_book_rounded, color: kRed, size: 22))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('HADITH OF THE DAY', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Astral', letterSpacing: 1.5, height: 1.2)),
                  Row(children: [Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: kRed)), const SizedBox(width: 6), Text(grade, style: TextStyle(color: kRed.withOpacity(0.6), fontSize: 10, fontFamily: 'Astral', height: 1.2)), const SizedBox(width: 6), Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54)), const SizedBox(width: 6), Text('Tap card to read full', style: TextStyle(color: Colors.black54.withOpacity(0.3), fontSize: 9, height: 1.2))]),
                ])),
                GestureDetector(
                  onTap: _fetchRandomHadith,
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kRed.withOpacity(0.12), kRed.withOpacity(0.04)]), border: Border.all(color: kRed.withOpacity(0.3), width: 1.5)), child: Icon(Icons.refresh_rounded, color: kRed.withOpacity(0.6), size: 18)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showHadithFullDialog(arabic, indo, source, number, grade),
              child: Column(
                children: [
                  Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder.withOpacity(0.2), width: 1)),
                    child: Text(arabic, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.black87, fontSize: 17, height: 2.2, fontWeight: FontWeight.w400))),
                  const SizedBox(height: 10),
                  Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder.withOpacity(0.1), width: 1)),
                    child: Row(children: [
                      Expanded(child: Text(indo, style: TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic, height: 1.8), maxLines: 3, overflow: TextOverflow.ellipsis)),
                      Container(padding: const EdgeInsets.all(6), margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(shape: BoxShape.circle, color: kRed.withOpacity(0.1)), child: Icon(Icons.arrow_forward_ios_rounded, color: kRed.withOpacity(0.3), size: 12)),
                    ])),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kRed.withOpacity(0.2), width: 1)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_rounded, color: kRed.withOpacity(0.5), size: 12),
                    const SizedBox(width: 6),
                    Text('${source.isNotEmpty ? source : "Muslim"} #$number', style: TextStyle(color: kRed.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Astral', height: 1.2)),
                  ]),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _fetchRandomHadith,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder.withOpacity(0.2), width: 1)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.touch_app_rounded, color: Colors.black54.withOpacity(0.3), size: 12),
                      const SizedBox(width: 4),
                      Text('Tap ganti', style: TextStyle(color: Colors.black54.withOpacity(0.3), fontSize: 9, fontFamily: 'Astral', height: 1.2)),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
    // ─── BUILD ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBg,
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPagePointerDown,
        onPointerUp: _onPagePointerUp,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: kBg),
            ),
            CustomPaint(size: Size.infinite, painter: _GridPatternPainter(gridColor: kBorder.withOpacity(0.2), lineColor: kRed.withOpacity(0.1), spacing: 35)),
            AnimatedSwitcher(duration: const Duration(milliseconds: 350), transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child), child: KeyedSubtree(key: ValueKey(_navIndex), child: _buildCurrentPage())),
            Positioned(left: 0, right: 0, bottom: 0, child: _SwipeUpHandle(onTap: _showNav, accentColor: kRed, lightColor: Colors.black54, bottomPadding: MediaQuery.of(context).padding.bottom)),
            if (_isNavVisible)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: AnimatedBuilder(
                  animation: _navRevealAnimation,
                  builder: (context, child) {
                    final double t = _navRevealAnimation.value;
                    return Opacity(opacity: t.clamp(0.0, 1.0), child: Transform.translate(offset: Offset(0, (1 - t) * 140), child: child));
                  },
                  child: _buildBottomNav(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── BUILDAPPBAR ──────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCard,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      titleSpacing: 0,
      flexibleSpace: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.5))))),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'Menu',
        splashRadius: 24,
        splashColor: kRed.withOpacity(0.3),
        highlightColor: kRed.withOpacity(0.1),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Text('VURTAX X RAT', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Genetic', letterSpacing: 2, height: 1.2, shadows: [Shadow(color: kRed.withOpacity(0.3), blurRadius: 10)])),
        ],
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(context, _slideRoute(ProfilePage(username: username, password: password, role: role, expiredDate: expiredDate, sessionKey: sessionKey))),
          child: Container(width: 38, height: 38, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kRed.withOpacity(0.6), width: 2), color: kRed.withOpacity(0.2)),
            child: ClipOval(child: Image.asset('assets/images/logo.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) { return _profileImage != null ? Image.file(_profileImage!, fit: BoxFit.cover) : const Icon(FontAwesomeIcons.userAstronaut, color: kRed, size: 20); }))),
        ),
        const SizedBox(width: 4),
        GestureDetector(onTap: () => Navigator.push(context, _slideRoute(const ContactPage())), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.headset_mic_outlined, color: Colors.black87, size: 24))),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── BUILDBOTTOMNAV ──────────────────────────────────────────────
Widget _buildBottomNav() {
    final items = [
    _NavItem(icon: Icons.home_rounded, label: 'HOME'),
    _NavItem(icon: Icons.devices_rounded, label: 'RAT'),
    _NavItem(icon: FontAwesomeIcons.whatsapp, label: 'BUG'),
    _NavItem(icon: Icons.info_outline_rounded, label: 'INFO'),
    _NavItem(icon: Icons.build_circle_outlined, label: 'TOOLS'),
  ];


  final Color primaryColor = kRed;
  final Color accentColor = kBorder;

  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
    height: 110,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // ─── BACKGROUND NAV ──────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: kCard.withOpacity(0.95),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: kBorder.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),
        
        // ─── 5 MENU ITEMS ──────────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final isActive = _navIndex == i;
                final isCenter = i == 2;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onNavTap(i),
                    child: Transform.translate(
                      offset: Offset(0, isCenter ? -30 : 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isCenter)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: 72,
                              height: 72,
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [primaryColor, accentColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.7),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                items[i].icon,
                                color: Colors.white,
                                size: 34,
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  items[i].icon,
                                  color: isActive
                                      ? primaryColor
                                      : Colors.black87.withOpacity(0.4),
                                  size: 26,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  items[i].label,
                                  style: TextStyle(
                                    color: isActive
                                        ? primaryColor
                                        : Colors.black87.withOpacity(0.4),
                                    fontSize: isActive ? 11 : 10,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: isActive ? 'Astral' : null,
                                    letterSpacing: isActive ? 0.5 : 0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        
        // ─── INDICATOR ACTIVE ────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _navIndex == i && i != 2;

              return Expanded(
                child: Container(
                  height: 68,
                  alignment: Alignment.topCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 30 : 0,
                    height: isActive ? 3 : 0,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDrawer() {
  final List<Map<String, dynamic>> drawerItems = [];
  if (roleLevel.containsKey(role)) {
    if (role == 'developer' || role == 'founder' || role == 'kingz' || role == 'high owner' || role == 'owner' || role == 'tk' || role == 'admin' || role == 'reseller') {
      if (role == 'developer') drawerItems.add({'icon': Icons.code_rounded, 'label': 'Developer Page', 'page': DeveloperPage(sessionKey: sessionKey), 'role': 'developer'});
      if (role == 'founder' || role == 'kingz' || role == 'high owner' || role == 'owner' || role == 'tk' || role == 'admin') drawerItems.add({'icon': Icons.workspace_premium_rounded, 'label': 'Owner Page', 'page': OwnerPage(sessionKey: sessionKey, username: username), 'role': 'owner'});
      if (role == 'founder' || role == 'kingz' || role == 'high owner' || role == 'owner' || role == 'tk' || role == 'admin') drawerItems.add({'icon': Icons.admin_panel_settings_rounded, 'label': 'Admin Page', 'page': AdminPage(sessionKey: sessionKey), 'role': 'admin'});
      if (role == 'founder' || role == 'kingz' || role == 'high owner' || role == 'owner' || role == 'tk' || role == 'admin' || role == 'reseller') drawerItems.add({'icon': Icons.storefront_rounded, 'label': 'Seller Page', 'page': SellerPage(keyToken: sessionKey), 'role': 'reseller'});
    }
  }

  return Drawer(
    backgroundColor: kCard,
    width: MediaQuery.of(context).size.width * 0.8,
    child: Column(
      children: [
        // ─── HEADER ────────────────────────────────────────────
        Container(
          height: 240,
          color: kBg,
          child: Stack(
            children: [
              if (_menuVideoCtrl != null && _menuVideoCtrl!.value.isInitialized)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _menuVideoCtrl!.value.size.width,
                      height: _menuVideoCtrl!.value.size.height,
                      child: VideoPlayer(_menuVideoCtrl!),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.85)],
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kRed.withOpacity(0.8), width: 3),
                          boxShadow: [BoxShadow(color: kRed.withOpacity(0.4), blurRadius: 14, spreadRadius: 4)],
                        ),
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(_profileImage!, fit: BoxFit.cover)
                              : const Icon(FontAwesomeIcons.userAstronaut, size: 38, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Astral',
                          height: 1.2,
                        ),
                      ),
                      Text(
                        _roleDisplayName(role).toUpperCase(),
                        style: const TextStyle(
                          color: kRed,
                          fontSize: 12,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // ─── MENU LIST ──────────────────────────────────────────
        Expanded(
          child: Container(
            color: kCard,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // ─── DRAWER ITEMS DARI ROLE ────────────────────
                for (var item in drawerItems)
                  _buildDrawerItem(
                    icon: item['icon'],
                    label: item['label'],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['page']),
                      ).then((_) {
                        if (mounted && _newsPageCtrl.hasClients) {
                          setState(() {
                            _currentNewsPage = 0.0;
                            _newsPageViewKey++;
                          });
                          _newsPageCtrl.jumpToPage(0);
                        }
                      });
                    },
                  ),
                
                // ─── 🔥 TIKTOK MENU 🔥 ──────────────────────────
                _buildDrawerItem(
                  icon: FontAwesomeIcons.tiktok,
                  label: 'TikTok',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TiktokPage(),
                      ),
                    );
                  },
                ),
                
                // ─── MENU TETAP ──────────────────────────────────
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat Aktivitas',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      _slideRoute(RiwayatPage(
                    sessionKey: sessionKey,
                      role: role,
                     )),
                    ).then((_) {
                      if (mounted && _newsPageCtrl.hasClients) {
                        setState(() {
                          _currentNewsPage = 0.0;
                          _newsPageViewKey++;
                        });
                        _newsPageCtrl.jumpToPage(0);
                      }
                    });
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Ganti Password',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      _slideRoute(
                        ChangePasswordPage(
                          username: username,
                          sessionKey: sessionKey,
                          role: role,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  isLogout: true,
                  onTap: () async {
                    Navigator.pop(context);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDrawerItem({required IconData icon, required String label, required VoidCallback onTap, bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(color: isLogout ? Colors.red.withOpacity(0.15) : kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: isLogout ? Colors.red.withOpacity(0.4) : kBorder.withOpacity(0.3))),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.redAccent : kRed, size: 20),
        title: Text(label, style: TextStyle(color: isLogout ? Colors.redAccent : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14, height: 1.2)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}

int _activeVideoCount = 0;

// ═══════════════════════════════════════════════════════════════════════════
// COMMENT SHEET
// ═══════════════════════════════════════════════════════════════════════════
void _showCommentSheet(
  BuildContext parentContext,
  String storyId,
  List<dynamic> initialComments,
  String sessionKey,
  String baseUrl,
  Function(List<dynamic>, int) onUpdate,
) {
  List<dynamic> comments = List.from(initialComments);
  final textCtrl = TextEditingController();

  showModalBottomSheet(
    context: parentContext,
    backgroundColor: const Color(0xFF1A1A1A),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.65,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Komentar (${comments.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: comments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.white24, size: 48),
                              SizedBox(height: 12),
                              Text('Belum ada komentar',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'Astral')),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: comments.length,
                          itemBuilder: (ctx, i) {
                            final c = comments[i];
                            final name = c['username']?.toString() ?? 'User';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1565C0),
                                          Color(0xFF42A5F5)
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Astral',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c['message']?.toString() ?? '',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontFamily: 'Astral',
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textCtrl,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Astral'),
                            decoration: const InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontFamily: 'Astral'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: Color(0xFF42A5F5)),
                          onPressed: () async {
                            final msg = textCtrl.text.trim();
                            if (msg.isEmpty) return;
                            textCtrl.clear();

                            try {
                              final res = await http.post(
                                Uri.parse(
                                    '$baseUrl/api/stories/$storyId/comment?key=$sessionKey'),
                                headers: {
                                  'Content-Type': 'application/json'
                                },
                                body: jsonEncode({'message': msg}),
                              ).timeout(const Duration(seconds: 5));

                              if (res.statusCode == 200) {
                                final data = jsonDecode(res.body);
                                if (data['valid'] == true) {
                                  setSheetState(() {
                                    comments.add(data['comment']);
                                  });
                                  onUpdate(comments, comments.length);
                                }
                              }
                            } catch (e) {
                              debugPrint('❌ Comment error: $e');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// BUILD STORY CONTENT
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildStoryContent({
  required String type,
  required String content,
  required String mediaUrl,
{
  // 1. BLOK TEXT
  if (type == 'text') {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Astral',
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // 2. BLOK IMAGE
  if (type == 'image') {
    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: mediaUrl.startsWith('http')
              ? Image.network(
                  mediaUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF42A5F5)),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image,
                            color: Colors.white54, size: 60),
                        SizedBox(height: 12),
                        Text('Gambar gagal dimuat',
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Astral')),
                      ],
                    ),
                  ),
                )
              : const Icon(Icons.image, color: Colors.white54, size: 60),
        ),
      ),
    );
  }

  // 3. BLOK VIDEO
  if (type == 'video') {
    return _StoryVideoWidget(mediaUrl: mediaUrl); 
  }

  // 4. CADANGAN (JIKA TYPE BUKAN TEXT, IMAGE, ATAU VIDEO)
  return const SizedBox.shrink(); 
}

// ═══════════════════════════════════════════════════════════════════════════
// 11. STORY VIEWER WIDGET — auto dispose video (ANTI DOUBLE SOUND)
// ═══════════════════════════════════════════════════════════════════════════
class _StoryViewerWidget extends StatefulWidget {
  final String type;
  final String content;
  final String mediaUrl;
  final String statusUsername;
  final bool isMine;
  final String storyId;
  final String sessionKey;
  final String baseUrl;
  final void Function(String deletedId) onDeleteMine;

  const _StoryViewerWidget({
    required this.type,
    required this.content,
    required this.mediaUrl,
    required this.statusUsername,
    required this.isMine,
    required this.storyId,
    required this.sessionKey,
    required this.baseUrl,
    required this.onDeleteMine,
  });

  @override
  State<_StoryViewerWidget> createState() => _StoryViewerWidgetState();
}

class _StoryViewerWidgetState extends State<_StoryViewerWidget> {
  int _likesCount = 0;
  int _commentsCount = 0;
  int _viewsCount = 0;
  bool _isLiked = false;
  List<dynamic> _comments = [];
  bool _socialLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchSocialData();
  }

  @override
  void dispose() {
    // ✅ PASTIKAN VIDEO MATI + GLOBAL FLAG RESET
    _activeVideoCount = 0;
    debugPrint('✅ _StoryViewerWidget disposed (video stopped)');
    super.dispose();
  }

  Future<void> _fetchSocialData() async {
    if (widget.storyId.isEmpty || _socialLoaded) return;
    _socialLoaded = true;

    try {
      final res = await http.get(
        Uri.parse(
            '$baseUrl/api/stories/${widget.storyId}/social?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true) {
          setState(() {
            _likesCount = data['likesCount'] ?? 0;
            _commentsCount = data['commentsCount'] ?? 0;
            _viewsCount = data['viewsCount'] ?? 0;
            _isLiked = data['isLiked'] ?? false;
            _comments = data['comments'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Fetch social error: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final res = await http.post(
        Uri.parse(
            '$baseUrl/api/stories/${widget.storyId}/like?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true) {
          setState(() {
            _isLiked = data['liked'] ?? false;
            _likesCount = data['likesCount'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Like error: $e');
    }
  }

  void _openComments() async {
    List<dynamic> latest = _comments;
    try {
      final res = await http.get(
        Uri.parse(
            '$baseUrl/api/stories/${widget.storyId}/comments?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true) {
          latest = data['comments'] ?? [];
        }
      }
    } catch (_) {}

    if (!mounted) return;

    _showCommentSheet(
      context,
      widget.storyId,
      latest,
      widget.sessionKey,
      widget.baseUrl,
      (newComments, newCount) {
        if (mounted) {
          setState(() {
            _comments = newComments;
            _commentsCount = newCount;
          });
        }
      },
    );
  }

  Future<void> _deleteStory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Story?',
            style: TextStyle(color: Colors.white, fontFamily: 'Astral')),
        content: const Text(
            'Story ini akan dihapus permanen. Lanjutkan?',
            style: TextStyle(color: Colors.white70, fontFamily: 'Astral')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: Colors.white54, fontFamily: 'Astral')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white, fontFamily: 'Astral')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await http.delete(
        Uri.parse(
            '$baseUrl/api/stories/${widget.storyId}?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      if (data['valid'] == true && mounted) {
        widget.onDeleteMine(widget.storyId);
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Story berhasil dihapus!',
                  style: TextStyle(fontFamily: 'Astral')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // ─── KONTEN ─────────────────────────────────
            Positioned.fill(
              child: _buildStoryContent(
                type: widget.type,
                content: widget.content,
                mediaUrl: widget.mediaUrl,
              ),
            ),

            // ─── HEADER OVERLAY ─────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                        ),
                        child: Icon(
                          widget.type == 'video'
                              ? Icons.videocam
                              : widget.type == 'image'
                                  ? Icons.image
                                  : Icons.text_fields,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.statusUsername,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Astral',
                              ),
                            ),
                            if (widget.isMine)
                              const Text(
                                '(Story Saya)',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontFamily: 'Astral',
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.isMine)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                          onPressed: _deleteStory,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── BOTTOM BAR — LIKE, COMMENT, VIEW ───────
            if (widget.storyId.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.95),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // LIKE
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isLiked
                                  ? Colors.redAccent.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _isLiked
                                    ? Colors.redAccent
                                    : Colors.white30,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isLiked
                                      ? Colors.redAccent
                                      : Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_likesCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // COMMENT
                        GestureDetector(
                          onTap: _openComments,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white30, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  '$_commentsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // VIEW
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border:
                                Border.all(color: Colors.white30, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.remove_red_eye_outlined,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '$_viewsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STORY VIDEO WIDGET — StatefulWidget (ANTI DOUBLE SOUND, AUTO DISPOSE)
// ═══════════════════════════════════════════════════════════════════════════
class _StoryVideoWidget extends StatefulWidget {
  final String mediaUrl;
  const _StoryVideoWidget({required this.mediaUrl});

  @override
  State<_StoryVideoWidget> createState() => _StoryVideoWidgetState();
}

class _StoryVideoWidgetState extends State<_StoryVideoWidget> {
  BetterPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _activeVideoCount++;
    debugPrint('🎬 Video player created. Active count: $_activeVideoCount');

    // Kalau ada lebih dari 1, berarti ada leak — matikan yang lama
    if (_activeVideoCount > 1) {
      debugPrint('⚠️ Multiple video detected! Forcing cleanup...');
    }

    _initPlayer();
  }

  Future<void> _initPlayer() async {
  try {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.mediaUrl,
      videoFormat: BetterPlayerVideoFormat.other,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
      },
    );

    final config = BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,  // ✅ WAJIB false biar ga double
      fit: BoxFit.cover,
      aspectRatio: 16 / 9,
      autoDispose: false,
      allowedScreenSleep: false,
      startAt: Duration.zero,
      handleLifecycle: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: true,
        showControlsOnInitialize: false,
        enablePlayPause: true,
        enableProgressBar: true,
        enableProgressText: true,
        enableFullscreen: true,
        enableMute: true,
        enableSkips: true,
        playerTheme: BetterPlayerTheme.custom,
        controlBarColor: Colors.black54,
        progressBarPlayedColor: const Color(0xFF42A5F5),
        progressBarHandleColor: const Color(0xFF42A5F5),
        progressBarBufferedColor: Colors.white24,
        progressBarBackgroundColor: Colors.white12,
        playIcon: Icons.play_arrow_rounded,
        pauseIcon: Icons.pause_rounded,
        muteIcon: Icons.volume_off_rounded,
        unMuteIcon: Icons.volume_up_rounded,
        fullscreenEnableIcon: Icons.fullscreen_rounded,
        fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
      ),
    );

    // ✅ BetterPlayerController AUTO-INIT saat dibuat — TIDAK perlu .initialize()
    _controller = BetterPlayerController(
      config,
      betterPlayerDataSource: dataSource,
    );

    // Listener event
    _controller?.addEventsListener((event) {
      if (!mounted) return;
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        setState(() => _isLoading = false);
      } else if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });

    // Timeout fallback — kalau 5 detik ga ada event, set loading false
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });

  } catch (e) {
    debugPrint('❌ Video init error: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }
}

  @override
  void dispose() {
    // ✅ HENTIKAN & DISPOSE PLAYER
    try {
      _controller?.pause();
      _controller?.dispose(forceDispose: true);
      _controller = null;
    } catch (e) {
      debugPrint('⚠️ Dispose error: $e');
    }

    _activeVideoCount--;
    if (_activeVideoCount < 0) _activeVideoCount = 0;

    debugPrint('🛑 Video disposed. Active count: $_activeVideoCount');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 60),
              SizedBox(height: 12),
              Text(
                'Gagal memuat video',
                style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Astral',
                    fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_controller != null && !_isLoading)
            BetterPlayer(controller: _controller!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF42A5F5)),
            ),
        ],
      ),
    );
  }
}

// ─── QUICK ACTION DATA ─────────────────────────────────────────────
class _QuickActionData {
  final IconData icon;
  final IconData bgIcon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _QuickActionData({required this.icon, required this.bgIcon, required this.title, required this.subtitle, required this.gradient, required this.onTap});
}

// ─── NAV ITEM ──────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  final bool isCenter;
  const _NavItem({required this.icon, required this.label, this.isCenter = false});
}

// ─── SLIDE ROUTE ───────────────────────────────────────────────────
PageRoute _slideRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 350),
  transitionsBuilder: (_, anim, __, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: FadeTransition(opacity: anim, child: child)),
);

// ─── SWIPE UP HANDLE ───────────────────────────────────────────────
class _SwipeUpHandle extends StatefulWidget {
  final VoidCallback onTap;
  final Color accentColor;
  final Color lightColor;
  final double bottomPadding;
  const _SwipeUpHandle({required this.onTap, required this.accentColor, required this.lightColor, required this.bottomPadding});
  @override
  State<_SwipeUpHandle> createState() => _SwipeUpHandleState();
}

class _SwipeUpHandleState extends State<_SwipeUpHandle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final double offsetY = -3 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          final double glowOpacity = 0.18 + 0.22 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
          return Padding(
            padding: EdgeInsets.only(bottom: 6 + widget.bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(offset: Offset(0, offsetY), child: Opacity(opacity: 0.7 + 0.3 * (0.5 + 0.5 * math.sin(t * 2 * math.pi)), child: Icon(Icons.keyboard_arrow_up_rounded, color: widget.lightColor.withOpacity(0.7), size: 16))),
                const SizedBox(height: 2),
                Container(width: 44, height: 4, decoration: BoxDecoration(color: widget.lightColor.withOpacity(0.5), borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: widget.accentColor.withOpacity(glowOpacity), blurRadius: 12, spreadRadius: 1)])),
              ],
            ),
          );
        },
      ),
    );
  }
}