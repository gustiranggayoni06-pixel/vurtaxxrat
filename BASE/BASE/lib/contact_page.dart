import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // ─── VURTAX X RAT THEME (SESUAI DASHBOARD) ──────────────────────────────────────
  static const Color bgDark       = Color(0xFFDCEEFB);  // biru muda lembut
  static const Color primaryBlue  = Color(0xFF1565C0);  // biru tua accent
  static const Color accentBlue   = Color(0xFF42A5F5);  // biru cerah
  static const Color textPrimary  = Color(0xFF000000);  // hitam 87%
  static const Color textSecondary = Color(0x8A000000); // hitam 54%
  static const Color surface      = Color(0xFFFFFFFF);  // putih
  static const Color cardBg       = Color(0xFFF0F7FF);  // biru sangat pucat

  // Glassmorphism dengan warna biru
  static const Color cardGlass = Color.fromARGB(180, 255, 255, 255);
  static const Color borderGlass = Color(0xFF42A5F5);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Customer Service",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Astral',
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgDark,
              primaryBlue.withOpacity(0.08),
              bgDark,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Icon
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 60,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Need Help?",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Astral',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Contact us through our social media platforms below.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontFamily: 'Astral',
                  ),
                ),
                const SizedBox(height: 40),

                // Grid Buttons
                Column(
                  children: [
                    _buildContactButton(
                      label: "Telegram",
                      icon: FontAwesomeIcons.telegram,
                      color: Colors.blue,
                      url: "https://t.me/ranzz_offczaxx_stur",
                    ),
                    const SizedBox(height: 16),
                    _buildContactButton(
                      label: "WhatsApp",
                      icon: FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      url: "https://wa.me/gapunya whatsapp 🗿",
                    ),
                    const SizedBox(height: 16),
                    _buildContactButton(
                      label: "TikTok",
                      icon: FontAwesomeIcons.tiktok,
                      color: Colors.black,
                      url: "https://www.tiktok.com/manuver.xx",
                    ),
                    const SizedBox(height: 16),
                    _buildContactButton(
                      label: "Instagram",
                      icon: FontAwesomeIcons.instagram,
                      color: const Color(0xFFE1306C),
                      url: "https://",
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required String label,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGlass.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Astral',
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}