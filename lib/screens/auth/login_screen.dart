import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/network_guard.dart';
import 'package:priomeet_app/services/firebase_service.dart';
import 'package:priomeet_app/screens/auth/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    final hasNet = await NetworkGuard.checkInternet();
    if (!hasNet) {
      if (mounted) NetworkGuard.showNoInternetDialog(context, _handleRegistration);
      return;
    }

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final refCode = _referralController.text.trim();

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক Gmail / ইমেইল ঠিকানা দিন!')),
      );
      return;
    }

    if (phone.length < 11 || !phone.startsWith('01')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: 017XXXXXXXX)!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    AppUserSession.userEmail = email;
    AppUserSession.userPhone = phone;
    AppUserSession.userId = phone;
    AppUserSession.coins = 5;

    if (refCode.isNotEmpty) {
      final success = await FirebaseService.applyReferralCode(refCode);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 রেফারেল কোড সফল! বোনাস ১০ কয়েন যুক্ত হয়েছে!')),
        );
      }
    }

    await AppUserSession.saveSession();
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const ProfileSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF380854), Color(0xFF160324), Color(0xFF07040D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.5), blurRadius: 25, spreadRadius: 2),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/icon/app_logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Text('DATE & CONNECT', style: TextStyle(color: Color(0xFFD6A4FF), fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text('অথেন্টিক অ্যাকাউন্ট রেজিস্ট্রেশন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text('লাইভ সেবা পেতে আপনার রিয়েল তথ্য দিন', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                      const SizedBox(height: 20),

                      const Text('আপনার বৈধ Gmail অ্যাড্রেস', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mark_email_read_rounded, color: Color(0xFFFF2A85), size: 20),
                          hintText: 'example@gmail.com',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('মোবাইল নম্বর', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Color(0xFFFF2A85), size: 20),
                          hintText: '01XXXXXXXXX',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('রেফারেল কোড (ঐচ্ছিক - বোনাস ১০ কয়েন 🎁)', style: TextStyle(color: Color(0xFFFFCC00), fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _referralController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFFFCC00), size: 20),
                          hintText: 'বন্ধুর রেফারেল কোড দিন',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2A85),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('রেজিস্টার ও এগিয়ে যান', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('🔒 প্রতিটি অ্যাকাউন্ট ফায়ারবেস ক্লাউড সিকিউরিটি দিয়ে সুরক্ষিত।', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
