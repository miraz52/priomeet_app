import 'dart:async';
import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/network_guard.dart';
import 'package:priomeet_app/screens/auth/login_screen.dart';
import 'package:priomeet_app/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final hasInternet = await NetworkGuard.checkInternet();
    if (!hasInternet) {
      if (mounted) NetworkGuard.showNoInternetDialog(context, _initializeApp);
      return;
    }

    await AppUserSession.loadSession();

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final bool isRegistered = AppUserSession.userId.isNotEmpty && AppUserSession.userName.isNotEmpty;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => isRegistered ? const HomeScreen() : const LoginScreen(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [Color(0xFF380854), Color(0xFF160324), Color(0xFF07040D)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.55), blurRadius: 35, spreadRadius: 4),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.asset('assets/icon/app_logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.favorite, size: 70, color: Color(0xFFFF2A85))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  const Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text('DATE & CONNECT', style: TextStyle(color: Color(0xFFD6A4FF), fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 50),
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF2A85))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
