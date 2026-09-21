import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _coins = 250;
  final _pCtrl = TextEditingController();
  final _tCtrl = TextEditingController();

  void _submit() async {
    final bdt = (_coins * 0.40).toStringAsFixed(0);
    TelegramService.sendMessage("<b>💰 রিচার্জ:</b> ${AppUserSession.userName} | $_coins কয়েন (৳$bdt) | Phone: ${_pCtrl.text} | Trx: ${_tCtrl.text}");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পেমেন্ট রিকোয়েস্ট পাঠানো হয়েছে!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('কয়েন ওয়ালেট')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('ব্যালেন্স: ${AppUserSession.coins} কয়েন (১ কয়েন = ০.৪০ টাকা)', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _pCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'বিকাশ/নগদ নম্বর', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 10),
            TextField(controller: _tCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'TrxID', filled: true, fillColor: Color(0xFF160F2A))),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)), child: const Text('সাবমিট করুন')),
          ],
        ),
      ),
    );
  }
}
