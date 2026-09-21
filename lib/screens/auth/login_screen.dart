import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/firebase_service.dart';
import 'package:priomeet_app/services/telegram_service.dart';
import 'package:priomeet_app/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = true;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _gender = 'male';

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (!email.contains('@') || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক ইমেইল ও পাসওয়ার্ড দিন!')));
      return;
    }

    if (_isSignUp) {
      AppUserSession.userName = name.isEmpty ? "User" : name;
      AppUserSession.userEmail = email;
      AppUserSession.userPhone = phone;
      AppUserSession.userId = phone.isEmpty ? email : phone;
      AppUserSession.userPassword = pass;
      AppUserSession.gender = _gender;
      AppUserSession.isHost = (_gender == 'female');
      AppUserSession.coins = 15;
      FirebaseService.syncUserProfile();
    } else {
      AppUserSession.userEmail = email;
      AppUserSession.userPassword = pass;
    }

    await AppUserSession.saveSession();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/icon/app_logo.png', width: 65, height: 65, errorBuilder: (_, __, ___) => const Icon(Icons.favorite, color: Color(0xFFFF2A85), size: 45)),
              const SizedBox(height: 10),
              const Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: () => setState(() => _isSignUp = true), style: ElevatedButton.styleFrom(backgroundColor: _isSignUp ? const Color(0xFFFF2A85) : const Color(0xFF160F2A)), child: const Text('রেজিস্ট্রেশন'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: () => setState(() => _isSignUp = false), style: ElevatedButton.styleFrom(backgroundColor: !_isSignUp ? const Color(0xFFFF2A85) : const Color(0xFF160F2A)), child: const Text('লগইন'))),
                ],
              ),
              const SizedBox(height: 20),
              if (_isSignUp) ...[
                TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'আপনার নাম', filled: true, fillColor: Color(0xFF160F2A))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: ChoiceChip(label: const Text('ছেলে (User)'), selected: _gender == 'male', onSelected: (_) => setState(() => _gender = 'male'))),
                    const SizedBox(width: 10),
                    Expanded(child: ChoiceChip(label: const Text('মেয়ে (Host 💎)'), selected: _gender == 'female', onSelected: (_) => setState(() => _gender = 'female'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'মোবাইল নম্বর', filled: true, fillColor: Color(0xFF160F2A))),
                const SizedBox(height: 10),
              ],
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Gmail অ্যাড্রেস', filled: true, fillColor: Color(0xFF160F2A))),
              const SizedBox(height: 10),
              TextField(controller: _passCtrl, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'পাসওয়ার্ড (৬+ অক্ষর)', filled: true, fillColor: Color(0xFF160F2A))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)), child: Text(_isSignUp ? 'একাউন্ট খুলুন' : 'লগইন করুন'))),
            ],
          ),
        ),
      ),
    );
  }
}
