import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

class OwnerPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String? userRole;

  const OwnerPage({
    super.key,
    required this.sessionKey,
    required this.username,
    this.userRole,
  });

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  late String sessionKey;
  List<dynamic> fullUserList = [];
  List<dynamic> filteredList = [];

  // ✅ ROLE OPTIONS berdasarkan role user
  List<String> get roleOptions {
    final role = widget.userRole?.toLowerCase() ?? 'owner';
    if (role == 'owner') {
      return ['member', 'reseller', 'vip', 'admin', 'tk'];
    } else {
      return ['member', 'reseller', 'vip', 'admin'];
    }
  }

  String selectedRole = 'member';

  int currentPage = 1;
  int itemsPerPage = 25;

  final createUsernameController = TextEditingController();
  final createPasswordController = TextEditingController();
  final deleteController = TextEditingController();
  final editUsernameController = TextEditingController();

  // ✅ DURASI OPTIONS
  final List<Map<String, dynamic>> durationOptions = [
    {'label': '1 Hari', 'value': '1'},
    {'label': '3 Hari', 'value': '3'},
    {'label': '7 Hari', 'value': '7'},
    {'label': '1 Bulan', 'value': '30'},
    {'label': 'Permanent', 'value': '9999999'},
  ];
  String selectedDuration = '7';
  String selectedEditDuration = '7';

  String newUserRole = 'member';
  bool isLoading = false;

  // ─── VURTAX X RAT THEME (SESUAI DASHBOARD) ──────────────────────────────────────
  final Color bgDark = const Color(0xFFDCEEFB);  // biru muda lembut
  final Color primaryBlue = const Color(0xFF1565C0);  // biru tua accent
  final Color accentBlue = const Color(0xFF42A5F5);  // biru cerah
  final Color primaryWhite = const Color(0xFF000000);  // hitam 87%
  final Color textGrey = const Color(0x8A000000);  // hitam 54%
  final Color cardGlass = const Color(0xFFFFFFFF);  // putih
  final Color borderGlass = const Color(0xFF42A5F5);  // biru cerah

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    _fetchUsers();
  }

  @override
  void dispose() {
    createUsernameController.dispose();
    createPasswordController.dispose();
    deleteController.dispose();
    editUsernameController.dispose();
    super.dispose();
  }

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
        _alert("Info", data['message'] ?? 'Gagal memuat user.');
      }
    } catch (_) {
      _alert("Error", "Gagal terhubung ke server.");
    }
    setState(() => isLoading = false);
  }

  void _filterAndPaginate() {
    setState(() {
      currentPage = 1;
      filteredList = fullUserList
          .where((u) => u['role'] == selectedRole)
          .toList();
    });
  }

  List<dynamic> _getCurrentPageData() {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage);
    return filteredList.sublist(
      start,
      end > filteredList.length ? filteredList.length : end,
    );
  }

  int get totalPages => (filteredList.length / itemsPerPage).ceil();

  Future<void> _deleteUser() async {
    final username = deleteController.text.trim();
    if (username.isEmpty) {
      _alert("Peringatan", "Masukkan username yang ingin dihapus.");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/deleteUser?key=$sessionKey&username=$username'),
      );
      final data = jsonDecode(res.body);

      if (data['deleted'] == true) {
        _alert("Sukses", "User berhasil dihapus.");
        deleteController.clear();
        _fetchUsers();
      } else {
        _alert("Gagal", data['message'] ?? 'Gagal menghapus user.');
      }
    } catch (_) {
      _alert("Error", "Gagal menghubungi server.");
    }
    setState(() => isLoading = false);
  }

  Future<void> _createAccount() async {
    final u = createUsernameController.text.trim();
    final p = createPasswordController.text.trim();
    final d = selectedDuration;

    if (u.isEmpty || p.isEmpty) {
      _alert("Peringatan", "Username dan Password wajib diisi.");
      return;
    }

    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        '$baseUrl/userAdd?key=$sessionKey&username=$u&password=$p&day=$d&role=$newUserRole',
      );
      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (data['created'] == true) {
        _alert("Sukses", "Akun berhasil dibuat sebagai ${_roleDisplayName(newUserRole)}.");
        createUsernameController.clear();
        createPasswordController.clear();
        setState(() {
          newUserRole = 'member';
          selectedDuration = '7';
        });
        _fetchUsers();
      } else {
        _alert("Gagal", data['message'] ?? 'Gagal membuat akun.');
      }
    } catch (_) {
      _alert("Error", "Gagal menghubungi server.");
    }
    setState(() => isLoading = false);
  }

  Future<void> _editUser() async {
    final u = editUsernameController.text.trim();
    final d = selectedEditDuration;

    if (u.isEmpty) {
      _alert("Peringatan", "Username wajib diisi.");
      return;
    }

    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        '$baseUrl/editUser?key=$sessionKey&username=$u&addDays=$d',
      );
      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (data['edited'] == true) {
        _alert("Sukses", "Durasi berhasil diperbarui.");
        editUsernameController.clear();
        setState(() {
          selectedEditDuration = '7';
        });
        _fetchUsers();
      } else {
        _alert("Gagal", data['message'] ?? 'Gagal mengubah durasi.');
      }
    } catch (_) {
      _alert("Error", "Gagal menghubungi server.");
    }
    setState(() => isLoading = false);
  }

  void _alert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentBlue.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: accentBlue),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: primaryWhite, fontFamily: 'Astral')),
          ],
        ),
        content: Text(message, style: TextStyle(color: textGrey, fontFamily: 'Astral')),
        actions: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Astral'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: primaryWhite, fontFamily: 'Astral'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accentBlue, fontFamily: 'Astral'),
          prefixIcon: Icon(icon, color: accentBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderGlass),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderGlass),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentBlue, width: 2),
          ),
        ),
      ),
    );
  }

  // ✅ DROPDOWN DURASI
  Widget _buildDurationDropdown({
    required String value,
    required ValueChanged<String> onChanged,
    String? label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderGlass),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 2),
                child: Text(
                  label,
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 13,
                    fontFamily: 'Astral',
                  ),
                ),
              ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.expand_more, color: Color(0x8A000000), size: 20),
                style: const TextStyle(
                  color: Color(0xFF000000),
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
                            color: accentBlue,
                            size: 16,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          opt['label'],
                          style: TextStyle(
                            color: opt['value'] == '9999999' 
                                ? Colors.amber 
                                : Color(0xFF000000),
                            fontFamily: 'Astral',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGlass),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: newUserRole,
          dropdownColor: Colors.white,
          style: TextStyle(color: primaryWhite, fontFamily: 'Astral'),
          items: roleOptions.map((role) {
            final color = _roleColor(role);
            return DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Icon(_roleIcon(role), color: color, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _roleDisplayName(role),
                    style: TextStyle(color: color, fontFamily: 'Astral'),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => newUserRole = val ?? 'member'),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGlass),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentBlue),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: primaryWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Astral',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUserItem(Map user) {
    final role = user['role'] ?? 'member';
    final color = _roleColor(role);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_roleIcon(role), color: color),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: TextStyle(
                    color: primaryWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Astral',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "ROLE: ${_roleDisplayName(role)} | EXP: ${user['expiredDate']}",
                  style: TextStyle(color: textGrey, fontSize: 13, fontFamily: 'Astral'),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: accentBlue.withOpacity(0.3)),
                    ),
                    title: Text("Konfirmasi", style: TextStyle(color: primaryWhite, fontFamily: 'Astral')),
                    content: Text("Hapus user ini?", style: TextStyle(color: textGrey, fontFamily: 'Astral')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Batal", style: TextStyle(color: primaryBlue, fontFamily: 'Astral')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Hapus", style: TextStyle(color: Colors.redAccent, fontFamily: 'Astral')),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  deleteController.text = user['username'];
                  _deleteUser();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(totalPages, (index) {
        final page = index + 1;
        return ElevatedButton(
          onPressed: () => setState(() => currentPage = page),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentPage == page ? accentBlue : Colors.transparent,
            foregroundColor: currentPage == page ? Colors.white : Color(0x8A000000),
            padding: EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: borderGlass),
            ),
          ),
          child: Text("$page", style: TextStyle(fontSize: 12, fontFamily: 'Astral')),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = widget.userRole?.toLowerCase() ?? 'owner';
    final title = userRole == 'owner' ? 'OWNER DASHBOARD' : 'TK DASHBOARD';
    final subtitle = userRole == 'owner' 
        ? 'Bisa create sampai TK' 
        : 'Bisa create sampai Admin';

    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgDark, primaryBlue.withOpacity(0.08), bgDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  userRole == 'owner' 
                      ? Icons.workspace_premium 
                      : Icons.security_rounded,
                  color: accentBlue,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: primaryWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Astral',
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
                    fontFamily: 'Astral',
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 40),

                _buildGlassCard(
                  title: "DELETE USER",
                  icon: FontAwesomeIcons.userSlash,
                  children: [
                    _buildInput(
                      label: "Username Target",
                      controller: deleteController,
                      icon: FontAwesomeIcons.user,
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.redAccent, Colors.red]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _deleteUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "DELETE ACCOUNT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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

                _buildGlassCard(
                  title: "CREATE ACCOUNT",
                  icon: FontAwesomeIcons.userPlus,
                  children: [
                    _buildInput(
                      label: "Username",
                      controller: createUsernameController,
                      icon: FontAwesomeIcons.user,
                    ),
                    _buildInput(
                      label: "Password",
                      controller: createPasswordController,
                      icon: FontAwesomeIcons.lock,
                    ),
                    _buildDurationDropdown(
                      value: selectedDuration,
                      label: "Durasi",
                      onChanged: (value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    // ✅ ROLE DROPDOWN (dinamis berdasarkan role)
                    _buildRoleDropdown(),
                    SizedBox(height: 20),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                _buildGlassCard(
                  title: "EXTEND DURATION",
                  icon: FontAwesomeIcons.clock,
                  children: [
                    _buildInput(
                      label: "Username Target",
                      controller: editUsernameController,
                      icon: FontAwesomeIcons.userEdit,
                    ),
                    _buildDurationDropdown(
                      value: selectedEditDuration,
                      label: "Tambah Durasi",
                      onChanged: (value) {
                        setState(() {
                          selectedEditDuration = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _editUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          "ADD DAYS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                _buildGlassCard(
                  title: "USER LIST",
                  icon: FontAwesomeIcons.users,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGlass),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          dropdownColor: Colors.white,
                          style: TextStyle(color: primaryWhite, fontFamily: 'Astral'),
                          items: roleOptions.map((role) {
                            final color = _roleColor(role);
                            return DropdownMenuItem(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(_roleIcon(role), color: color, size: 14),
                                  const SizedBox(width: 8),
                                  Text(
                                    _roleDisplayName(role),
                                    style: TextStyle(color: color, fontFamily: 'Astral'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              selectedRole = val;
                              _filterAndPaginate();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: accentBlue,
                      ),
                    )
                        : Column(
                      children: [
                        ..._getCurrentPageData()
                            .map((u) => _buildUserItem(u))
                            .toList(),
                        SizedBox(height: 20),
                        _buildPagination(),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}