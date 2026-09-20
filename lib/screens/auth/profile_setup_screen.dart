import 'package:priomeet_app/user_session.dart';
import 'package:flutter/material.dart';
import 'package:priomeet_app/screens/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedGender = 'male'; // 'male' or 'female'
  bool _isEighteenPlus = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = AppUserSession.userName;
  }

  void _completeSetup() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে একটি নাম বা নিকনেম লিখুন!')),
      );
      return;
    }

    if (!_isEighteenPlus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PrioMeet ব্যবহার করতে আপনার বয়স ১৮+ হতে হবে!')),
      );
      return;
    }

    // সেশনে প্রোফাইল ডাটা আপডেট
    AppUserSession.userName = name;
    AppUserSession.gender = _selectedGender;
    AppUserSession.isHost = (_selectedGender == 'female');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0818),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.2,
            colors: [Color(0xFF32134E), Color(0xFF0B0818)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'প্রোফাইল সেটআপ 🌟',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'আপনার অভিজ্ঞতা কাস্টমাইজ করতে তথ্যগুলো দিন',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 30),

                // অবতার প্রিভিউ
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _selectedGender == 'female'
                                ? [const Color(0xFFFF2A85), Colors.purpleAccent]
                                : [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFF1E133A),
                          child: Icon(
                            _selectedGender == 'female' ? Icons.face_3 : Icons.face,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Text('আপনার নাম বা নিকনেম', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFFF2A85)),
                    hintText: 'যেমন: রিয়া বা রাহুল',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 24),
                const Text('আপনার লিঙ্গ (Gender) বেছে নিন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                const Text('এটি পরবর্তীতে পরিবর্তন করা যাবে না', style: TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 12),

                // ছেলে বনাম মেয়ে সিলেকশন কার্ড
                Row(
                  children: [
                    // ছেলে
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = 'male'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedGender == 'male' ? const Color(0xFF0D254C) : const Color(0xFF140F27),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedGender == 'male' ? const Color(0xFF00C6FF) : Colors.white12,
                              width: _selectedGender == 'male' ? 2 : 1,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.male, color: Color(0xFF00C6FF), size: 38),
                              SizedBox(height: 6),
                              Text('ছেলে', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 2),
                              Text('ম্যাচ ও কলিং মোড', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // মেয়ে
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = 'female'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedGender == 'female' ? const Color(0xFF38102C) : const Color(0xFF140F27),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedGender == 'female' ? const Color(0xFFFF2A85) : Colors.white12,
                              width: _selectedGender == 'female' ? 2 : 1,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.female, color: Color(0xFFFF2A85), size: 38),
                              SizedBox(height: 6),
                              Text('মেয়ে', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 2),
                              Text('হোস্ট আর্নিং মোড 💎', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // ১৮+ বয়স ভেরিফিকেশন চেক
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isEighteenPlus,
                        activeColor: const Color(0xFFFF2A85),
                        onChanged: (val) => setState(() => _isEighteenPlus = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'আমি নিশ্চিত করছি যে আমার বয়স ১৮ বছর বা তার বেশি।',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                // সাবমিট বাটন
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2A85),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 5,
                    ),
                    child: const Text('চালিয়ে যান (Continue)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
