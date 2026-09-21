import 'dart:async';
import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/screens/auth/login_screen.dart';
import 'package:priomeet_app/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AppUserSession.loadSession().then((_) {
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          final isAuth = AppUserSession.userId.isNotEmpty && AppUserSession.userName.isNotEmpty;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => isAuth ? const HomeScreen() : const LoginScreen()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.5), blurRadius: 25)]),
              child: ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.asset('assets/icon/app_logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.favorite, size: 50, color: Color(0xFFFF2A85)))),
            ),
            const SizedBox(height: 20),
            const Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFFFF2A85), strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
