import 'dart:math';
import 'package:flutter/material.dart';
import 'package:priomeet_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _loginAsGuest() {
    setState(() => _isLoading = true);
    
    // অটো গেস্ট প্রোফাইল জেনারেট
    final randomId = (100000 + Random().nextInt(900000)).toString();
    AppUserSession.userId = "Prio_$randomId";
    AppUserSession.userName = "Guest User";
    AppUserSession.isGuest = true;
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const HomeScreen()),
      );
    });
  }

  void _showPhoneLoginDialog() {
    final phoneController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF191230),
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
            const Text(
              'ফোন নম্বর দিয়ে লগইন',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনার ১১ ডিজিটের মোবাইল নম্বরটি লিখুন:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFFF2A85)),
                hintText: '017XXXXXXXX',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      const SnackBar(content: Text('সঠিক মোবাইল নম্বর লিখুন!')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  AppUserSession.userId = phoneController.text.trim();
                  AppUserSession.userName = "Prio User";
                  AppUserSession.isGuest = false;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('লগইন / ওটিপি পাঠান', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
          // ব্যাকগ্রাউন্ড নিয়ন গ্লো
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [Color(0xFF3B1556), Color(0xFF0B0818)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // প্রিমিয়াম লোগো ও ব্র্যান্ডিং
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2A85).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 54),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'PrioMeet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '১-অন-১ রিয়েল-টাইম ভিডিও ডেটিং ও চ্যাট',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),

                  const Spacer(),

                  // ১. গেস্ট লগইন বাটন (লুমির মূল সাইকোলজি)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginAsGuest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2A85),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        elevation: 6,
                        shadowColor: const Color(0xFFFF2A85).withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flash_on_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text('গেস্ট হিসেবে প্রবেশ (Quick Guest)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ২. ফোন নম্বর লগইন
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _showPhoneLoginDialog,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        backgroundColor: Colors.white.withOpacity(0.04),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text('মোবাইল নম্বর দিয়ে লগইন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'প্রবেশ করার মাধ্যমে আপনি আমাদের টার্মস ও প্রাইভেসি পলিসিতে সম্মতি দিচ্ছেন',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white30, fontSize: 11),
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
