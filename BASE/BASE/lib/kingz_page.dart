// kingz_page.dart - KINGZ & FOUNDER PAGE
// ✅ KINGZ: Bisa create member, reseller, vip, admin, tk, owner, high owner
// ✅ FOUNDER: Bisa create member, reseller, vip, admin, tk, owner, high owner, kingz
// ✅ Durasi dropdown (1 Hari, 3 Hari, 7 Hari, 1 Bulan, Permanent)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'api_config.dart';

// ─── ROLE HELPERS (SINKRON DENGAN DASHBOARD) ──────────────────────────────
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

// ✅ KINGZ & FOUNDER CREATE PERMISSIONS
const List<String> kingzCreateRoles = ['member', 'reseller', 'vip', 'admin', 'tk', 'owner', 'high owner'];
const List<String> founderCreateRoles = ['member', 'reseller', 'vip', 'admin', 'tk', 'owner', 'high owner', 'kingz'];

class KingzPage extends StatefulWidget {
  final String sessionKey;
  final String? userRole;

  const KingzPage({super.key, required this.sessionKey, this.userRole});

  @override
  State<KingzPage> createState() => _KingzPageState();
}

class _KingzPageState extends State<KingzPage>
    with TickerProviderStateMixin {
  late String sessionKey;
  List<dynamic> fullUserList = [];
  List<dynamic> filteredList = [];

  // ✅ ROLE OPTIONS berdasarkan role user
  List<String> get roleOptions {
    final role = widget.userRole?.toLowerCase() ?? 'kingz';
    if (role == 'founder') {
      return ['member', 'reseller', 'vip', 'admin', 'tk', 'owner', 'high owner', 'kingz'];
    } else {
      return ['member', 'reseller', 'vip', 'admin', 'tk', 'owner', 'high owner'];
    }
  }

  String selectedRole = 'member';

  // ✅ DURASI OPTIONS
  final List<Map<String, dynamic>> durationOptions = [
    {'label': '1 Hari', 'value': '1'},
    {'label': '3 Hari', 'value': '3'},
    {'label': '7 Hari', 'value': '7'},
    {'label': '1 Bulan', 'value': '30'},
    {'label': 'Permanent', 'value': '9999999'},
  ];
  String selectedDuration = '7';

  int currentPage = 1;
  int itemsPerPage = 25;

  final deleteController = TextEditingController();
  final createUsernameController = TextEditingController();
  final createPasswordController = TextEditingController();
  String newUserRole = 'member';
  bool isLoading = false;

  // ─── VURTAX X RAT THEME (SESUAI DASHBOARD) ──────────────────────────────────────
  static const Color bgBase      = Color(0xFFDCEEFB);  // biru muda lembut
  static const Color bgSurface   = Color(0xFFFFFFFF);  // putih
  static const Color bgCard      = Color(0xFFF0F7FF);  // biru sangat pucat
  static const Color borderColor = Color(0xFF42A5F5);  // biru cerah
  static const Color primary     = Color(0xFF1565C0);  // biru tua accent
  static const Color primaryLit  = Color(0xFF1565C0);
  static const Color accent      = Color(0xFF42A5F5);
  static const Color accentGlow  = Color(0xFF42A5F5);
  static const Color textPrimary = Color(0xFF000000);  // hitam 87%
  static const Color textMuted   = Color(0x8A000000);  // hitam 54%
  static const Color textSub     = Color(0x61000000);  // hitam 38%

  // ─── Animasi ──────────────────────────────────────────────────────────────
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerFade;
  late Animation<double> _headerSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<double>(begin: -24, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerController.forward();
    _fetchUsers();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    deleteController.dispose();
    createUsernameController.dispose();
    createPasswordController.dispose();
    super.dispose();
  }

  // ─── API ──────────────────────────────────────────────────────────────────
  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/listUsers?key=$sessionKey'),
      );
      final data = jsonDecode(res.body);
      if (data['valid'] == true && data['authorized'] == true) {
        fullUserList = data['users'] ?? [];
        _filterAndPaginate();
      } else {
        _alert('Error', data['message'] ?? 'Tidak diizinkan.', isError: true);
      }
    } catch (_) {
      _alert('Koneksi Gagal', 'Tidak dapat menghubungi server.', isError: true);
    }
    setState(() => isLoading = false);
  }

  void _filterAndPaginate() {
    setState(() {
      currentPage = 1;
      filteredList =
          fullUserList.where((u) => u['role'] == selectedRole).toList();
    });
  }

  List<dynamic> _getCurrentPageData() {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredList.sublist(
        start, end > filteredList.length ? filteredList.length : end);
  }

  int get totalPages => (filteredList.length / itemsPerPage).ceil();

  Future<void> _deleteUser() async {
    final username = deleteController.text.trim();
    if (username.isEmpty) {
      _alert('Perhatian', 'Masukkan username yang ingin dihapus.',
          isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          '$baseUrl/deleteUser?key=$sessionKey&username=$username'));
      final data = jsonDecode(res.body);
      if (data['deleted'] == true) {
        _alert('Berhasil', "User '${data['user']['username']}' telah dihapus.");
        deleteController.clear();
        _fetchUsers();
      } else {
        _alert('Gagal', data['message'] ?? 'Gagal menghapus user.',
            isError: true);
      }
    } catch (_) {
      _alert('Error', 'Tidak dapat menghubungi server.', isError: true);
    }
    setState(() => isLoading = false);
  }

  Future<void> _createAccount() async {
    final username = createUsernameController.text.trim();
    final password = createPasswordController.text.trim();
    
    final day = selectedDuration;

    if (username.isEmpty || password.isEmpty) {
      _alert('Perhatian', 'Username dan Password wajib diisi.', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          '$baseUrl/userAdd?key=$sessionKey&username=$username&password=$password&day=$day&role=$newUserRole'));
      final data = jsonDecode(res.body);
      if (data['created'] == true) {
        _alert('Sukses', "Akun '${data['user']['username']}' berhasil dibuat.");
        createUsernameController.clear();
        createPasswordController.clear();
        setState(() {
          newUserRole = 'member';
          selectedDuration = '7';
        });
        _fetchUsers();
      } else {
        _alert('Gagal', data['message'] ?? 'Gagal membuat akun.',
            isError: true);
      }
    } catch (_) {
      _alert('Error', 'Gagal menghubungi server.', isError: true);
    }
    setState(() => isLoading = false);
  }

  // ─── Dialog Modern ────────────────────────────────────────────────────────
  void _alert(String title, String message, {bool isError = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isError
                  ? Colors.redAccent.withOpacity(0.4)
                  : primaryLit.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.redAccent : primaryLit)
                    .withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isError ? Colors.redAccent : primaryLit)
                      .withOpacity(0.12),
                ),
                child: Icon(
                  isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: isError ? Colors.redAccent : primaryLit,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    fontFamily: 'Astral',
                  )),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: textMuted, fontSize: 14, height: 1.5, fontFamily: 'Astral')),
              const SizedBox(height: 24),
              _buildButton(
                label: 'OK',
                onTap: () => Navigator.pop(ctx),
                isDestructive: false,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String username) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.redAccent.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.12),
                blurRadius: 40,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.12),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 26),
              ),
              const SizedBox(height: 16),
              const Text('Hapus User',
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Astral')),
              const SizedBox(height: 10),
              Text("Yakin ingin menghapus '$username'?\nTindakan ini tidak bisa dibatalkan.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: textMuted, fontSize: 14, height: 1.5, fontFamily: 'Astral')),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      label: 'Batal',
                      onTap: () => Navigator.pop(ctx, false),
                      isDestructive: false,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(
                      label: 'Hapus',
                      onTap: () => Navigator.pop(ctx, true),
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Komponen UI ──────────────────────────────────────────────────────────

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isOutline = false,
    bool fullWidth = false,
    IconData? icon,
    bool loading = false,
  }) {
    final Color baseColor = isDestructive ? Colors.redAccent : primaryLit;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 46,
      child: _PressableButton(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: isOutline
                ? null
                : LinearGradient(
                    colors: [
                      baseColor.withOpacity(0.85),
                      baseColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isOutline ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(12),
            border: isOutline
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow: isOutline
                ? null
                : [
                    BoxShadow(
                      color: baseColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: isOutline ? textMuted : Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isOutline ? textMuted : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        fontFamily: 'Astral',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        style: const TextStyle(
            color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Astral'),
        cursorColor: primaryLit,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: textMuted, fontSize: 13, fontFamily: 'Astral'),
          floatingLabelStyle:
              const TextStyle(color: primaryLit, fontSize: 12, fontFamily: 'Astral'),
          prefixIcon:
              Icon(icon, color: textSub, size: 18),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryLit, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ✅ DROPDOWN DURASI
  Widget _buildDurationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 2),
              child: Text(
                'Durasi',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                  fontFamily: 'Astral',
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDuration,
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.expand_more, color: textSub, size: 20),
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Astral',
                ),
                items: durationOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt['value'],
                    child: Row(
                      children: [
                        if (opt['value'] == '9999999')
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '∞',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.calendar_today_rounded,
                            color: primaryLit,
                            size: 16,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          opt['label'],
                          style: TextStyle(
                            color: opt['value'] == '9999999' 
                                ? Colors.amber 
                                : textPrimary,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDuration = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DROPDOWN ROLE dengan icon & warna
  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              'Role',
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
                fontFamily: 'Astral',
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: newUserRole,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.expand_more, color: textSub, size: 20),
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Astral',
              ),
              items: roleOptions.map((opt) {
                final color = _roleColor(opt);
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _roleIcon(opt),
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _roleDisplayName(opt),
                        style: const TextStyle(letterSpacing: 0.5, fontFamily: 'Astral'),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    newUserRole = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Text(label,
                  style: const TextStyle(color: textMuted, fontSize: 11, fontFamily: 'Astral')),
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon:
                  const Icon(Icons.expand_more, color: textSub, size: 20),
              style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Astral'),
              items: options.map((opt) {
                final color = _roleColor(opt);
                return DropdownMenuItem(
                  value: opt,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _roleIcon(opt),
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _roleDisplayName(opt),
                        style: const TextStyle(letterSpacing: 0.5, fontFamily: 'Astral'),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final color = accentColor ?? primaryLit;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: borderColor.withOpacity(0.6))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          fontFamily: 'Astral',
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                            color: textMuted, fontSize: 11, fontFamily: 'Astral')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map user, int index) {
    final role = user['role'] ?? 'member';
    final color = _roleColor(role);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 50).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  _roleIcon(role),
                  color: color,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['username'],
                      style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'Astral')),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _buildBadge(_roleDisplayName(role), color),
                      const SizedBox(width: 8),
                      Text("Exp: ${user['expiredDate']}",
                          style: const TextStyle(
                              color: textMuted, fontSize: 11, fontFamily: 'Astral')),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("Parent: ${user['parent'] ?? 'SYSTEM'}",
                      style: const TextStyle(
                          color: textSub, fontSize: 11, fontFamily: 'Astral')),
                ],
              ),
            ),
            _IconBtn(
              icon: Icons.delete_outline_rounded,
              color: Colors.redAccent,
              onTap: () async {
                final confirm =
                    await _confirmDelete(user['username']);
                if (confirm == true) {
                  deleteController.text = user['username'];
                  _deleteUser();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Astral')),
    );
  }

  Widget _buildPagination() {
    if (totalPages <= 1) return const SizedBox();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PillBtn(
            icon: Icons.chevron_left,
            enabled: currentPage > 1,
            onTap: () => setState(() => currentPage--),
          ),
          const SizedBox(width: 6),
          ...List.generate(totalPages, (i) {
            final page = i + 1;
            final active = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _PillBtn(
                label: '$page',
                active: active,
                onTap: () => setState(() => currentPage = page),
              ),
            );
          }),
          const SizedBox(width: 6),
          _PillBtn(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages,
            onTap: () => setState(() => currentPage++),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final userRole = widget.userRole?.toLowerCase() ?? 'kingz';
    final title = userRole == 'founder' ? 'Founder Dashboard' : 'Kingz Dashboard';
    final subtitle = userRole == 'founder' 
        ? 'Bisa create sampai Kingz' 
        : 'Bisa create sampai High Owner';

    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          Positioned.fill(child: _GridBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _headerController,
                    builder: (_, __) => Opacity(
                      opacity: _headerFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _headerSlide.value),
                        child: _buildHeader(title: title, subtitle: subtitle),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Hapus User',
                        subtitle: 'Nonaktifkan akun dari sistem',
                        icon: FontAwesomeIcons.userSlash,
                        accentColor: Colors.redAccent,
                        children: [
                          _buildInput(
                            label: 'Username Target',
                            controller: deleteController,
                            icon: FontAwesomeIcons.user,
                          ),
                          const SizedBox(height: 4),
                          _buildButton(
                            label: 'Hapus Akun',
                            onTap: _deleteUser,
                            icon: Icons.delete_outline_rounded,
                            isDestructive: true,
                            fullWidth: true,
                            loading: isLoading,
                          ),
                        ],
                      ),
                      _buildSection(
                        title: 'Buat Akun Baru',
                        subtitle: subtitle,
                        icon: FontAwesomeIcons.userPlus,
                        accentColor: primary,
                        children: [
                          _buildInput(
                            label: 'Username',
                            controller: createUsernameController,
                            icon: FontAwesomeIcons.user,
                          ),
                          _buildInput(
                            label: 'Password',
                            controller: createPasswordController,
                            icon: FontAwesomeIcons.lock,
                            obscure: true,
                          ),
                          _buildDurationDropdown(),
                          // ✅ ROLE DROPDOWN (dinamis berdasarkan role user)
                          _buildRoleDropdown(),
                          const SizedBox(height: 16),
                          _buildButton(
                            label: 'Buat Akun',
                            onTap: _createAccount,
                            icon: Icons.add_rounded,
                            fullWidth: true,
                            loading: isLoading,
                          ),
                        ],
                      ),
                      _buildSection(
                        title: 'User Management',
                        subtitle:
                            '${filteredList.length} pengguna ditemukan',
                        icon: FontAwesomeIcons.users,
                        accentColor: accent,
                        children: [
                          _buildDropdown(
                            value: selectedRole,
                            options: roleOptions,
                            label: 'Filter Role',
                            onChanged: (v) {
                              if (v != null) {
                                selectedRole = v;
                                _filterAndPaginate();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: _LoadingDots(),
                              ),
                            )
                          else if (filteredList.isEmpty)
                            _buildEmptyState()
                          else
                            Column(
                              children: [
                                ..._getCurrentPageData()
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        _buildUserItem(e.value, e.key))
                                    .toList(),
                                const SizedBox(height: 16),
                                _buildPagination(),
                              ],
                            ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: primaryLit.withOpacity(0.4 * _pulse.value)),
                boxShadow: [
                  BoxShadow(
                    color: primaryLit.withOpacity(0.2 * _pulse.value),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                widget.userRole?.toLowerCase() == 'founder' 
                    ? Icons.workspace_premium_rounded 
                    : Icons.emoji_events,
                color: primaryLit, 
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    fontFamily: 'Astral',
                  )),
              Text(subtitle,
                  style: TextStyle(color: textMuted, fontSize: 11, fontFamily: 'Astral')),
            ],
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.refresh_rounded,
            color: textSub,
            onTap: _fetchUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalAll = fullUserList.length;
    final totalPremium =
        fullUserList.where((u) => ['reseller','vip','owner','tk','admin','high owner','kingz','founder'].contains(u['role'])).length;
    final totalMember =
        fullUserList.where((u) => u['role'] == 'member').length;

    return Row(
      children: [
        _buildStatCard('Total User', '$totalAll',
            Icons.people_outline_rounded, primaryLit),
        const SizedBox(width: 10),
        _buildStatCard('Premium', '$totalPremium',
            Icons.storefront_outlined, accent),
        const SizedBox(width: 10),
        _buildStatCard('Member', '$totalMember',
            Icons.person_outline_rounded, textMuted),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Astral')),
            Text(label,
                style: const TextStyle(
                    color: textMuted, fontSize: 10, fontFamily: 'Astral')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: textSub, size: 40),
          const SizedBox(height: 12),
          const Text('Tidak ada data',
              style: TextStyle(color: textMuted, fontSize: 14, fontFamily: 'Astral')),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.15)
              : _KingzPageState.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _KingzPageState.borderColor),
        ),
        child: Icon(widget.icon, color: widget.color, size: 18),
      ),
    );
  }
}

class _PillBtn extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _PillBtn({
    this.label,
    this.icon,
    this.active = false,
    this.enabled = true,
    required this.onTap,
  });

  @override
  State<_PillBtn> createState() => _PillBtnState();
}

class _PillBtnState extends State<_PillBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (widget.enabled) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: widget.active
              ? _KingzPageState.primaryLit
              : (_pressed ? _KingzPageState.borderColor : _KingzPageState.bgSurface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.active
                ? _KingzPageState.primaryLit
                : _KingzPageState.borderColor,
          ),
          boxShadow: widget.active
              ? [
                  BoxShadow(
                    color: _KingzPageState.primaryLit.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Center(
          child: widget.icon != null
              ? Icon(widget.icon,
                  size: 16,
                  color: widget.enabled
                      ? _KingzPageState.textMuted
                      : _KingzPageState.borderColor)
              : Text(
                  widget.label ?? '',
                  style: TextStyle(
                    color: widget.active
                        ? Colors.white
                        : _KingzPageState.textMuted,
                    fontSize: 13,
                    fontWeight: widget.active
                        ? FontWeight.w700
                        : FontWeight.w400,
                    fontFamily: 'Astral',
                  ),
                ),
        ),
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressableButton({required this.child, this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: widget.onTap == null ? 0.45 : (_down ? 0.85 : 1.0),
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
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
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _KingzPageState.primaryLit
                        .withOpacity(0.4 + scale * 0.6),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.2)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final gradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        Colors.transparent,
        const Color(0xFFDCEEFB).withOpacity(0.85),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader =
            gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}