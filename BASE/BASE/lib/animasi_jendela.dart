import 'dart:async';
import 'package:flutter/material.dart';

class AnimasiJendela extends StatefulWidget {
  final Widget nextPage;
  const AnimasiJendela({super.key, required this.nextPage});

  @override
  State<AnimasiJendela> createState() => _AnimasiJendelaState();
}

class _AnimasiJendelaState extends State<AnimasiJendela> with TickerProviderStateMixin {
  late AnimationController _doorCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _doorAnim;
  late Animation<double> _textFade;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    
    _doorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _doorAnim = CurvedAnimation(parent: _doorCtrl, curve: Curves.easeInOutCubic);

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);

    _doorCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showText = true);
        _textCtrl.forward();
      }
    });

    Timer(const Duration(milliseconds: 500), () {
      _doorCtrl.forward();
    });
  }

  @override
  void dispose() {
    _doorCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _ketukPintu() {
    if (_doorCtrl.isCompleted || _doorCtrl.isAnimating) return;
    _doorCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _ketukPintu,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // GAMBAR PINTU TERBUKA (BELAKANG)
            Image.asset(
              'assets/images/pintu_terbuka.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),

            // GAMBAR PINTU TERTUTUP (DEPAN)
            AnimatedBuilder(
              animation: _doorAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-MediaQuery.of(context).size.width * _doorAnim.value, 0),
                  child: Opacity(
                    opacity: 1.0 - _doorAnim.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/pintu_tertutup.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
            ),

            // EFEK CAHAYA
            AnimatedBuilder(
              animation: _doorAnim,
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width * (1 - _doorAnim.value),
                  top: 0,
                  bottom: 0,
                  width: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(_doorAnim.value * 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                );
              },
            ),

            // TEKS NAMA
            if (_showText)
              FadeTransition(
                opacity: _textFade,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VURTAX X RAT', // <--- GANTI NAMA DI SINI
                        style: const TextStyle(
                          fontFamily: 'Genetic',
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4AF37),
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => widget.nextPage),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                          ),
                          child: const Text(
                            'MASUK',
                            style: TextStyle(
                              fontFamily: 'Astral',
                              color: Color(0xFFD4AF37),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // TEKS KETUK PINTU
            if (!_doorCtrl.isCompleted && !_doorCtrl.isAnimating)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(seconds: 1),
                    child: const Text(
                      'K E T U K   P I N T U',
                      style: TextStyle(
                        fontFamily: 'Astral',
                        color: Colors.white54,
                        fontSize: 14,
                        letterSpacing: 5,
                      ),
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