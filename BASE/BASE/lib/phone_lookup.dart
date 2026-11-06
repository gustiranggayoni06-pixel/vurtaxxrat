// phone_lookup.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────────
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

// ─── Model Hasil Phone Lookup ────────────────────────────────────────────
class PhoneLookupResult {
  final String phoneNumber;
  final String phoneFormatted;
  final String countryCode;
  final String countryName;
  final String carrier;
  final String lineType;
  final bool isValid;
  final String? city;
  final String? operatorCode;
  final Map<String, dynamic> details;

  PhoneLookupResult({
    required this.phoneNumber,
    required this.phoneFormatted,
    required this.countryCode,
    required this.countryName,
    required this.carrier,
    required this.lineType,
    required this.isValid,
    this.city,
    this.operatorCode,
    required this.details,
  });
}

// ─── Phone Validator Service ─────────────────────────────────────────────
class PhoneValidator {
  static final Map<String, Map<String, String>> _indonesianOperators = {
    'Telkomsel': {
      'prefix': '0811,0812,0813,0821,0822,0823,0851,0852,0853,08521,08522,08523,081,082,085',
      'codes': '0811,0812,0813,0821,0822,0823,0851,0852,0853'
    },
    'XL Axiata': {
      'prefix': '0817,0818,0819,0859,0877,0878,0879,0817,0818,0819,0859,0877,0878,0879',
      'codes': '0817,0818,0819,0859,0877,0878,0879'
    },
    'Indosat (IM3/Ooredoo)': {
      'prefix': '0814,0815,0816,0855,0856,0857,0858,0814,0815,0816,0855,0856,0857,0858',
      'codes': '0814,0815,0816,0855,0856,0857,0858'
    },
    'Tri (3)': {
      'prefix': '0895,0896,0897,0898,0899,0895,0896,0897,0898,0899',
      'codes': '0895,0896,0897,0898,0899'
    },
    'Smartfren': {
      'prefix': '0881,0882,0883,0884,0885,0886,0887,0888,0889,0881,0882,0883,0884,0885,0886,0887,0888,0889',
      'codes': '0881,0882,0883,0884,0885,0886,0887,0888,0889'
    },
    'Axis': {
      'prefix': '0831,0832,0833,0834,0835,0836,0837,0838,0831,0832,0833,0834,0835,0836,0837,0838',
      'codes': '0831,0832,0833,0834,0835,0836,0837,0838'
    },
    'By.U': {
      'prefix': '0851,0852,0853',
      'codes': '0851,0852,0853'
    },
  };

  static final Map<String, Map<String, String>> _countries = {
    '+62': {'name': 'Indonesia', 'pattern': r'^(\+62|0)[0-9]{9,12}$'},
    '+1': {'name': 'United States', 'pattern': r'^\+1[0-9]{10}$'},
    '+44': {'name': 'United Kingdom', 'pattern': r'^\+44[0-9]{10}$'},
    '+91': {'name': 'India', 'pattern': r'^\+91[0-9]{10}$'},
    '+60': {'name': 'Malaysia', 'pattern': r'^\+60[0-9]{9,10}$'},
    '+65': {'name': 'Singapore', 'pattern': r'^\+65[0-9]{8}$'},
    '+63': {'name': 'Philippines', 'pattern': r'^\+63[0-9]{10}$'},
    '+66': {'name': 'Thailand', 'pattern': r'^\+66[0-9]{9}$'},
    '+84': {'name': 'Vietnam', 'pattern': r'^\+84[0-9]{9,10}$'},
    '+81': {'name': 'Japan', 'pattern': r'^\+81[0-9]{10}$'},
    '+82': {'name': 'South Korea', 'pattern': r'^\+82[0-9]{10}$'},
    '+86': {'name': 'China', 'pattern': r'^\+86[0-9]{11}$'},
    '+61': {'name': 'Australia', 'pattern': r'^\+61[0-9]{9}$'},
    '+49': {'name': 'Germany', 'pattern': r'^\+49[0-9]{10,11}$'},
    '+33': {'name': 'France', 'pattern': r'^\+33[0-9]{9}$'},
    '+39': {'name': 'Italy', 'pattern': r'^\+39[0-9]{10}$'},
    '+34': {'name': 'Spain', 'pattern': r'^\+34[0-9]{9}$'},
    '+55': {'name': 'Brazil', 'pattern': r'^\+55[0-9]{11}$'},
    '+7': {'name': 'Russia', 'pattern': r'^\+7[0-9]{10}$'},
    '+20': {'name': 'Egypt', 'pattern': r'^\+20[0-9]{10}$'},
    '+27': {'name': 'South Africa', 'pattern': r'^\+27[0-9]{9}$'},
    '+90': {'name': 'Turkey', 'pattern': r'^\+90[0-9]{10}$'},
  };

  static String detectCarrier(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanNumber.startsWith('62')) {
      cleanNumber = cleanNumber.substring(2);
    }
    
    if (!cleanNumber.startsWith('0')) {
      cleanNumber = '0$cleanNumber';
    }
    
    String prefix4 = cleanNumber.length >= 4 ? cleanNumber.substring(0, 4) : '';
    String prefix3 = cleanNumber.length >= 3 ? cleanNumber.substring(0, 3) : '';
    
    for (var entry in _indonesianOperators.entries) {
      if (entry.value['codes']!.contains(prefix4) || 
          entry.value['codes']!.contains(prefix3)) {
        return entry.key;
      }
    }
    
    return 'Unknown';
  }

  static String detectLineType(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanNumber.startsWith('62')) {
      cleanNumber = cleanNumber.substring(2);
    }
    if (!cleanNumber.startsWith('0')) {
      cleanNumber = '0$cleanNumber';
    }
    
    if (cleanNumber.startsWith('08') || cleanNumber.startsWith('06')) {
      return 'Mobile / Cellular';
    }
    if (cleanNumber.startsWith('02')) {
      return 'Landline / Fixed Line';
    }
    if (cleanNumber.startsWith('001') || cleanNumber.startsWith('007')) {
      return 'Toll Free / Special';
    }
    
    return 'Mobile';
  }

  static String formatPhoneNumber(String phoneNumber) {
    String clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    if (clean.startsWith('+62')) {
      String local = clean.substring(3);
      if (local.startsWith('0')) local = local.substring(1);
      if (local.length >= 4) {
        if (local.length == 10) {
          return '+62 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
        } else if (local.length == 11) {
          return '+62 ${local.substring(0, 4)} ${local.substring(4, 7)} ${local.substring(7)}';
        } else if (local.length == 12) {
          return '+62 ${local.substring(0, 3)} ${local.substring(3, 7)} ${local.substring(7)}';
        }
      }
      return '+62 $local';
    }
    
    return clean;
  }

  static PhoneLookupResult validate(String rawNumber) {
    String cleanNumber = rawNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    String detectedCountryCode = '';
    String detectedCountryName = '';
    bool isValid = false;
    
    for (var entry in _countries.entries) {
      if (cleanNumber.startsWith(entry.key)) {
        detectedCountryCode = entry.key;
        detectedCountryName = entry.value['name']!;
        RegExp pattern = RegExp(entry.value['pattern']!);
        isValid = pattern.hasMatch(cleanNumber);
        break;
      }
    }
    
    if (detectedCountryCode.isEmpty) {
      if (RegExp(r'^0[0-9]{9,12}$').hasMatch(cleanNumber)) {
        detectedCountryCode = '+62';
        detectedCountryName = 'Indonesia';
        isValid = true;
        cleanNumber = '+62${cleanNumber.substring(1)}';
      }
    }
    
    if (detectedCountryCode.isEmpty) {
      if (RegExp(r'^[0-9]{8,15}$').hasMatch(cleanNumber)) {
        detectedCountryCode = '+??';
        detectedCountryName = 'Unknown';
        isValid = true;
      }
    }
    
    String carrier = 'Unknown';
    String operatorCode = '';
    String? city;
    
    if (detectedCountryName == 'Indonesia') {
      carrier = detectCarrier(cleanNumber);
      
      String localNumber = cleanNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (localNumber.startsWith('62')) localNumber = localNumber.substring(2);
      if (!localNumber.startsWith('0')) localNumber = '0$localNumber';
      
      if (localNumber.startsWith('021')) city = 'Jakarta';
      else if (localNumber.startsWith('022')) city = 'Bandung';
      else if (localNumber.startsWith('0231')) city = 'Cirebon';
      else if (localNumber.startsWith('024')) city = 'Semarang';
      else if (localNumber.startsWith('0271')) city = 'Surakarta';
      else if (localNumber.startsWith('0274')) city = 'Yogyakarta';
      else if (localNumber.startsWith('031')) city = 'Surabaya';
      else if (localNumber.startsWith('0341')) city = 'Malang';
      else if (localNumber.startsWith('0361')) city = 'Denpasar';
      else if (localNumber.startsWith('0411')) city = 'Makassar';
      else if (localNumber.startsWith('061')) city = 'Medan';
      else if (localNumber.startsWith('0711')) city = 'Palembang';
      else if (localNumber.startsWith('0751')) city = 'Padang';
      else if (localNumber.startsWith('0771')) city = 'Pangkal Pinang';
      
      String numPart = localNumber.replaceFirst('0', '');
      if (numPart.length >= 4) {
        operatorCode = numPart.substring(0, 4);
      } else if (numPart.length >= 3) {
        operatorCode = numPart.substring(0, 3);
      }
    }
    
    String formatted = formatPhoneNumber(cleanNumber);
    String lineType = detectLineType(cleanNumber);
    
    return PhoneLookupResult(
      phoneNumber: rawNumber,
      phoneFormatted: formatted,
      countryCode: detectedCountryCode,
      countryName: detectedCountryName,
      carrier: carrier,
      lineType: lineType,
      isValid: isValid,
      city: city,
      operatorCode: operatorCode.isNotEmpty ? operatorCode : null,
      details: {
        'raw': rawNumber,
        'clean': cleanNumber,
        'formatted': formatted,
        'length': cleanNumber.replaceAll(RegExp(r'[^0-9]'), '').length,
      },
    );
  }
}

// ─── Main Page ────────────────────────────────────────────────────────────
class PhoneLookupPage extends StatefulWidget {
  const PhoneLookupPage({super.key});

  @override
  State<PhoneLookupPage> createState() => _PhoneLookupPageState();
}

class _PhoneLookupPageState extends State<PhoneLookupPage> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  PhoneLookupResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _lookupPhone() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });
    
    final phone = _phoneController.text.trim();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      final result = PhoneValidator.validate(phone);
      
      setState(() {
        _result = result;
        _isLoading = false;
        
        if (!result.isValid && result.countryName == 'Unknown') {
          _errorMessage = 'Format nomor tidak dikenali. Gunakan format internasional (+62, +1, dll)';
        }
      });
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label disalin',
          style: const TextStyle(color: Colors.white, fontFamily: 'Astral'),
        ),
        backgroundColor: _C.blueMid,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          Positioned.fill(child: _AnimatedBg(controller: _bgCtrl)),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInputSection(),
                        
                        const SizedBox(height: 24),
                        
                        if (_isLoading) _buildLoadingIndicator(),
                        
                        if (_errorMessage != null && !_isLoading)
                          _buildErrorMessage(),
                        
                        if (_result != null && !_isLoading)
                          _buildResultCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _C.surface,
            _C.bg,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: _C.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: _C.blue.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _C.blueLight,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _C.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _C.blueLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _C.blueLight.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PHONE LOOKUP',
                  style: TextStyle(
                    color: _C.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontFamily: 'Astral',
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
        ],
      ),
    );
  }
  
  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.surface,
            _C.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _C.blueLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nomor Telepon Lookup',
                        style: TextStyle(
                          color: _C.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: _C.text, fontFamily: 'Astral'),
                    cursorColor: _C.blueLight,
                    decoration: InputDecoration(
                      hintText: '+62 812 3456 7890',
                      hintStyle: const TextStyle(color: _C.textSub, fontFamily: 'Astral'),
                      prefixIcon: Icon(Icons.phone_android_rounded, color: _C.blueLight, size: 20),
                      filled: true,
                      fillColor: _C.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _C.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _C.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _C.blueLight, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _C.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      final cleanNumber = value.replaceAll(RegExp(r'[^0-9+]'), '');
                      if (cleanNumber.length < 8) {
                        return 'Nomor telepon terlalu pendek';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: _C.textSub, size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Format: +62 (Indonesia), +1 (US), +44 (UK), dll',
                          style: const TextStyle(color: _C.textSub, fontSize: 10, fontFamily: 'Astral'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  GestureDetector(
                    onTap: _lookupPhone,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _C.blueMid.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'LOOKUP NUMBER',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _C.blueLight,
              backgroundColor: _C.border,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Menganalisis nomor...',
            style: TextStyle(color: _C.textSub, fontFamily: 'Astral'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: _C.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: _C.textSub, fontFamily: 'Astral'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultCard() {
    final result = _result!;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _C.surface,
                _C.card,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                color: _C.blue.withOpacity(0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: result.isValid ? _C.green.withOpacity(0.1) : _C.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: result.isValid ? _C.green.withOpacity(0.3) : _C.red.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      result.isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: result.isValid ? _C.green : _C.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.phoneFormatted,
                          style: const TextStyle(
                            color: _C.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Astral',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.isValid ? 'Nomor Valid' : 'Nomor Tidak Valid',
                          style: TextStyle(
                            color: result.isValid ? _C.green : _C.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copyToClipboard(result.phoneFormatted, 'Nomor telepon'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _C.border),
                      ),
                      child: Icon(Icons.copy_rounded, color: _C.blueLight, size: 18),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(color: _C.border, height: 1),
              const SizedBox(height: 16),
              
              _buildInfoRow(
                icon: Icons.public_rounded,
                label: 'Country',
                value: '${result.countryCode} ${result.countryName}',
                onCopy: () => _copyToClipboard(result.countryName, 'Country'),
              ),
              const SizedBox(height: 12),
              
              if (result.carrier != 'Unknown') ...[
                _buildInfoRow(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: 'Carrier',
                  value: result.carrier,
                  onCopy: () => _copyToClipboard(result.carrier, 'Carrier'),
                ),
                const SizedBox(height: 12),
              ],
              
              _buildInfoRow(
                icon: Icons.devices_rounded,
                label: 'Line Type',
                value: result.lineType,
              ),
              const SizedBox(height: 12),
              
              if (result.city != null) ...[
                _buildInfoRow(
                  icon: Icons.location_city_rounded,
                  label: 'Area/City',
                  value: result.city!,
                ),
                const SizedBox(height: 12),
              ],
              
              if (result.operatorCode != null) ...[
                _buildInfoRow(
                  icon: Icons.qr_code_rounded,
                  label: 'Operator Code',
                  value: result.operatorCode!,
                ),
                const SizedBox(height: 12),
              ],
              
              _buildInfoRow(
                icon: Icons.format_size_rounded,
                label: 'Length',
                value: '${result.details['length']} digit',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.blueLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline_rounded, color: _C.blueLight, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.isValid 
                    ? 'Nomor terdeteksi dari ${result.countryName}. ${result.carrier != "Unknown" ? "Operator: ${result.carrier}." : ""}'
                    : 'Format nomor tidak dikenali. Gunakan kode negara (+62, +1, +44, dll)',
                  style: const TextStyle(color: _C.textSub, fontSize: 12, height: 1.4, fontFamily: 'Astral'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: _C.blueLight, size: 18),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: _C.textSub, fontSize: 13, fontFamily: 'Astral'),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _C.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Astral',
              ),
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _C.border),
                ),
                child: Icon(Icons.copy_rounded, color: _C.textSub, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────
class _AnimatedBg extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBg({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(controller.value),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = _C.border.withOpacity(0.22)
      ..strokeWidth = 0.5;
    
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final glow = Paint()
      ..shader = RadialGradient(colors: [
        _C.blueMid.withOpacity(0.10 + math.sin(t * math.pi * 2) * 0.03),
        Colors.transparent,
      ], radius: 0.9).createShader(
        Rect.fromCircle(center: Offset(size.width / 2, 0), radius: size.width)
      );
    canvas.drawCircle(Offset(size.width / 2, 0), size.width, glow);

    final glow2 = Paint()
      ..shader = RadialGradient(colors: [
        _C.blueLight.withOpacity(0.05 + math.cos(t * math.pi * 2) * 0.02),
        Colors.transparent,
      ], radius: 0.5).createShader(
        Rect.fromCircle(center: Offset(size.width * 0.85, size.height * 0.75), radius: size.width * 0.4)
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      size.width * 0.4,
      glow2,
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}