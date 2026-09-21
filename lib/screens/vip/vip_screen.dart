import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('ভিআইপি ক্লাব 👑')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            TelegramService.sendMessage("<b>👑 VIP:</b> ${AppUserSession.userName}");
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ভিআইপি আবেদন সম্পন্ন!')));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text('সাপ্তাহিক ভিআইপি নিন (৳৩০০)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
