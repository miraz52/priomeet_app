import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class HostEarningsScreen extends StatefulWidget {
  const HostEarningsScreen({super.key});

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();
}

class _HostEarningsScreenState extends State<HostEarningsScreen> {
  int _diamonds = 1250;
  final double _rate = 0.20;
  String _method = 'bKash';
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  void _cashout() async {
    final d = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    final phone = _phoneCtrl.text.trim();
    if (d < 500 || d > _diamonds || phone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক তথ্য দিন (মিনিমাম ৫০০ 💎)!')));
      return;
    }
    setState(() => _isLoading = true);
    final bdt = d * _rate;
    final alert = "<b>💸 নতুন হোস্ট ক্যাশআউট!</b>\n👤 হোস্ট: <b>${AppUserSession.userName}</b>\n💎 ডায়মন্ড: <b>$d</b>\n💵 টাকা: <b>৳${bdt.toStringAsFixed(0)} টাকা</b>\n📱 মেথড: <b>$_method ($phone)</b>";
    final ok = await TelegramService.sendMessage(alert);
    setState(() => _isLoading = false);
    if (mounted && ok) {
      setState(() => _diamonds -= d);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ক্যাশআউট রিকোয়েস্ট সফল হয়েছে!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('হোস্ট আর্নিং 💎', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8A00D4), Color(0xFF16002A)]), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text('$_diamonds 💎', style: const TextStyle(color: Colors.cyanAccent, fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('আনুমানিক আয়: ৳${(_diamonds * _rate).toStringAsFixed(0)} টাকা', style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
                  const Text('রেট: ১ ডায়মন্ড = ২০ পয়সা', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _amountCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'ডায়মন্ড পরিমাণ (মিনিমাম ৫০০)', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 10),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'বিকাশ/নগদ নম্বর', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(onPressed: _isLoading ? null : _cashout, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)), child: const Text('ক্যাশআউট করুন')),
            ),
          ],
        ),
      ),
    );
  }
}
