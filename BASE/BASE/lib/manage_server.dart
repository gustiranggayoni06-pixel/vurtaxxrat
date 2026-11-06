import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class ManageServerPage extends StatefulWidget {
  final String keyToken;
  const ManageServerPage({super.key, required this.keyToken});

  @override
  State<ManageServerPage> createState() => _ManageServerPageState();
}

class _ManageServerPageState extends State<ManageServerPage> {
  List<Map<String, dynamic>> vpsList = [];
  bool isLoading = false;

  final _hostController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────────
  final Color primaryDark = const Color(0xFFDCEEFB);  // biru muda lembut
  final Color primaryWhite = const Color(0xFF000000);  // hitam 87%
  final Color accentCyan = const Color(0xFF1565C0);  // biru tua accent
  final Color accentLight = const Color(0xFF42A5F5);  // biru cerah
  final Color cardDark = const Color(0xFFFFFFFF);  // putih
  final Color textGrey = const Color(0x8A000000);  // hitam 54%

  @override
  void initState() {
    super.initState();
    _fetchVpsList();
  }

  Future<void> _fetchVpsList() async {
    setState(() => isLoading = true);
    final uri = Uri.parse('$baseUrl/myServer?key=${widget.keyToken}');
    try {
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      setState(() {
        vpsList = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {
      _showError("Gagal mengambil data VPS.");
    }
    setState(() => isLoading = false);
  }

  Future<void> _addVps() async {
    final host = _hostController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (host.isEmpty || user.isEmpty || pass.isEmpty) {
      _showError("Isi semua field terlebih dahulu.");
      return;
    }

    final uri = Uri.parse('$baseUrl/addServer');
    try {
      final res = await http.post(uri, body: {
        'key': widget.keyToken,
        'host': host,
        'username': user,
        'password': pass,
      });
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _hostController.clear();
        _userController.clear();
        _passController.clear();
        _fetchVpsList();
      } else {
        _showError(data['error'] ?? 'Gagal menambah VPS');
      }
    } catch (_) {
      _showError("Gagal terhubung ke server.");
    }
  }

  Future<void> _deleteVps(String host) async {
    final uri = Uri.parse('$baseUrl/delServer');
    try {
      final res = await http.post(uri, body: {
        'key': widget.keyToken,
        'host': host,
      });
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _fetchVpsList();
      } else {
        _showError("Gagal menghapus VPS.");
      }
    } catch (_) {
      _showError("Gagal menghubungi server.");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentCyan.withOpacity(0.3)),
        ),
        title: Text("Error", style: TextStyle(color: primaryWhite, fontFamily: 'Astral', fontWeight: FontWeight.bold)),
        content: Text(msg, style: TextStyle(color: textGrey, fontFamily: 'Astral')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: accentCyan, fontFamily: 'Astral')),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentCyan.withOpacity(0.3)),
        ),
        title: Text("Tambah VPS", style: TextStyle(color: primaryWhite, fontFamily: 'Astral', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput("IP VPS", _hostController),
            _buildInput("Username", _userController),
            _buildInput("Password", _passController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("BATAL", style: TextStyle(color: textGrey, fontFamily: 'Astral')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addVps();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentCyan,
              foregroundColor: Colors.white,
            ),
            child: Text("TAMBAH", style: TextStyle(color: Colors.white, fontFamily: 'Astral')),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: TextStyle(color: primaryWhite, fontFamily: 'Astral'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accentCyan, fontFamily: 'Astral'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentCyan.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentCyan),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: primaryDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryDark,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("My VPS List",
                      style: TextStyle(
                          fontSize: 18,
                          color: primaryWhite,
                          fontFamily: 'Astral',
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add, color: accentCyan),
                    onPressed: _showAddDialog,
                  )
                ],
              ),
              Divider(color: accentCyan),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
                    : ListView.builder(
                  itemCount: vpsList.length,
                  itemBuilder: (context, index) {
                    final vps = vpsList[index];
                    return Card(
                      color: cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: accentCyan.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        title: Text("${vps['host']}", style: TextStyle(color: primaryWhite, fontFamily: 'Astral')),
                        subtitle: Text("User: ${vps['username']}", style: TextStyle(color: textGrey, fontFamily: 'Astral')),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: accentCyan),
                          onPressed: () => _deleteVps(vps['host']),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}