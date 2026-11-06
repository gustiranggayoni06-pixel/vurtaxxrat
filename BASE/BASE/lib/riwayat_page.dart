import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

// ─── VURTAX X RAT THEME COLORS (SAMA PERSIS DENGAN DASHBOARD PAGE) ────────────────
class RiwayatTheme {
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
  static const primaryCyan = red;
  static const accentCyan = border;
  static const lightCyan = border;
  static const primaryWhite = white;
  static const accentGrey = textMuted;
  static const cardGlass = surface2;
  static const borderGlass = border;
  static const bgDark = bg;
}

class RiwayatPage extends StatefulWidget {
  final String sessionKey;
  final String role;

  const RiwayatPage({
    super.key,
    required this.sessionKey,
    required this.role,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // ─── WARNA VURTAX X RAT THEME ──────────────────────────────────────────────
  final Color bgDark = RiwayatTheme.bg;
  final Color primaryCyan = RiwayatTheme.red;
  final Color accentCyan = RiwayatTheme.border;
  final Color lightCyan = RiwayatTheme.border;
  final Color primaryWhite = RiwayatTheme.textPrimary;
  final Color accentGrey = RiwayatTheme.textMuted;
  final Color cardGlass = RiwayatTheme.surface2;
  final Color borderGlass = RiwayatTheme.border;

  List<ActivityModel> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getMyActivity?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid']) {
          List<dynamic> rawList = data['activities'];

          setState(() {
            activities = rawList.map((item) {
              return ActivityModel(
                type: item['type'] ?? 'system',
                title: item['title'] ?? 'Aktivitas',
                description: item['description'] ?? '-',
                timestamp: DateTime.fromMillisecondsSinceEpoch(
                    item['timestamp'] ?? DateTime.now().millisecondsSinceEpoch
                ),
              );
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        print("Server Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching history: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text(
          "Riwayat Aktivitas",
          style: TextStyle(
            color: RiwayatTheme.textPrimary,
            fontFamily: 'Astral',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: RiwayatTheme.red.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        backgroundColor: RiwayatTheme.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: RiwayatTheme.red),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, RiwayatTheme.red, Colors.transparent],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              RiwayatTheme.bg,
              RiwayatTheme.red.withOpacity(0.05),
              RiwayatTheme.bg,
            ],
          ),
        ),
        child: isLoading
            ? Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RiwayatTheme.red, RiwayatTheme.border],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: RiwayatTheme.red.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : activities.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: RiwayatTheme.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: RiwayatTheme.border.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.history_toggle_off,
                        size: 56,
                        color: accentGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada aktivitas",
                      style: TextStyle(
                        color: RiwayatTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Astral',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Pastikan server aktif",
                      style: TextStyle(
                        color: RiwayatTheme.textMuted,
                        fontSize: 12,
                        fontFamily: 'Astral',
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadActivities,
                color: RiwayatTheme.border,
                backgroundColor: RiwayatTheme.card,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityCard(activity);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    Color iconColor;
    IconData iconData;
    String typeLabel;

    switch (activity.type) {
      case 'login':
        iconColor = RiwayatTheme.success;
        iconData = Icons.login_rounded;
        typeLabel = "LOGIN";
        break;
      case 'bug':
        iconColor = RiwayatTheme.orange;
        iconData = Icons.bug_report_outlined;
        typeLabel = "ATTACK";
        break;
      case 'create':
        iconColor = RiwayatTheme.border;
        iconData = Icons.person_add_alt_1_rounded;
        typeLabel = "ACCOUNT";
        break;
      default:
        iconColor = RiwayatTheme.textMuted;
        iconData = Icons.info_outline;
        typeLabel = "SYSTEM";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RiwayatTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RiwayatTheme.border.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: RiwayatTheme.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: RiwayatTheme.red.withOpacity(0.04),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: TextStyle(
                          color: RiwayatTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Astral',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: RiwayatTheme.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: RiwayatTheme.border.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: RiwayatTheme.border,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: RiwayatTheme.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Astral',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: RiwayatTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(activity.timestamp),
                      style: TextStyle(
                        color: RiwayatTheme.textMuted,
                        fontSize: 11,
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
    );
  }
}

class ActivityModel {
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;

  ActivityModel({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}