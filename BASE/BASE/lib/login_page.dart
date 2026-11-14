import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:local_auth/local_auth.dart';
import 'api_config.dart';
import 'splash.dart';

// ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────────
class _C {
  static const bg         = Color(0xFFDCEEFB);  // biru muda lembut
  static const surface    = Color(0xFFFFFFFF);  // putih
  static const card       = Color(0xFFF0F7FF);  // biru sangat pucat
  static const border     = Color(0xFF42A5F5);  // biru cerah
  static const borderLit  = Color(0xFF42A5F5);

  static const blueLight  = Color(0xFF42A5F5);
  static const blueMid    = Color(0xFF1565C0);  // biru tua accent
  static const blueDark   = Color(0xFF1565C0);
  static const blueMuda   = Color(0xFF64B5F6);
  static const redLight   = Color(0xFFEF4444);
  static const redDark    = Color(0xFFC62828);

  static const blue       = Color(0xFF1565C0);
  static const red        = Color(0xFFEF4444);
  static const amber      = Color(0xFFFFC34D);

  static const text       = Color(0xFF000000);  // hitam 87%
  static const textSub    = Color(0x8A000000);  // hitam 54%
  static const textDim    = Color(0x61000000);  // hitam 38%

  static const LinearGradient metalGrad = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFFF0F7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGrad = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGrad = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFC62828), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final userCtrl    = TextEditingController();
  final passCtrl    = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  bool _isLoading       = false;
  bool _obscurePass     = true;
  String? _androidId;
  final LocalAuthentication _localAuth = LocalAuthentication();
//  late VideoPlayerController _videoController;
 // bool _videoInitialized = false;

  late AnimationController _entranceCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _btnCtrl;
  late AnimationController _shakeCtrl;

  late Animation<double> _fade;
  late Animation<Offset>  _slide;
  late Animation<double>  _logoGlow;
  late Animation<double>  _btnPulse;
  late Animation<double>  _shake;

  @override
  void initState() {
    super.initState();

    //_videoController = VideoPlayerController.asset('assets/videos/background.mp4')
  //    ..initialize().then((_) {
    //    setState(() {
     //     _videoInitialized = true;
    //    });
    //    _videoController.setLooping(true);
    //    _videoController.setVolume(1.0);
   //     _videoController.play();
  //    });

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _btnPulse = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0),   weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0),    weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _entranceCtrl.forward();
    _initLogin();
  }

  @override
  void dispose() {
//    _videoController.dispose();
    _entranceCtrl.dispose();
    _logoCtrl.dispose();
    _btnCtrl.dispose();
    _shakeCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLogin() async {
    final info = await DeviceInfoPlugin().androidInfo;
    _androidId = info.id;
    // Login otomatis dinonaktifkan agar sesi tersimpan tidak melewati
    // verifikasi perangkat. Pengguna dapat memakai tombol verifikasi perangkat.
  }

  List<Map<String, dynamic>> _parseList(dynamic raw) =>
      (raw as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = userCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      final res  = await http.post(
          Uri.parse('$baseUrl/validate'),
          body: {
            'username': username,
            'password': password,
            'androidId': _androidId ?? 'unknown',
          });
      final data = jsonDecode(res.body);

      if (data['expired'] == true) {
        _shakeCtrl.forward(from: 0);
        _showAlert(
          title: 'Akses Habis',
          message: 'Masa akses Anda telah berakhir. Silakan perpanjang.',
          type: _AlertType.warning,
          showContact: true,
        );
      } else if (data['valid'] != true) {
        _shakeCtrl.forward(from: 0);
        final msg = (data['message'] ?? '').toString().toLowerCase();
        if (msg.contains('perangkat') || msg.contains('device') ||
            msg.contains('another')) {
          _showAlert(
            title: 'Sesi Aktif',
            message: 'Akun ini sedang login di perangkat lain.',
            type: _AlertType.warning,
          );
        } else {
          _showAlert(
            title: 'Login Gagal',
            message: 'Username atau password salah.',
            type: _AlertType.error,
          );
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        // Tunggu sampai kredensial tersimpan sebelum berpindah halaman.
        await prefs.setString('username', username);
        await prefs.setString('password', password);
        await prefs.setString('key', data['key']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SplashScreen(
              username: username, password: password,
              role: data['role'], sessionKey: data['key'],
              expiredDate: data['expiredDate'],
              listBug:  _parseList(data['listBug']),
              listDoos: _parseList(data['listDDoS']),
              news:     _parseList(data['news']),
            )),
          );
        }
      }
    } catch (_) {
      _shakeCtrl.forward(from: 0);
      _showAlert(
        title: 'Koneksi Error',
        message: 'Gagal terhubung ke server. Periksa jaringan Anda.',
        type: _AlertType.error,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Verifikasi memakai autentikasi sistem perangkat (biometrik atau kredensial layar kunci).
  Future<void> _deviceLogin() async {
    if (_isLoading) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('username');
      final savedPass = prefs.getString('password');

      if (savedUser == null || savedPass == null) {
        _showAlert(
          title: 'Login perangkat belum tersedia',
          message: 'Silakan login dengan username dan password terlebih dahulu.',
          type: _AlertType.warning,
        );
        return;
      }

      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        _showAlert(
          title: 'Verifikasi tidak didukung',
          message: 'Perangkat ini tidak mendukung verifikasi layar kunci.',
          type: _AlertType.warning,
        );
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verifikasi untuk masuk ke akun VURTAX X RAT',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!authenticated || !mounted) return;

      userCtrl.text = savedUser;
      passCtrl.text = savedPass;
      await _login();
    } catch (e) {
      if (!mounted) return;
      _showAlert(
        title: 'Verifikasi gagal',
        message: 'Autentikasi perangkat gagal atau dibatalkan. Gunakan login biasa.',
        type: _AlertType.error,
      );
    }
  }

  void _showAlert({
    required String title,
    required String message,
    required _AlertType type,
    bool showContact = false,
  }) {
    final color = switch (type) {
      _AlertType.error   => _C.red,
      _AlertType.warning => _C.amber,
      _AlertType.success => _C.blue,
    };
    final icon = switch (type) {
      _AlertType.error   => Icons.error_rounded,
      _AlertType.warning => Icons.warning_amber_rounded,
      _AlertType.success => Icons.check_circle_rounded,
    };

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_C.card, _C.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.15), blurRadius: 50),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    color: _C.text, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Astral')),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _C.textSub, fontSize: 13, height: 1.5, fontFamily: 'Astral')),
            const SizedBox(height: 24),
            if (showContact) ...[
              _GradBtn(
                label: 'HUBUNGI ADMIN',
                fullWidth: true,
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchUrl(Uri.parse('https://t.me/ranzz_offczaxx_stur'),
                      mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 12),
            ],
            _OutlineBtn(
              label: showContact ? 'TUTUP' : 'OK',
              fullWidth: true,
              onTap: () => Navigator.pop(ctx),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // SESUDAH (Ganti jadi Gambar)
Positioned.fill(
  child: Image.asset(
    'assets/images/bg_jdm.jpg', // <--- Sesuaikan dengan nama file Tuan
    fit: BoxFit.cover,
  ),
),
          // Overlay putih
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.0),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 20),
                        _buildHeading(),
                        const SizedBox(height: 24),
                        AnimatedBuilder(
                          animation: _shake,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(_shake.value, 0),
                            child: child,
                          ),
                          child: _buildForm(),
                        ),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoGlow,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _C.blueMid.withOpacity(_logoGlow.value * 0.15),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _C.blueMid.withOpacity(_logoGlow.value * 0.3),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 92, height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _C.blueMuda.withOpacity(_logoGlow.value * 0.5),
                width: 2,
              ),
            ),
          ),
          Hero(
            tag: 'logo',
            child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0F7FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _C.blueMuda.withOpacity(_logoGlow.value * 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.blueMid.withOpacity(_logoGlow.value * 0.6),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.sports_soccer_rounded,
                      color: _C.blueMuda, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Column(children: [
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(b),
        child: const Text(
          "VURTAX X RAT",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
            fontFamily: 'Astral',
          ),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border, width: 1),
        ),
        child: const Text('Masuk ke akunmu',
            style: TextStyle(
                color: _C.textSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Astral')),
      ),
    ]);
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.card.withOpacity(0.85),
            _C.surface.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: [
          BoxShadow(
              color: _C.blueMid.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 15)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(children: [
          Row(children: [
            Container(
              width: 5, height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_C.blueMid, _C.blueLight],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.account_circle_rounded,
                color: _C.blueMid, size: 18),
            const SizedBox(width: 8),
            const Text('Username & password',
                style: TextStyle(
                    color: _C.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    fontFamily: 'Astral')),
          ]),
          const SizedBox(height: 22),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Welcome back',
                style: TextStyle(
                    color: _C.blueMid,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Astral')),
          ),
          const SizedBox(height: 20),

          _LoginField(
            controller: userCtrl,
            label: 'Username',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Username tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),

          _LoginField(
            controller: passCtrl,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            onToggleObscure: () =>
                setState(() => _obscurePass = !_obscurePass),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password tidak boleh kosong' : null,
          ),
          const SizedBox(height: 28),

          _LoginButton(
            isLoading: _isLoading,
            pulseAnim: _btnPulse,
            onTap: _login,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _deviceLogin,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text(
                'Verifikasi perangkat (Fingerprint / Wajah / PIN)',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Astral', fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.blueMid,
                side: const BorderSide(color: _C.border, width: 1.3),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(children: [
      const Text('Masuk ke akunmu',
          style: TextStyle(color: _C.textSub, fontSize: 13, fontFamily: 'Astral')),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.circle, color: _C.blueMid, size: 5),
        const SizedBox(width: 8),
        const Text("© 2026 VURTAX X RAT",
            style: TextStyle(
                color: _C.textDim,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                fontFamily: 'Astral')),
        const SizedBox(width: 8),
        Icon(Icons.circle, color: _C.blueLight, size: 5),
      ]),
    ]);
  }
}

// ─── Login Field ─────────────────────────────────────────────────────────
class _LoginField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
  });

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  bool _focused = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? _C.blueLight : _C.border,
          width: _focused ? 1.5 : 1.0,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                    color: _C.blueLight.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscure,
        validator: widget.validator,
        style: const TextStyle(
            color: _C.text, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Astral'),
        cursorColor: _C.blueLight,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
              color: _focused ? _C.blueMuda : _C.textSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Astral'),
          floatingLabelStyle:
              const TextStyle(color: _C.blueLight, fontSize: 11, fontFamily: 'Astral'),
          prefixIcon: Icon(widget.icon,
              color: _focused ? _C.blueMuda : _C.textSub, size: 20),
          suffixIcon: widget.onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    widget.obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _focused ? _C.blueMuda : _C.textSub,
                    size: 20,
                  ),
                  onPressed: widget.onToggleObscure,
                )
              : null,
          errorStyle: const TextStyle(color: _C.red, fontSize: 11, fontFamily: 'Astral'),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }
}

// ─── Login Button ────────────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const _LoginButton({
    required this.isLoading,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedBuilder(
        animation: widget.pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: widget.isLoading || _down ? 1.0 : widget.pulseAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: widget.isLoading
                  ? const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1565C0)])
                  : const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _down || widget.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF1565C0)
                            .withOpacity(widget.pulseAnim.value * 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: widget.isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Row(
                        key: ValueKey('idle'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                fontFamily: 'Astral',
                              )),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Button ────────────────────────────────────────────────────
class _GradBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _GradBtn(
      {required this.label, required this.onTap, this.fullWidth = false});

  @override
  State<_GradBtn> createState() => _GradBtnState();
}

class _GradBtnState extends State<_GradBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 48,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: _C.accentGrad,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _down
                ? []
                : [
                    BoxShadow(
                        color: _C.blueMid.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
          ),
          child: Center(
            child: Text(widget.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    fontFamily: 'Astral')),
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ─────────────────────────────────────────────────────
class _OutlineBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _OutlineBtn(
      {required this.label, required this.onTap, this.fullWidth = false});

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        width: widget.fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: _down ? _C.border.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border, width: 1.5),
        ),
        child: Center(
          child: Text(widget.label,
              style: const TextStyle(
                  color: _C.textSub,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  fontFamily: 'Astral')),
        ),
      ),
    );
  }
}

enum _AlertType { error, warning, success }