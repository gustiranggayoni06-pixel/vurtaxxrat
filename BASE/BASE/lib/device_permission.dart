import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─── Config ───────────────────────────────────────────────────────────────────
const _kBase = 'http://cp.zyrostore.id:3594';

// ============================================================================
// VURTAX X RAT THEME COLORS (SAMA PERSIS DENGAN DASHBOARD PAGE)
// ============================================================================
class _C {
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
  static const textSecondary  = Color(0xFF3D6080);  // biru gelap
  static const textMuted      = Color(0xFF8A9BB0);  // abu-abu biru
  
  static const shadow         = Color(0x40000000);
  static const shadowHeavy    = Color(0x80000000);
  
  // ─── ALIAS UNTUK KOMPATIBILITAS ──────────────────────────────────
  static const red1 = red;
  static const red2 = border;
  static const red3 = red;
  static const red4 = red;
  static const gold = border;
  static const silver = textMuted;
  static const chrome = cardAlt;
  static const accent = red;
  static const accentL = border;
  static const textP = textPrimary;
  static const textS = textSecondary;
  static const textM = textMuted;
  static const s1 = card;
  static const s2 = cardAlt;
  static const s3 = surface3;
  static const borderLight = border;
}

// ============================================================================
// ROLE HELPERS (SAMA PERSIS DENGAN DASHBOARD PAGE)
// ============================================================================
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

bool isRoleAtLeast(String role, String target) {
  final rLevel = roleLevel[role.toLowerCase()] ?? 0;
  final tLevel = roleLevel[target.toLowerCase()] ?? 0;
  return rLevel >= tLevel;
}

// ─── Permission Store ────────────────────────────────────────────────────────
class DevicePermissionStore {

  /// Ambil permission user dari server
  static Future<PermissionResult> getFor(String username, String sessionKey) async {
    if (username.toLowerCase() == 'owner') {
      return PermissionResult(approved: true, allDevices: true, devices: []);
    }
    try {
      final res = await http.get(
        Uri.parse('$_kBase/devicePerms?key=$sessionKey&username=${Uri.encodeComponent(username)}'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d['valid'] == true) {
          return PermissionResult(
            approved: d['approved'] == true,
            allDevices: d['allDevices'] == true,
            devices: List<String>.from(d['devices'] ?? []),
          );
        }
      }
    } catch (e) {
      debugPrint('[DevicePerm] getFor error: $e');
    }
    return PermissionResult(approved: false, allDevices: false, devices: []);
  }

  /// Owner: set permission user ke server
  static Future<bool> setPerm(String ownerKey, String username,
      {required bool approved, required bool allDevices, required List<String> devices}) async {
    try {
      final res = await http.post(
        Uri.parse('$_kBase/setDevicePerm?key=$ownerKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'approved': approved,
          'allDevices': allDevices,
          'devices': devices,
        }),
      ).timeout(const Duration(seconds: 8));
      final d = jsonDecode(res.body);
      return d['valid'] == true;
    } catch (e) {
      debugPrint('[DevicePerm] setPerm error: $e');
      return false;
    }
  }

  /// Owner: hapus permission user
  static Future<bool> removePerm(String ownerKey, String username) async {
    return setPerm(ownerKey, username,
        approved: false, allDevices: false, devices: []);
  }

  /// Owner: ambil semua permission dari server
  static Future<Map<String, dynamic>> getAll(String ownerKey) async {
    try {
      final res = await http.get(
        Uri.parse('$_kBase/listDevicePerms?key=$ownerKey'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d['valid'] == true) return Map<String, dynamic>.from(d['perms'] ?? {});
      }
    } catch (e) {
      debugPrint('[DevicePerm] getAll error: $e');
    }
    return {};
  }
}

class PermissionResult {
  final bool approved, allDevices;
  final List<String> devices;
  PermissionResult({required this.approved, required this.allDevices, required this.devices});
  bool canSee(String? deviceId) {
    if (!approved) return false;
    if (allDevices) return true;
    return deviceId != null && devices.contains(deviceId);
  }
}

// ─── Owner Permission Manager ────────────────────────────────────────────────
class DevicePermissionManagerPage extends StatefulWidget {
  final String sessionKey;
  final List<dynamic> allDevices;
  const DevicePermissionManagerPage({
    super.key, required this.sessionKey, required this.allDevices});
  @override State<DevicePermissionManagerPage> createState() => _DPMState();
}

class _DPMState extends State<DevicePermissionManagerPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _perms = {};
  String _selectedUser = '';
  final _inputCtrl = TextEditingController();
  String _inputVal = '';
  bool _loading = true;
  bool _saving = false;
  
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override void initState() { 
    super.initState(); 
    _load();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }
  
  @override void dispose() { 
    _inputCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose(); 
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await DevicePermissionStore.getAll(widget.sessionKey);
    setState(() { _perms = data; _loading = false; });
  }

  List<String> get _users => _perms.keys.toList();
  bool _approved(String u) => _perms[u]?['approved'] == true;
  bool _hasAll(String u) => _perms[u]?['allDevices'] == true;
  List<String> _devices(String u) => List<String>.from(_perms[u]?['devices'] ?? []);

  Future<void> _addUser(String username) async {
    if (username.trim().isEmpty) return;
    final key = username.trim().toLowerCase();
    final ok = await DevicePermissionStore.setPerm(
      widget.sessionKey, key,
      approved: true, allDevices: true, devices: [],
    );
    if (ok) {
      await _load();
      setState(() { _selectedUser = key; _inputVal = ''; _inputCtrl.clear(); });
    }
  }

  Future<void> _update(String u, {bool? approved, bool? allDevices, List<String>? devices}) async {
    setState(() => _saving = true);
    final ok = await DevicePermissionStore.setPerm(
      widget.sessionKey, u,
      approved: approved ?? _approved(u),
      allDevices: allDevices ?? _hasAll(u),
      devices: devices ?? _devices(u),
    );
    if (ok) await _load();
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _C.bg,
    appBar: _buildAppBar(),
    body: _loading
        ? Center(
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.red, _C.border],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _C.red.withOpacity(0.2 * _glow.value),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        : Column(children: [
      // ─ Add user ──────────────────────────────────────────────────────
      _buildAddUserSection(),
      if (_users.isEmpty)
        Expanded(child: _buildEmptyState())
      else
        Expanded(child: _buildUserList()),
    ]),
  );

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _C.card,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_C.red, _C.border]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.devices_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'DEVICE ACCESS',
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontFamily: 'Astral',
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: _C.border),
      actions: [
        if (_saving)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: _C.border.withOpacity(0.3), width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const CircularProgressIndicator(
                color: _C.border,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, _C.red, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddUserSection() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.red.withOpacity(0.1), _C.border.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _C.cardAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  onChanged: (v) => setState(() => _inputVal = v),
                  style: const TextStyle(color: _C.textPrimary, fontSize: 13, fontFamily: 'Astral'),
                  decoration: const InputDecoration(
                    hintText: 'Ketik username...',
                    hintStyle: TextStyle(color: _C.textMuted, fontSize: 12, fontFamily: 'Astral'),
                    prefixIcon: Icon(Icons.person_rounded, color: _C.textSecondary, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => GestureDetector(
                onTap: () => _addUser(_inputVal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.red, _C.border, _C.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _C.red.withOpacity(0.2 * _glow.value),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: _C.red.withOpacity(0.1 * _glow.value),
                        blurRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: _C.border.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'TAMBAH',
                    style: TextStyle(
                      color: _C.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontFamily: 'Astral',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.card, _C.cardAlt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _C.border.withOpacity(0.2), width: 2),
            ),
            child: Icon(Icons.group_off_rounded, color: _C.textMuted, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'TIDAK ADA USER',
            style: TextStyle(
              color: _C.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ketik username untuk memberi akses',
            style: TextStyle(
              color: _C.textMuted,
              fontSize: 12,
              fontFamily: 'Astral',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.people_rounded, color: _C.textSecondary, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'DAFTAR USER',
                  style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontFamily: 'Astral',
                  ),
                ),
                const Spacer(),
                Text(
                  '${_users.length} user',
                  style: const TextStyle(
                    color: _C.textMuted,
                    fontSize: 11,
                    fontFamily: 'Astral',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _users.map((u) {
              final active = u == _selectedUser;
              final appr = _approved(u);
              return GestureDetector(
                onTap: () => setState(() => _selectedUser = u),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: active 
                        ? const LinearGradient(colors: [_C.red, _C.border])
                        : null,
                    color: active ? null : _C.cardAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active 
                          ? _C.border.withOpacity(0.3)
                          : (appr ? _C.border.withOpacity(0.2) : _C.border.withOpacity(0.1)),
                      width: active ? 1.5 : 1,
                    ),
                    boxShadow: active ? [
                      BoxShadow(
                        color: _C.red.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appr ? _C.success : _C.error,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        u,
                        style: TextStyle(
                          color: active ? _C.white : _C.textSecondary,
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedUser.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildUserDetailCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildUserDetailCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.card, _C.cardAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _C.border.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.red.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _C.border.withOpacity(0.15), width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_C.red, _C.border]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedUser,
                      style: const TextStyle(
                        color: _C.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Astral',
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    await DevicePermissionStore.removePerm(widget.sessionKey, _selectedUser);
                    setState(() => _selectedUser = '');
                    await _load();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _C.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _C.error.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_rounded, color: _C.error, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'HAPUS',
                          style: TextStyle(
                            color: _C.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Toggle approve
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(
                bottom: _approved(_selectedUser) 
                    ? BorderSide(color: _C.border.withOpacity(0.15), width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AKSES',
                      style: TextStyle(
                        color: _C.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontFamily: 'Astral',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _approved(_selectedUser) 
                            ? _C.success.withOpacity(0.08)
                            : _C.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _approved(_selectedUser) 
                              ? _C.success.withOpacity(0.15)
                              : _C.error.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _approved(_selectedUser) ? 'APPROVED' : 'DENIED',
                        style: TextStyle(
                          color: _approved(_selectedUser) ? _C.success : _C.error,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _approved(_selectedUser),
                  activeColor: _C.border,
                  inactiveTrackColor: _C.cardAlt,
                  onChanged: (v) => _update(_selectedUser, approved: v),
                ),
              ],
            ),
          ),

          // Device checklist
          if (_approved(_selectedUser) && !_hasAll(_selectedUser)) ...[
            Container(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices_rounded, color: _C.textSecondary, size: 14),
                      const SizedBox(width: 8),
                      const Text(
                        'DEVICE LIST',
                        style: TextStyle(
                          color: _C.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          fontFamily: 'Astral',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _C.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _C.red.withOpacity(0.15)),
                        ),
                        child: Text(
                          '${_devices(_selectedUser).length} dipilih',
                          style: const TextStyle(
                            color: _C.border,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.allDevices.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Belum ada device',
                          style: TextStyle(
                            color: _C.textMuted,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                    )
                  else
                    ...widget.allDevices.map((d) {
                      final id = d['id']?.toString() ?? '';
                      final model = d['model']?.toString() ?? 'Unknown';
                      final ip = d['ip']?.toString() ?? '-';
                      final allowed = _devices(_selectedUser).contains(id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: allowed 
                              ? LinearGradient(
                                  colors: [_C.red.withOpacity(0.04), _C.border.withOpacity(0.02)],
                                )
                              : null,
                          color: allowed ? null : _C.cardAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: allowed ? _C.border.withOpacity(0.25) : _C.border.withOpacity(0.1),
                            width: allowed ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: allowed ? _C.red.withOpacity(0.12) : _C.card,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.phone_android_rounded,
                                color: allowed ? _C.border : _C.textSecondary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model,
                                    style: TextStyle(
                                      color: allowed ? _C.textPrimary : _C.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Astral',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: $id  •  IP: $ip',
                                    style: const TextStyle(
                                      color: _C.textMuted,
                                      fontSize: 10,
                                      fontFamily: 'Astral',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: allowed,
                              activeColor: _C.border,
                              checkColor: _C.white,
                              side: BorderSide(color: _C.border.withOpacity(0.2)),
                              onChanged: (v) async {
                                final cur = List<String>.from(_devices(_selectedUser));
                                if (v == true) { if (!cur.contains(id)) cur.add(id); }
                                else cur.remove(id);
                                await _update(_selectedUser, devices: cur);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}