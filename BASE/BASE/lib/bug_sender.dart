import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'api_config.dart';

// ─── ROLE HELPER ──────────────────────────────────────────────────────────────
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

Color roleColor(String role) {
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

IconData roleIcon(String role) {
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

String roleDisplayName(String role) {
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

// ─── VURTAX X RAT THEME ─────────────────────────────────────────────────────────────
class _C {
  static const bg         = Color(0xFFDCEEFB);
  static const surface    = Color(0xFFFFFFFF);
  static const card       = Color(0xFFF0F7FF);
  static const border     = Color(0xFF42A5F5);
  static const borderLit  = Color(0xFF64B5F6);

  static const blue       = Color(0xFF1565C0);
  static const blueMid    = Color(0xFF1565C0);
  static const blueLight  = Color(0xFF42A5F5);
  static const blueFrost  = Color(0xFF64B5F6);

  static const green      = Color(0xFF22C55E);
  static const greenDim   = Color(0xFF16A34A);
  static const red        = Color(0xFFEF4444);
  static const amber      = Color(0xFFF59E0B);  // ✅ untuk global

  static const text       = Color(0xFF000000);
  static const textSub    = Color(0x8A000000);
  static const textDim    = Color(0x61000000);

  static const LinearGradient btnGrad = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient globalGrad = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient btnRedGrad = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class BugSenderPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const BugSenderPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<BugSenderPage> createState() => _BugSenderPageState();
}

class _BugSenderPageState extends State<BugSenderPage>
    with TickerProviderStateMixin {
  
  List<dynamic> privateSenderList = [];
  List<dynamic> globalSenderList = [];
  List<dynamic> senderList = [];
  
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  String _currentTab = 'private';
  Timer? _refreshTimer;

  late AnimationController _bgOrbitCtrl;
  late AnimationController _headerCtrl;
  late AnimationController _fabPulseCtrl;
  late AnimationController _listCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _fabScale;
  late Animation<double> _fabGlow;

  @override
  void initState() {
    super.initState();

    _bgOrbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _fabPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _fabScale = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _fabPulseCtrl, curve: Curves.easeInOut));
    _fabGlow  = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _fabPulseCtrl, curve: Curves.easeInOut));

    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _headerCtrl.forward();
    _fetchSenders();

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && !isLoading) {
        _fetchSenders(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _bgOrbitCtrl.dispose();
    _headerCtrl.dispose();
    _fabPulseCtrl.dispose();
    _listCtrl.dispose();
    _refreshTimer?.cancel();  
    super.dispose();
  }

  // ─── API ────────────────────────────────────────────────────────────────────
  Future<void> _fetchSenders({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final privateRes = await http.get(
        Uri.parse("$baseUrl/mySender?key=${widget.sessionKey}"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      List<dynamic> privateConns = [];
      if (privateRes.statusCode == 200) {
        final data = jsonDecode(privateRes.body);
        if (data["connections"] != null) {
          if (data["connections"] is Map) {
            final connMap = data["connections"] as Map;
            if (connMap["private"] != null) {
              privateConns = connMap["private"] as List<dynamic>;
            }
          } else if (data["connections"] is List) {
            privateConns = data["connections"] as List<dynamic>;
          }
        } else if (data["senderList"] != null) {
          privateConns = data["senderList"] as List<dynamic>;
        } else if (data["data"] != null) {
          privateConns = data["data"] as List<dynamic>;
        }

        // Handle developer fallback dari backend
if (data["isDeveloperFallback"] == true &&
    data["borrowedAvailable"] != null) {
  privateConns = data["borrowedAvailable"] as List<dynamic>;
  privateConns = privateConns.map((c) {
    final map = Map<String, dynamic>.from(c as Map);
    map['type'] = 'private';  // ✅ Paksa jadi private biar bisa dipilih
    map['status'] = 'connected';
    return map;
  }).toList();
}

// ✅ FALLBACK: kalau developer dan private masih kosong, 
// ambil dari global as private
if (widget.role.toLowerCase() == 'developer' && privateConns.isEmpty) {
  final globalRes2 = await http.get(
    Uri.parse("$baseUrl/getPublicSenders?key=${widget.sessionKey}"),
  ).timeout(const Duration(seconds: 10));
  
  if (globalRes2.statusCode == 200) {
    final gData = jsonDecode(globalRes2.body);
    if (gData['valid'] == true && gData['senders'] != null) {
      privateConns = (gData['senders'] as List).map((s) {
        final session = s['session']?.toString() ?? '';
        return {
          'sessionName': session,
          'number': session,
          'type': 'private',
          'status': 'connected',
          'isPublic': true,
          'borrowed': true,
        };
      }).where((s) => (s['sessionName'] as String).isNotEmpty).toList();
    }
  }
}
      }

      final globalRes = await http.get(
  Uri.parse("$baseUrl/mySender?key=${widget.sessionKey}"), // ✅ GANTI JADI /mySender
  headers: {'Content-Type': 'application/json'},
).timeout(const Duration(seconds: 15));

      List<dynamic> globalConns = [];
if (globalRes.statusCode == 200) {
  final data = jsonDecode(globalRes.body);
  if (data['valid'] == true && data['connections'] != null && data['connections']['global'] != null) {
  final senders = List<dynamic>.from(data['connections']['global']); // ✅ BACA DARI SINI
  globalConns = senders.map((s) {
    final session = s['sessionName']?.toString() ?? "";
    final isActive = s['status'] == 'connected';
    return {
      'sessionName': session,
      'number': s['number']?.toString() ?? session,
      'type': 'global',
      'isActive': isActive,
      // ... sesuaikan field lainnya
    };
  }).toList();
}
}

// ✅ FIX: Hapus sender global yang juga ada di private milik user ini
final privateIds = privateConns
    .map((c) => c['sessionName']?.toString() ?? c['number']?.toString())
    .toSet();
globalConns = globalConns
    .where((g) => !privateIds.contains(g['sessionName']?.toString()))
    .toList();

      privateConns = privateConns.map((c) {
        final map = Map<String, dynamic>.from(c as Map);
        map['type'] = map['type'] ?? 'private';
        return map;
      }).toList();

      if (mounted) {
        setState(() {
          privateSenderList = privateConns;
          globalSenderList = globalConns;
          senderList = [...privateConns, ...globalConns];
          errorMessage = null;
        });
        _listCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() => errorMessage = "Connection failed: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshSenders() async {
    setState(() => isRefreshing = true);
    await _fetchSenders();
  }

  bool get canDeleteSender {
    final role = widget.role.toLowerCase();
    return ['developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin', 'reseller'].contains(role);
  }

  // ✅ Selalu kirim sebagai private, backend akan otomatis promote ke global
  Future<void> _addSender(String number) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/getPairing?key=${widget.sessionKey}&number=$number&type=private")
      ).timeout(const Duration(seconds: 30));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true) {
          _showPairingCodeDialog(number, data['pairingCode'] ?? data['code'] ?? '000000');
        } else {
          _toast(data['message'] ?? "Failed to generate pairing code", error: true);
        }
      } else {
        _toast("Server error: ${res.statusCode}", error: true);
      }
    } catch (e) {
      _toast("Connection failed: ${e.toString()}", error: true);
    } finally {
      setState(() => isLoading = false);
      _fetchSenders();
    }
  }

  Future<void> _deleteSender(String senderId) async {
    if (!canDeleteSender) {
      _toast("Role ${roleDisplayName(widget.role)} tidak punya izin hapus sender!", error: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/deleteSender?key=${widget.sessionKey}&id=$senderId")
      ).timeout(const Duration(seconds: 15));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true) {
          _toast("Sender deleted successfully");
          _fetchSenders();
        } else {
          _toast(data["message"] ?? "Failed", error: true);
        }
      } else {
        _toast("Server error: ${res.statusCode}", error: true);
      }
    } catch (e) {
      _toast("Connection failed: ${e.toString()}", error: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(error ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'Astral'))),
      ]),
      backgroundColor: error ? _C.red : _C.greenDim,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────
  void _showAddSenderDialog() {
    final phoneCtrl = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => StatefulBuilder(
        builder: (ctx2, setStateDialog) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _DialogShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  _DialogIcon(icon: Icons.add_link_rounded, color: _C.blueMid),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tambah Sender',
                          style: TextStyle(color: _C.text, fontSize: 17,
                              fontWeight: FontWeight.w700, fontFamily: 'Astral')),
                      Text('Masukkan nomor WhatsApp',
                          style: TextStyle(color: _C.textSub, fontSize: 12, fontFamily: 'Astral')),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),
                _InputField(
                  controller: phoneCtrl,
                  label: 'Nomor Telepon',
                  hint: '628xxx',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _OutlineBtn(
                    label: 'Batal',
                    onTap: () => Navigator.pop(ctx),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _GradBtn(
                    label: 'Generate Pairing',
                    icon: Icons.link_rounded,
                    onTap: () {
                      final num = phoneCtrl.text.trim();
                      if (num.isEmpty) {
                        _toast('Masukkan nomor telepon', error: true);
                        return;
                      }
                      Navigator.pop(ctx);
                      _addSender(num);
                    },
                  )),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.border),
                  ),
                  child: Row(
                    children: [
                      Icon(roleIcon(widget.role), color: roleColor(widget.role), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Role: ${roleDisplayName(widget.role)}',
                        style: TextStyle(
                          color: roleColor(widget.role),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Astral',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _C.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Auto Global',
                          style: TextStyle(
                            color: _C.green,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  void _showPairingCodeDialog(String number, String code) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: _PairingDialog(
          number: number,
          code: code,
          onClose: () {
            Navigator.pop(ctx);
            _fetchSenders();
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirm(Map<String, dynamic> sender) async {
    if (!canDeleteSender) {
      _toast("Role ${roleDisplayName(widget.role)} tidak punya izin hapus sender!", error: true);
      return;
    }

    final senderName = sender['sessionName'] ?? sender['number'] ?? sender['id'] ?? 'Unknown';
    final isGlobal = sender['type'] == 'global' || sender['isPublic'] == true;

    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _DialogShell(
          accentColor: _C.red,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogIcon(icon: Icons.delete_forever_rounded, color: _C.red),
              const SizedBox(height: 16),
              Text('Hapus Sender?',
                  style: TextStyle(color: _C.text, fontSize: 18,
                      fontWeight: FontWeight.w700, fontFamily: 'Astral')),
              const SizedBox(height: 10),
              Text(
                "Sender '$senderName' ${isGlobal ? '(GLOBAL)' : '(PRIVATE)'} akan dihapus permanen.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _C.textSub, fontSize: 13, height: 1.5, fontFamily: 'Astral'),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _OutlineBtn(
                  label: 'Batal',
                  onTap: () => Navigator.pop(ctx, false),
                )),
                const SizedBox(width: 12),
                Expanded(child: _GradBtn(
                  label: 'Hapus',
                  icon: Icons.delete_outline_rounded,
                  gradient: _C.btnRedGrad,
                  onTap: () => Navigator.pop(ctx, true),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) _deleteSender(sender['id'] ?? senderName);
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────────
  Widget _buildSenderCard(Map<String, dynamic> sender, int index) {
    final name = sender['sessionName'] ?? sender['number'] ?? sender['id'] ?? 'WhatsApp Sender';
    final isConn = sender['status'] == 'connected' || sender['isActive'] == true;
    final isGlobal = sender['type'] == 'global' || sender['isPublic'] == true;

    return _StaggerItem(
      index: index,
      child: _SenderCard(
        name: name,
        isConnected: isConn,
        isGlobal: isGlobal,
        role: widget.role,
        canDelete: canDeleteSender,
        onRefresh: _refreshSenders,
        onDelete: () => _showDeleteConfirm(sender),
      ),
    );
  }

  Widget _buildEmptyState() {
  // Kalau developer, sembunyikan empty state — biarkan fallback backend handle
  if (widget.role.toLowerCase() == 'developer' && _currentTab == 'private') {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: _C.blueMid, size: 48),
            const SizedBox(height: 16),
            Text('Developer Mode',
                style: TextStyle(
                  color: _C.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Astral',
                )),
            const SizedBox(height: 8),
            Text(
              'Kamu bisa kirim bug tanpa sender private.\nSistem akan otomatis pinjam sender dari pool global.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _C.textSub,
                fontSize: 13,
                height: 1.5,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 24),
            _GradBtn(
              label: 'Refresh Pool',
              icon: Icons.refresh_rounded,
              onTap: _refreshSenders,
            ),
          ],
        ),
      ),
    );
  }

  return _EmptyState(
    onAdd: _showAddSenderDialog,
    role: widget.role,
    isGlobalTab: _currentTab == 'global',
  );
}

  Widget _buildErrorState() {
    return _ErrorState(
      message: errorMessage ?? 'Unknown error',
      onRetry: _fetchSenders,
    );
  }

  Widget _buildLoading() {
    return const Center(child: _DotsLoader());
  }

  Widget _buildTabSelector() {
    final privateCount = privateSenderList.length;
    final globalCount = globalSenderList.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 'private'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: _currentTab == 'private' ? _C.btnGrad : null,
                  color: _currentTab == 'private' ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_rounded,
                        color:
                            _currentTab == 'private' ? Colors.white : _C.textSub,
                        size: 16),
                    const SizedBox(width: 6),
                    Text('Private ($privateCount)',
                        style: TextStyle(
                            color: _currentTab == 'private'
                                ? Colors.white
                                : _C.textSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Astral')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 'global'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: _currentTab == 'global' ? _C.globalGrad : null,
                  color: _currentTab == 'global' ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public_rounded,
                        color:
                            _currentTab == 'global' ? Colors.white : _C.textSub,
                        size: 16),
                    const SizedBox(width: 6),
                    Text('Global ($globalCount)',
                        style: TextStyle(
                            color: _currentTab == 'global'
                                ? Colors.white
                                : _C.textSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Astral')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: _AnimatedBg(controller: _bgOrbitCtrl)),
          SafeArea(
            child: _buildBody(),
          ),
          if (isLoading && senderList.isNotEmpty)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
              left: 0, right: 0,
              child: const Center(child: _ThinProgress()),
            ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _AppBarBtn(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
      title: FadeTransition(
        opacity: _headerFade,
        child: SlideTransition(
          position: _headerSlide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bug Sender',
                  style: TextStyle(
                    color: _C.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    fontFamily: 'Astral',
                  )),
              Text('${senderList.length} sender • ${roleDisplayName(widget.role)}',
                  style: TextStyle(color: _C.textSub, fontSize: 11, fontFamily: 'Astral')),
            ],
          ),
        ),
      ),
      actions: [
        _AppBarBtn(
          icon: Icons.refresh_rounded,
          onTap: isLoading ? null : _refreshSenders,
          spinning: isRefreshing,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading && senderList.isEmpty) return _buildLoading();
    if (errorMessage != null && senderList.isEmpty) return _buildErrorState();

    final currentList =
        _currentTab == 'private' ? privateSenderList : globalSenderList;

    return RefreshIndicator(
      color: _C.blueMid,
      backgroundColor: _C.card,
      onRefresh: _refreshSenders,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildTabSelector()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _StatStrip(
                total: currentList.length,
                role: widget.role,
                isGlobal: _currentTab == 'global',
              ),
            ),
          ),
          if (currentList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildSenderCard(
                      Map<String, dynamic>.from(currentList[i]), i),
                  childCount: currentList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _fabPulseCtrl,
      builder: (_, child) => Transform.scale(
        scale: _fabScale.value,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: _C.btnGrad,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _C.blueMid.withOpacity(_fabGlow.value),
                blurRadius: 28,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.white24,
              onTap: _showAddSenderDialog,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SENDER CARD
// ═══════════════════════════════════════════════════════════════════════════
class _SenderCard extends StatefulWidget {
  final String name;
  final bool isConnected;
  final bool isGlobal;
  final String role;
  final bool canDelete;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;

  const _SenderCard({
    required this.name,
    required this.isConnected,
    required this.isGlobal,
    required this.role,
    required this.canDelete,
    required this.onRefresh,
    required this.onDelete,
  });

  @override
  State<_SenderCard> createState() => _SenderCardState();
}

class _SenderCardState extends State<_SenderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _dot;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _dot = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isGlobal ? _C.amber : _C.border;
    final topGradient = widget.isGlobal 
        ? const [Colors.transparent, _C.amber, Colors.transparent]
        : const [Colors.transparent, _C.blueMid, Colors.transparent];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: (widget.isGlobal ? _C.amber : _C.blue).withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: topGradient),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (widget.isGlobal ? _C.amber : _C.blue).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: borderColor),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                widget.isGlobal ? Icons.public_rounded : FontAwesomeIcons.whatsapp,
                                color: widget.isGlobal ? _C.amber : _C.blueLight,
                                size: 24,
                              ),
                            ),
                            Positioned(
                              right: 5, bottom: 5,
                              child: AnimatedBuilder(
                                animation: _dot,
                                builder: (_, __) => Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isConnected
                                        ? _C.green.withOpacity(_dot.value)
                                        : _C.red,
                                    boxShadow: widget.isConnected
                                        ? [BoxShadow(
                                            color: _C.green.withOpacity(
                                                _dot.value * 0.6),
                                            blurRadius: 6,
                                          )]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(widget.name,
                                      style: TextStyle(
                                          color: _C.text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Astral')),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: widget.isGlobal
                                        ? _C.amber.withOpacity(0.15)
                                        : _C.blueMid.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: widget.isGlobal
                                          ? _C.amber.withOpacity(0.4)
                                          : _C.blueMid.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    widget.isGlobal ? 'GLOBAL' : 'PRIVATE',
                                    style: TextStyle(
                                      color: widget.isGlobal ? _C.amber : _C.blueMid,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      fontFamily: 'Astral',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(children: [
                              AnimatedBuilder(
                                animation: _dot,
                                builder: (_, __) => Container(
                                  width: 6, height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isConnected
                                        ? _C.green.withOpacity(_dot.value)
                                        : _C.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isConnected ? 'Connected' : 'Disconnected',
                                style: TextStyle(
                                  color: widget.isConnected ? _C.green : _C.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Astral',
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.isConnected
                              ? _C.green.withOpacity(0.1)
                              : _C.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.isConnected
                                ? _C.green.withOpacity(0.3)
                                : _C.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.isConnected ? 'ACTIVE' : 'OFFLINE',
                          style: TextStyle(
                            color: widget.isConnected ? _C.green : _C.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: borderColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: _CardBtn(
                        label: 'Refresh',
                        icon: Icons.refresh_rounded,
                        onTap: widget.onRefresh,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (widget.canDelete)
                      Expanded(
                        child: _CardBtn(
                          label: 'Hapus',
                          icon: Icons.delete_outline_rounded,
                          isDestructive: true,
                          onTap: widget.onDelete,
                        ),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Button ──────────────────────────────────────────────────────────────
class _CardBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback onTap;

  const _CardBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_CardBtn> createState() => _CardBtnState();
}

class _CardBtnState extends State<_CardBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? _C.red : _C.blueLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        height: 42,
        decoration: BoxDecoration(
          color: _pressed ? color.withOpacity(0.15) : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pressed ? color.withOpacity(0.5) : color.withOpacity(0.2),
          ),
        ),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 130),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Astral',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pairing Code Dialog ──────────────────────────────────────────────────────
class _PairingDialog extends StatefulWidget {
  final String number;
  final String code;
  final VoidCallback onClose;

  const _PairingDialog({
    required this.number,
    required this.code,
    required this.onClose,
  });

  @override
  State<_PairingDialog> createState() => _PairingDialogState();
}

class _PairingDialogState extends State<_PairingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glow;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.9)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.blue.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: _C.blueMid.withOpacity(_glow.value * 0.4),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                    color: _C.blueMid.withOpacity(_glow.value * 0.5)),
              ),
              child: const Icon(Icons.phonelink_lock_rounded,
                  color: _C.blueLight, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text('Kode Pairing',
              style: TextStyle(
                  color: _C.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Astral')),
          const SizedBox(height: 6),
          Text('Nomor: ${widget.number}',
              style: TextStyle(color: _C.textSub, fontSize: 13, fontFamily: 'Astral')),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _C.blueMid.withOpacity(_glow.value * 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.blueMid.withOpacity(_glow.value * 0.25),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                widget.code,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.blueMid.withOpacity(0.9 + _glow.value * 0.1),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CopyBtn(
            code: widget.code,
            onCopied: () => setState(() => _copied = true),
            copied: _copied,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _C.blue.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: _C.textSub, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Buka WhatsApp → Linked Devices → Link a device → Enter code',
                  style: TextStyle(color: _C.textSub, fontSize: 11, height: 1.4, fontFamily: 'Astral'),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          _GradBtn(
            label: 'Selesai & Refresh',
            icon: Icons.check_rounded,
            fullWidth: true,
            onTap: widget.onClose,
          ),
        ],
      ),
    );
  }
}

// ─── Copy Button ──────────────────────────────────────────────────────────────
class _CopyBtn extends StatelessWidget {
  final String code;
  final VoidCallback onCopied;
  final bool copied;

  const _CopyBtn({
    required this.code,
    required this.onCopied,
    required this.copied,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: _PressableInk(
        onTap: copied ? null : () async {
          await Clipboard.setData(ClipboardData(text: code));
          onCopied();
        },
        borderRadius: 12,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: copied ? _C.green.withOpacity(0.12) : _C.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: copied ? _C.green.withOpacity(0.4) : _C.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  copied ? Icons.check_rounded : Icons.copy_rounded,
                  key: ValueKey(copied),
                  color: copied ? _C.green : _C.textSub,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  copied ? 'Disalin!' : 'Salin Kode',
                  key: ValueKey(copied),
                  style: TextStyle(
                    color: copied ? _C.green : _C.textSub,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'Astral',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Strip ──────────────────────────────────────────────────────────────
class _StatStrip extends StatelessWidget {
  final int total;
  final String role;
  final bool isGlobal;

  const _StatStrip({
    required this.total,
    required this.role,
    this.isGlobal = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isGlobal ? _C.amber : _C.blueLight;
    final icon = isGlobal ? Icons.public_rounded : Icons.wifi_tethering_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isGlobal ? _C.amber : _C.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text('$total sender ${isGlobal ? "global" : "private"}',
              style: TextStyle(
                  color: _C.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Astral')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor(role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: roleColor(role).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(roleIcon(role), color: roleColor(role), size: 10),
                const SizedBox(width: 4),
                Text(
                  roleDisplayName(role).toUpperCase(),
                  style: TextStyle(
                    color: roleColor(role),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontFamily: 'Astral',
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

// ─── Stagger Item ────────────────────────────────────────────────────────────
class _StaggerItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggerItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 70).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: ch),
      ),
      child: child,
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatefulWidget {
  final VoidCallback onAdd;
  final String role;
  final bool isGlobalTab;

  const _EmptyState({
    required this.onAdd, 
    required this.role,
    this.isGlobalTab = false,
  });

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isGlobal = widget.isGlobalTab;
    final iconColor = isGlobal ? _C.amber : _C.blueLight;
    final borderColor = isGlobal ? _C.amber : _C.borderLit;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (_, ch) => Transform.translate(
                  offset: Offset(0, _float.value), child: ch),
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: _C.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: (isGlobal ? _C.amber : _C.blue).withOpacity(0.2),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Icon(
                  isGlobal ? Icons.public_off_rounded : FontAwesomeIcons.whatsapp,
                  color: iconColor,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isGlobal ? 'Belum Ada Global Sender' : 'Belum Ada Sender',
              style: TextStyle(
                color: _C.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isGlobal
    ? 'Global sender dipakai bersama semua user.\nTambahkan sender untuk berkontribusi.'
    : 'Belum ada sender private.\nTambahkan nomor WhatsApp untuk memulai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _C.textSub,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 36),
            _GradBtn(
              label: 'Tambah Sender',
              icon: Icons.add_rounded,
              onTap: widget.onAdd,
              gradient: isGlobal ? _C.globalGrad : _C.btnGrad,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _C.red.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: _C.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: _C.red, size: 30),
            ),
            const SizedBox(height: 24),
            Text('Koneksi Gagal',
                style: TextStyle(
                    color: _C.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Astral')),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _C.textSub, fontSize: 13, height: 1.5, fontFamily: 'Astral')),
            const SizedBox(height: 32),
            _GradBtn(
              label: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable primitives ─────────────────────────────────────────────────────
class _DialogShell extends StatelessWidget {
  final Widget child;
  final Color? accentColor;

  const _DialogShell({required this.child, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? _C.blueMid;
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 50,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _DialogIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DialogIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _GradBtn extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final bool fullWidth;

  const _GradBtn({
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = _C.btnGrad,
    this.fullWidth = false,
  });

  @override
  State<_GradBtn> createState() => _GradBtnState();
}

class _GradBtnState extends State<_GradBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) { setState(() => _down = false); widget.onTap(); },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 46,
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.fullWidth ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(13),
            boxShadow: _down ? [] : [
              BoxShadow(
                color: _C.blueMid.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 17),
                const SizedBox(width: 8),
              ],
              Text(widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                    fontFamily: 'Astral',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) { setState(() => _down = false); widget.onTap(); },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 46,
        decoration: BoxDecoration(
          color: _down ? _C.border.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _down ? _C.textDim : _C.border),
        ),
        child: Center(
          child: Text(widget.label,
              style: TextStyle(
                  color: _C.textSub,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Astral')),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
          color: _C.text, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Astral'),
      cursorColor: _C.blueMid,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: _C.textSub, fontSize: 13, fontFamily: 'Astral'),
        hintStyle: TextStyle(color: _C.textDim, fontFamily: 'Astral'),
        floatingLabelStyle:
            TextStyle(color: _C.blueMid, fontSize: 12, fontFamily: 'Astral'),
        prefixIcon: Icon(icon, color: _C.textSub, size: 18),
        filled: true,
        fillColor: _C.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.blueMid, width: 1.5)),
      ),
    );
  }
}

class _AppBarBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool spinning;

  const _AppBarBtn({required this.icon, this.onTap, this.spinning = false});

  @override
  State<_AppBarBtn> createState() => _AppBarBtnState();
}

class _AppBarBtnState extends State<_AppBarBtn>
    with SingleTickerProviderStateMixin {
  bool _down = false;
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didUpdateWidget(_AppBarBtn old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !old.spinning) {
      _spinCtrl.repeat();
    } else if (!widget.spinning) {
      _spinCtrl.stop();
      _spinCtrl.reset();
    }
  }

  @override
  void dispose() { _spinCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) { setState(() => _down = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 40, height: 40,
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: _down ? _C.border : _C.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _C.border),
        ),
        child: AnimatedBuilder(
          animation: _spinCtrl,
          builder: (_, child) => Transform.rotate(
            angle: _spinCtrl.value * math.pi * 2,
            child: child,
          ),
          child: Icon(widget.icon,
              color: widget.onTap == null ? _C.textDim : _C.textSub,
              size: 18),
        ),
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_c.value - i / 3) % 1.0).clamp(0.0, 1.0);
          final scale = math.sin(t * math.pi);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: 0.4 + scale * 0.6,
              child: Container(
                width: 9, height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.blueMid.withOpacity(0.4 + scale * 0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ThinProgress extends StatelessWidget {
  const _ThinProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 2,
      child: const LinearProgressIndicator(
        backgroundColor: _C.border,
        color: _C.blueMid,
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
  }
}

class _PressableInk extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  const _PressableInk({
    required this.child,
    this.onTap,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: _C.blue.withOpacity(0.15),
        child: child,
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────
class _AnimatedBg extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBg({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(controller.value),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _C.border.withOpacity(0.35)
      ..strokeWidth = 0.5;
    const step = 38.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final cx = size.width * 0.5;
    final cy = size.height * 0.18;

    for (int i = 0; i < 3; i++) {
      final angle = (t * math.pi * 2) + (i * math.pi * 2 / 3);
      final r = 80.0 + i * 55.0;
      final ox = cx + math.cos(angle) * r * 0.3;
      final oy = cy + math.sin(angle) * r * 0.15;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            _C.blue.withOpacity(0.07 - i * 0.015),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(ox, oy), radius: r));
      canvas.drawCircle(Offset(ox, oy), r, paint);
    }

    final vigPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDCEEFB), Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.4), vigPaint);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}