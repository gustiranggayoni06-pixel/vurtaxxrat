import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'change_password_page.dart';

// ─── VURTAX X RAT THEME ─────────────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFFDCEEFB);  // biru muda lembut
  static const surface   = Color(0xFFFFFFFF);  // putih
  static const card      = Color(0xFFF0F7FF);  // biru sangat pucat
  static const cardInner = Color(0xFFE3F2FD);
  static const border    = Color(0xFF42A5F5);  // biru cerah
  static const borderLit = Color(0xFF42A5F5);
  static const steel     = Color(0xFF1565C0);  // biru tua accent
  static const blueMid   = Color(0xFF1565C0);
  static const blueLight = Color(0xFF42A5F5);
  static const chrome    = Color(0xFF64B5F6);
  static const frost     = Color(0xFF90CAF9);
  static const red       = Color(0xFFEF4444);
  static const amber     = Color(0xFFFFC34D);
  static const green     = Color(0xFF22C55E);
  static const purple    = Color(0xFF1565C0);
  static const pink      = Color(0xFFE91E63);
  static const teal      = Color(0xFF14B8A6);
  static const blue      = Color(0xFF3B82F6);
  static const text      = Color(0xFF000000);  // hitam 87%
  static const textSub   = Color(0x8A000000);  // hitam 54%
  static const textDim   = Color(0x61000000);  // hitam 38%
  static const white     = Color(0xFFFFFFFF);
}

class ProfilePage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;

  const ProfilePage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.sessionKey,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${widget.username}');
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() {
            _profileImage = file;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile image: $e");
    }
  }

  String _censorText(String text, {bool isPassword = false}) {
    if (text.isEmpty) return "N/A";
    if (isPassword) return "••••••••";
    if (text.length <= 2) return "${text.substring(0, 1)}••";
    return "${text.substring(0, 2)}${'•' * (text.length - 2)}";
  }

  Future<void> _showImageSourceDialog() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: _C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: _C.blueMid),
              title: Text("Kamera", style: TextStyle(color: _C.text, fontFamily: 'Astral')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: _C.blueMid),
              title: Text("Galeri", style: TextStyle(color: _C.text, fontFamily: 'Astral')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: _C.red),
              title: Text("Hapus Foto", style: TextStyle(color: _C.red, fontFamily: 'Astral')),
              onTap: () {
                Navigator.pop(context);
                _deleteProfileImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${widget.username}', imageFile.path);
        setState(() {
          _profileImage = imageFile;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Profil berhasil diperbarui', style: TextStyle(fontFamily: 'Astral')),
              backgroundColor: _C.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e', style: const TextStyle(fontFamily: 'Astral')),
            backgroundColor: _C.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${widget.username}');
      setState(() {
        _profileImage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🗑️ Foto profil dihapus', style: TextStyle(fontFamily: 'Astral')),
            backgroundColor: _C.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting image: $e");
    }
  }

  String _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'developer': return '💻';
      case 'founder':   return '👑';
      case 'kingz':     return '👑';
      case 'high owner':return '🔥';
      case 'owner':     return '👑';
      case 'tk':        return '🛡️';
      case 'admin':     return '🛡️';
      case 'reseller':  return '🛒';
      case 'vip':       return '💎';
      case 'member':    return '👤';
      default:          return '👤';
    }
  }

  Color _getRoleColor(String role) {
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
      default:          return _C.blueMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(widget.role);
    final roleIcon = _getRoleIcon(widget.role);

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _C.blueMid, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: _C.text,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
            fontFamily: 'Astral',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _C.blueMid, size: 20),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bg, _C.surface, _C.bg],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar Section
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [roleColor, _C.blueMid, _C.blueLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: roleColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      roleIcon,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.username.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Astral',
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _C.blueLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: _C.surface, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _C.blueLight.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Username & Role
              Text(
                widget.username,
                style: const TextStyle(
                  color: _C.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'Astral',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, _C.blueMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getRoleIcon(widget.role)} ${widget.role.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontFamily: 'Astral',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Info Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildInfoCard(
                    icon: Icons.person_outline_rounded,
                    label: "USERNAME",
                    value: _censorText(widget.username),
                  ),
                  _buildInfoCard(
                    icon: Icons.lock_outline_rounded,
                    label: "PASSWORD",
                    value: _censorText(widget.password, isPassword: true),
                  ),
                  _buildInfoCard(
                    icon: Icons.verified_user_rounded,
                    label: "ROLE",
                    value: widget.role.toUpperCase(),
                    color: roleColor,
                  ),
                  _buildInfoCard(
                    icon: Icons.calendar_today_rounded,
                    label: "EXPIRED",
                    value: widget.expiredDate,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Session Key Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_C.card, _C.cardInner],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _C.blueMid.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.vpn_key_rounded, color: _C.blueMid, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "SESSION KEY",
                          style: TextStyle(
                            color: _C.textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            fontFamily: 'Astral',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('📋 Session key copied!', style: TextStyle(fontFamily: 'Astral')),
                                backgroundColor: _C.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: Icon(Icons.copy_rounded, color: _C.textSub, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      widget.sessionKey,
                      style: const TextStyle(
                        color: _C.blueMid,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    "CHANGE PASSWORD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Astral',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.blueMid,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordPage(
                          sessionKey: widget.sessionKey,
                          username: widget.username,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Footer
              Center(
                child: Text(
                  '© ${widget.role.toUpperCase()} • Profile v2.0',
                  style: TextStyle(
                    color: _C.textDim,
                    fontSize: 10,
                    letterSpacing: 1,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.card, _C.cardInner],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (color ?? _C.blueMid).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color ?? _C.blueMid, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: _C.textSub,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? _C.text,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Astral',
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}