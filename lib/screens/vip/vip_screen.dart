import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final TextEditingController _trxCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  void _buyVip() async {
    final p = _phoneCtrl.text.trim();
    final t = _trxCtrl.text.trim();
    if (p.isEmpty || t.isEmpty) return;

    final alert = "<b>👑 নতুন ভিআইপি আবেদন!</b>\n👤 ইউজার: ${AppUserSession.userName}\n📞 ফোন: $p\n🧾 TrxID: $t";
    TelegramService.sendMessage(alert);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ভিআইপি আবেদন পাঠানো হয়েছে!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('ভিআইপি পাস 👑', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]), borderRadius: BorderRadius.circular(20)),
              child: const Text('👑 ভিআইপি মেম্বারশিপ\n• আনলিমিটেড ফ্রি চ্যাট\n• স্পেশাল গোল্ড ব্যাজ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 20),
            TextField(controller: _phoneCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'প্রেরকের নম্বর', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 10),
            TextField(controller: _trxCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'TrxID', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(onPressed: _buyVip, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)), child: const Text('৳৩০০ টাকায় সাপ্তাহিক ভিআইপি নিন')),
            ),
          ],
        ),
      ),
    );
  }
}
