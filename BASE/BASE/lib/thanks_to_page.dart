import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class ThanksToPage extends StatefulWidget {
  const ThanksToPage({super.key});

  @override
  State<ThanksToPage> createState() => _ThanksToPageState();
}

class _ThanksToPageState extends State<ThanksToPage> {
  List<Map<String, dynamic>> contributors = [];
  bool _isLoading = true;
  
  int _currentPage = 0;
  final PageController _pageController = PageController(
    viewportFraction: 0.88,
  );
  late Timer _autoSlideTimer;

  // ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────
  static const Color _primaryColor = Color(0xFF1565C0);  // biru tua accent
  static const Color _accentColor = Color(0xFF42A5F5);  // biru cerah
  static const Color _darkColor = Color(0xFFDCEEFB);  // biru muda lembut
  static const Color _cardBg = Color(0xFFFFFFFF);  // putih
  static const Color _textColor = Color(0xFF000000);  // hitam 87%
  static const Color _textMuted = Color(0x8A000000);  // hitam 54%

  @override
  void initState() {
    super.initState();
    _fetchContributors();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchContributors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/contributors'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> items = [];
        
        if (data is List) {
          items = data;
        } else if (data['contributors'] is List) {
          items = data['contributors'];
        } else if (data['data'] is List) {
          items = data['data'];
        }
        
        setState(() {
          contributors = List<Map<String, dynamic>>.from(items.map((item) {
            return {
              'nama': item['nama']?.toString() ?? 'Member',
              'telegram': item['telegram']?.toString() ?? '',
              'role': item['role']?.toString() ?? 'Contributor',
              'avatar': item['avatar']?.toString() ?? '',
              'telegram_url': 'https://t.me/ranzz_offc${item['telegram']?.toString().replaceAll('@', '')}',
            };
          }));
          _isLoading = false;
        });
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    setState(() {
      contributors = [
        {
          'nama': 'ᯓ ZAXX',
          'telegram': '@zaxx_str', 
          'role': 'LEAD DEVELOPER',
          'avatar': 'https://ziperr-img.lovable.app/i/wvurlkeo.jpg',
          'telegram_url': 'https://t.me/ranzz_offczaxx_stur',
        },
        {
          'nama': 'ᯓ VURTAX X RAT TEAM',
          'telegram': '@zaxx_stur', 
          'role': 'TELEGRAM CHANNEL',
          'avatar': 'https://ziperr-img.lovable.app/i/wvurlkeo.jpg',
          'telegram_url': 'https://t.me/ranzz_offczaxx_str05',
        },
      ];
      _isLoading = false;
    });
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients && contributors.length > 1) {
        int nextPage = _currentPage + 1;
        if (nextPage >= contributors.length) nextPage = 0;
        
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _openTelegram(String username) async {
    final cleanUsername = username.replaceAll('@', '');
    final Uri url = Uri.parse('https://t.me/ranzz_offc$cleanUsername');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Tidak bisa membuka Telegram';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkColor,
      body: Stack(
        children: [
          // Animated gradient background - VURTAX X RAT Blue
          AnimatedContainer(
            duration: const Duration(seconds: 10),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Color.lerp(_darkColor, _primaryColor, 0.05)!,
                  _darkColor,
                  _darkColor,
                ],
              ),
            ),
          ),
          
          // Floating particles effect
          _buildParticles(),
          
          SafeArea(
            child: Column(
              children: [
                // Minimal Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      // Back button with glow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textColor),
                          color: _textColor,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VURTAX X RAT TEAM',
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3,
                                fontFamily: 'Astral',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 1,
                              width: 60,
                              color: _primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Loading Team...',
                                style: TextStyle(
                                  color: Color(0x8A000000),
                                  fontSize: 14,
                                  fontFamily: 'Astral',
                                ),
                              ),
                            ],
                          ),
                        )
                      : contributors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.group_off_outlined,
                                    color: Color(0x61000000),
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No contributors yet',
                                    style: TextStyle(
                                      color: Color(0x8A000000),
                                      fontSize: 16,
                                      fontFamily: 'Astral',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : PageView.builder(
                              controller: _pageController,
                              itemCount: contributors.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final person = contributors[index];
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    double value = 1.0;
                                    if (_pageController.position.haveDimensions) {
                                      value = _pageController.page! - index;
                                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                                    }
                                    
                                    return Transform.scale(
                                      scale: value,
                                      child: Opacity(
                                        opacity: value.clamp(0.5, 1.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                                          child: _buildContributorCard(person),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),

                // Bottom Navigation
                if (!_isLoading && contributors.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(bottom: 30, top: 10),
                    child: Column(
                      children: [
                        // Page Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            contributors.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 20 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: _currentPage == index 
                                    ? BoxShape.rectangle 
                                    : BoxShape.circle,
                                borderRadius: _currentPage == index 
                                    ? BorderRadius.circular(4) 
                                    : null,
                                color: _currentPage == index
                                    ? _primaryColor
                                    : Color(0x61000000),
                                boxShadow: _currentPage == index
                                    ? [
                                        BoxShadow(
                                          color: _primaryColor.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Navigation Arrows
                        if (contributors.length > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNavButton(
                                icon: Icons.chevron_left_rounded,
                                enabled: _currentPage > 0,
                                onTap: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                              ),
                              
                              const SizedBox(width: 60),
                              
                              _buildNavButton(
                                icon: Icons.chevron_right_rounded,
                                enabled: _currentPage < contributors.length - 1,
                                onTap: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticles() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.06,
        child: Container(
          child: Stack(
            children: List.generate(
              20,
              (index) => Positioned(
                left: (index * 37) % MediaQuery.of(context).size.width,
                top: (index * 53) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? _primaryColor.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: enabled
                ? _primaryColor.withOpacity(0.5)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: enabled ? _primaryColor : Color(0x61000000),
          size: 30,
        ),
      ),
    );
  }

  Widget _buildContributorCard(Map<String, dynamic> person) {
    final role = person['role']?.toString().toLowerCase() ?? 'member';
    final roleColor = _roleColor(role);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardBg,
            Color(0xFFF5F9FF),
            _darkColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: _primaryColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar with shimmer effect
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Avatar image with border
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: roleColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: roleColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: person['avatar'].toString().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: person['avatar'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  roleColor.withOpacity(0.8),
                                  roleColor.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Icon(
                              _roleIcon(role),
                              color: Colors.white70,
                              size: 40,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  roleColor.withOpacity(0.8),
                                  roleColor.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Icon(
                              _roleIcon(role),
                              color: Colors.white70,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                roleColor.withOpacity(0.8),
                                roleColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: Icon(
                            _roleIcon(role),
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                ),
              ),
              
              // Role badge on bottom right of avatar
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    person['role'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Name with elegant typography
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              person['nama'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontSize: 26,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
                height: 1.3,
                fontFamily: 'Astral',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Role tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  roleColor.withOpacity(0.1),
                  roleColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: roleColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              _roleDisplayName(role).toUpperCase(),
              style: TextStyle(
                color: roleColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                fontFamily: 'Astral',
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Telegram Button (Elevated with icon)
          if (person['telegram'].toString().isNotEmpty)
            Container(
              width: 260,
              child: ElevatedButton(
                onPressed: () => _openTelegram(person['telegram']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0088CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF0088CC).withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.telegram,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Telegram',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Astral',
                            ),
                          ),
                          Text(
                            person['telegram'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Astral',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}