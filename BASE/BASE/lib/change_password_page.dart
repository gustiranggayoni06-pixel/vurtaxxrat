import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class ChangePasswordPage extends StatefulWidget {
  final String username;
  final String sessionKey;
  final String role;

  const ChangePasswordPage({
    super.key,
    required this.username,
    required this.sessionKey,
    required this.role,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ─── VURTAX X RAT THEME (SESUAI DASHBOARD) ──────────────────────────────────────
  static const Color kBg      = Color(0xFFDCEEFB);  // biru muda lembut
  static const Color kCard    = Color(0xFFFFFFFF);  // putih
  static const Color kCardAlt = Color(0xFFF0F7FF);  // biru sangat pucat
  static const Color kBorder  = Color(0xFF42A5F5);  // biru cerah
  static const Color kBlue    = Color(0xFF1565C0);  // biru tua accent
  static const Color kBlueLit = Color(0xFF42A5F5);
  static const Color kText    = Color(0xFF000000);  // hitam 87%
  static const Color kTextSub = Color(0x8A000000);  // hitam 54%
  static const Color kTextDim = Color(0x61000000);  // hitam 38%
  static const Color kGreen   = Color(0xFF22C55E);
  static const Color kRed     = Color(0xFFEF4444);

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
      default:          return kBlue;
    }
  }

  Future<void> _changePassword() async {
    final oldPass = oldPassCtrl.text.trim();
    final newPass = newPassCtrl.text.trim();
    final confirmPass = confirmPassCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("⚠️ All fields are required", kRed);
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar("❌ New password doesn't match confirmation", kRed);
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar("❌ Password must be at least 6 characters", kRed);
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/changepass"),
        body: {
          "username": widget.username,
          "oldPass": oldPass,
          "newPass": newPass,
          "sessionKey": widget.sessionKey,
        },
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        _showSnackBar("✅ Password changed successfully!", kGreen);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showSnackBar("❌ ${data['message'] ?? 'Failed to change password'}", kRed);
      }
    } catch (e) {
      _showSnackBar("❌ Server error: $e", kRed);
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'Astral')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(widget.role);
    final roleIcon = _getRoleIcon(widget.role);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Row(
          children: [
            Text(roleIcon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text(
              "Change Password",
              style: TextStyle(
                color: kText,
                fontWeight: FontWeight.bold,
                fontFamily: 'Astral',
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: kCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [roleColor, kBlueLit],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "CHANGE PASSWORD",
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 18,
                      fontFamily: 'Astral',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Update your account security",
                    style: TextStyle(
                      color: kTextSub,
                      fontSize: 13,
                      fontFamily: 'Astral',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${_getRoleIcon(widget.role)} ${widget.role.toUpperCase()}',
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        fontFamily: 'Astral',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildField(
              hint: "Old Password",
              controller: oldPassCtrl,
              obscure: _obscureOld,
              onToggle: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 16),

            _buildField(
              hint: "New Password",
              controller: newPassCtrl,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),

            _buildField(
              hint: "Confirm Password",
              controller: confirmPassCtrl,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 30),

            Center(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.security_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "CHANGE PASSWORD",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.2,
                                fontFamily: 'Astral',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                '© ${widget.role.toUpperCase()} • Change Password',
                style: TextStyle(
                  color: kTextSub.withOpacity(0.3),
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontFamily: 'Astral',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: kText, fontFamily: 'Astral'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kTextSub, fontFamily: 'Astral'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: kTextSub,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }
}