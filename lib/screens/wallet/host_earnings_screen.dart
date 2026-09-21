import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class HostEarningsScreen extends StatelessWidget {
  const HostEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pCtrl = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('হোস্ট আর্নিং 💎')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('১০০০ 💎 = ৳২০০ টাকা', style: TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: pCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'বিকাশ/নগদ নম্বর', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                TelegramService.sendMessage("<b>💸 ক্যাশআউট:</b> ${AppUserSession.userName} | Phone: ${pCtrl.text}");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ক্যাশআউট রিকোয়েস্ট সফল হয়েছে!')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
              child: const Text('ক্যাশআউট করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
