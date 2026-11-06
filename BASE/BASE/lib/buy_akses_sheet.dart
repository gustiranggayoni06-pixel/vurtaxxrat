import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart'; // ✅ Tambahkan import

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

// ─── VURTAX X RAT THEME (SESUAI DASHBOARD) ──────────────────────────────────────────
const Color _kBg      = Color(0xFFDCEEFB);  // biru muda lembut
const Color _kSurface = Color(0xFFFFFFFF);  // putih
const Color _kCard    = Color(0xFFF0F7FF);  // biru sangat pucat
const Color _kBorder  = Color(0xFF42A5F5);  // biru cerah
const Color _kBlue    = Color(0xFF1565C0);  // biru tua accent
const Color _kBlueLit = Color(0xFF42A5F5);
const Color _kText    = Color(0xFF000000);  // hitam 87%
const Color _kTextSub = Color(0x8A000000);  // hitam 54%
const Color _kTextDim = Color(0x61000000);  // hitam 38%
const Color _kGold    = Color(0xFFF59E0B);

const _telegramUrl = 'https://t.me/ranzz_offczaxx_str';

// ─── Paket Model ──────────────────────────────────────────────────────────────
class _Paket {
  final String role;
  final String desc;
  final Color color;
  final IconData icon;
  final List<_Harga> hargaList;

  const _Paket({
    required this.role,
    required this.desc,
    required this.color,
    required this.icon,
    required this.hargaList,
  });
}

class _Harga {
  final String label;
  final String harga;
  const _Harga(this.label, this.harga);
}

// ─── Data Paket (Sinkron dengan semua role) ──────────────────────────────────
final _paketList = [
  _Paket(
    role: 'MEMBER',
    desc: 'Paket member standard',
    color: _roleColor('member'),
    icon: _roleIcon('member'),
    hargaList: [
      _Harga('Trial Sehari',  'Rp 3.000'),
      _Harga('Trial Sebulan', 'Rp 10.000'),
      _Harga('Permanen',      'Rp 20.000'),
    ],
  ),
  _Paket(
    role: 'VIP',
    desc: 'Get Rat + Sender Global',
    color: _roleColor('vip'),
    icon: _roleIcon('vip'),
    hargaList: [
      _Harga('Trial Sebulan', 'Rp 15.000'),
      _Harga('Permanen', 'Rp 25.000'),
    ],
  ),
  _Paket(
    role: 'RESELLER',
    desc: 'Bisa jual akun Member',
    color: _roleColor('reseller'),
    icon: _roleIcon('reseller'),
    hargaList: [
      _Harga('Trial Sebulan', 'Rp 25.000'),
      _Harga('Permanen', 'Rp 35.000'),
    ],
  ),
  _Paket(
    role: 'ADMIN',
    desc: 'Bisa manage user & create member/reseller/vip',
    color: _roleColor('admin'),
    icon: _roleIcon('admin'),
    hargaList: [
      _Harga('Trial Sebulan', 'Rp 30.000'),
      _Harga('Permanen', 'Rp 45.000'),
    ],
  ),
  _Paket(
    role: 'TK',
    desc: 'Tangan Kanan Apk',
    color: _roleColor('tk'),
    icon: _roleIcon('tk'),
    hargaList: [
      _Harga('Permanen', 'Rp 45.000'),
    ],
  ),
  _Paket(
    role: 'OWNER',
    desc: 'Bisa jual sampai TK',
    color: _roleColor('owner'),
    icon: _roleIcon('owner'),
    hargaList: [
      _Harga('Permanen', 'Rp 65.000'),
    ],
  ),
  _Paket(
    role: 'HIGH OWNER',
    desc: 'Bisa jual sampai Owner',
    color: _roleColor('high owner'),
    icon: _roleIcon('high owner'),
    hargaList: [
      _Harga('Permanen', 'Rp 70.000'),
    ],
  ),
  _Paket(
    role: 'KINGZ',
    desc: 'Bisa jual sampai High Owner',
    color: _roleColor('kingz'),
    icon: _roleIcon('kingz'),
    hargaList: [
      _Harga('Permanen', 'Rp 80.000'),
    ],
  ),
  _Paket(
    role: 'FOUNDER',
    desc: 'Bisa jual sampai Kingz',
    color: _roleColor('founder'),
    icon: _roleIcon('founder'),
    hargaList: [
      _Harga('Permanen', 'Rp 90.000'),
    ],
  ),
  _Paket(
    role: 'DEVELOPER',
    desc: 'Full akses & manage semua',
    color: _roleColor('developer'),
    icon: _roleIcon('developer'),
    hargaList: [
      _Harga('Permanen', 'Rp 150.000'),
    ],
  ),
];

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────
class _BuyAksesSheet extends StatefulWidget {
  const _BuyAksesSheet();

  @override
  State<_BuyAksesSheet> createState() => _BuyAksesSheetState();
}

class _BuyAksesSheetState extends State<_BuyAksesSheet> {
  int _selectedPaket = 0;
  int _selectedHarga = 0;

  Future<void> _openTelegram() async {
    final p = _paketList[_selectedPaket];
    final h = p.hargaList[_selectedHarga];
    final msg = Uri.encodeComponent(
      'Halo, saya mau beli akses:\n'
      '• Role: ${p.role}\n'
      '• Paket: ${h.label}\n'
      '• Harga: ${h.harga}\n\n'
      'Mohon info selanjutnya 🙏',
    );
    final url = '$_telegramUrl?text=$msg';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa buka Telegram')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _paketList[_selectedPaket];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: _kBorder)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBlue.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.shopping_cart_rounded, color: _kBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BUY AKSES',
                        style: TextStyle(
                          color: _kText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Astral',
                          letterSpacing: 2,
                        ),
                      ),
                      Text('Pilih paket yang tersedia',
                        style: TextStyle(color: _kTextSub, fontSize: 12, fontFamily: 'Astral'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: _kBorder, height: 1),

            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [

                  // Pilih Role
                  const Text('PILIH ROLE',
                    style: TextStyle(
                      color: _kTextSub,
                      fontSize: 11,
                      fontFamily: 'Astral',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Cards
                  ...List.generate(_paketList.length, (i) {
                    final pkg = _paketList[i];
                    final isSelected = _selectedPaket == i;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedPaket = i;
                        _selectedHarga = 0;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? pkg.color.withOpacity(0.12)
                              : _kCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? pkg.color : _kBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: pkg.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: pkg.color.withOpacity(0.4)),
                              ),
                              child: Icon(pkg.icon, color: pkg.color, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(_roleDisplayName(pkg.role),
                                        style: TextStyle(
                                          color: pkg.color,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Astral',
                                        ),
                                      ),
                                      if (pkg.role == 'OWNER' || pkg.role == 'HIGH OWNER' || pkg.role == 'KINGZ') ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _kGold.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _kGold.withOpacity(0.4)),
                                          ),
                                          child: const Text('RECOMMENDED',
                                            style: TextStyle(
                                              color: _kGold,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Astral',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(pkg.desc,
                                    style: const TextStyle(color: _kTextSub, fontSize: 11, fontFamily: 'Astral'),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: pkg.color, size: 22)
                            else
                              const Icon(Icons.radio_button_unchecked_rounded, color: _kBorder, size: 22),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Pilih Durasi (kalau lebih dari 1 harga)
                  if (p.hargaList.length > 1) ...[
                    const Text('PILIH DURASI',
                      style: TextStyle(
                        color: _kTextSub,
                        fontSize: 11,
                        fontFamily: 'Astral',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(p.hargaList.length, (i) {
                      final h = p.hargaList[i];
                      final isSelected = _selectedHarga == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedHarga = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? p.color.withOpacity(0.1) : _kCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? p.color : _kBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: isSelected ? p.color : _kBorder,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(h.label,
                                style: TextStyle(
                                  color: isSelected ? _kText : _kTextSub,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontFamily: 'Astral',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: p.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: p.color.withOpacity(0.3)),
                                ),
                                child: Text(h.harga,
                                  style: TextStyle(
                                    color: p.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Astral',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    // Satu harga saja
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: p.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: p.color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.hargaList[0].label,
                            style: const TextStyle(color: _kTextSub, fontSize: 13, fontFamily: 'Astral'),
                          ),
                          Text(p.hargaList[0].harga,
                            style: TextStyle(
                              color: p.color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Astral',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: _kBg,
                border: Border(top: BorderSide(color: _kBorder)),
              ),
              child: Column(
                children: [
                  // Summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_roleDisplayName(p.role)} • ${p.hargaList[_selectedHarga].label}',
                          style: const TextStyle(color: _kTextSub, fontSize: 12, fontFamily: 'Astral'),
                        ),
                        Text(
                          p.hargaList[_selectedHarga].harga,
                          style: TextStyle(
                            color: p.color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Beli Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openTelegram,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'BELI VIA TELEGRAM',
                        style: TextStyle(
                          fontFamily: 'Astral',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Show Function ────────────────────────────────────────────────────────────
void showBuyAksesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BuyAksesSheet(),
  );
}