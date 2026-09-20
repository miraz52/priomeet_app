import 'dart:math';
import 'package:flutter/material.dart';
import 'package:priomeet_app/screens/auth/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _loginAsGuest() {
    setState(() => _isLoading = true);
    final randomId = (100000 + Random().nextInt(900000)).toString();
    AppUserSession.userId = "Guest_$randomId";
    AppUserSession.userName = "Prio Guest";
    AppUserSession.isGuest = true;

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // লগইন সফল হলে পরবর্তী স্ক্রিনে যাওয়া
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const ProfileSetupScreen()),
      );
    });
  }

  void _loginWithGoogle() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppUserSession.userId = "User_${Random().nextInt(99999)}";
      AppUserSession.userName = "Google Verified";
      AppUserSession.isGuest = false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const ProfileSetupScreen()),
      );
    });
  }

  void _showPhoneLoginDialog() {
    final phoneController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF160F2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'মোবাইল নম্বর দিয়ে সাইন ইন',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'আপনার ১১ ডিজিটের পার্সোনাল নম্বরটি লিখুন:',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFFFF2A85)),
                hintText: '01XXXXXXXXX',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (phoneController.text.trim().length < 11) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন!')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  AppUserSession.userId = phoneController.text.trim();
                  AppUserSession.userName = "Mobile User";
                  AppUserSession.isGuest = false;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const ProfileSetupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('লগইন নিশ্চিত করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0818),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // প্রিমিয়াম ব্যাকগ্রাউন্ড
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.3,
                colors: [Color(0xFF381552), Color(0xFF0B0818)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),
                  // লোগো ও প্রিমিয়াম ব্যানার
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)]),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.5), blurRadius: 30, spreadRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PrioMeet',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '১-অন-১ লাইভ ভিডিও ডেটিং ও প্রাইভেসির নিরাপদ অভিজ্ঞতা',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const Spacer(),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Color(0xFFFF2A85)),
                    )
                  else ...[
                    // ১. গুগল সাইন-ইন বাটন
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata_rounded, size: 30, color: Colors.red),
                            SizedBox(width: 6),
                            Text('Google দিয়ে সাইন ইন করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ২. ফোন নম্বর লগইন বাটন
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _showPhoneLoginDialog,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          backgroundColor: Colors.white.withOpacity(0.04),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_iphone_rounded, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text('মোবাইল নম্বর দিয়ে সাইন ইন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ৩. কুইক গেস্ট লগইন (লুমির সিগনেচার বাটন)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loginAsGuest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2A85),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 6,
                          shadowColor: const Color(0xFFFF2A85).withOpacity(0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on_rounded, color: Colors.white),
                            SizedBox(width: 6),
                            Text('গেস্ট হিসেবে প্রবেশ (Quick Guest)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'প্রবেশের মাধ্যমে আপনি আমাদের টার্মস এবং ১৮+ ইউজার গাইডলাইন গ্রহণ করছেন।',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white30, fontSize: 10.5),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
