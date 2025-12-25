import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:hackto/screens/login%20screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseScale;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();

    // Logo pop-in scale
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);

    // Rotation (infinite)
    _rotationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);

    // Pulse effect
    _pulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseScale =
        Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut,
        ));

    // Fade-in text
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeOpacity =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Start animations
    _logoController.forward();
    _fadeController.forward();

    // Navigate to Login Screen after 3s
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A85B6), // bluish
              Color(0xFFbac8e0), // greyish light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_rotationController, _pulseController, _logoController]),
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating dotted circle
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: _CirclePainter(),
                        ),
                      ),

                      // Pulsing Glow
                      Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                        ),
                      ),

                      // Logo (Hospital icon)
                      ScaleTransition(
                        scale: _logoScale,
                        child: const Icon(Icons.local_hospital,
                            size: 72, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Fade-in hospital name in center
                  FadeTransition(
                    opacity: _fadeOpacity,
                    child: const Text(
                      'MEDICORE',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Custom painter for rotating dotted circle
class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    const dashCount = 30;
    const dashLength = 2 * math.pi / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      final startAngle = i * dashLength;
      final sweepAngle = dashLength * 0.7;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}