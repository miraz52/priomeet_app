import 'package:priomeet_app/user_session.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:priomeet_app/screens/home/home_screen.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final String bkashNumber = "01746232340";
  final String nagadNumber = "01859785435";
  final String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  final String chatId = "5330021607";

  void _showVipPurchaseDialog(String planTitle, int price) {
    final phoneController = TextEditingController();
    final trxController = TextEditingController();
    String method = 'bKash';
    bool sending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E143A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('VIP সাবস্ক্রিপশন: $planTitle', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('মূল্য: ৳$price BDT (Send Money)', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => method = 'bKash'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: method == 'bKash' ? const Color(0xFFE2136E) : Colors.white10, borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Text('বিকাশ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => method = 'Nagad'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: method == 'Nagad' ? const Color(0xFFF7941D) : Colors.white10, borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Text('নগদ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('নম্বর: ${method == 'bKash' ? bkashNumber : nagadNumber}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'প্রেরক নম্বর (Phone)',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: trxController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Transaction ID (TrxID)',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: sending
                  ? null
                  : () async {
                      final pNum = phoneController.text.trim();
                      final trx = trxController.text.trim();
                      if (pNum.isEmpty || trx.isEmpty) return;

                      setDialogState(() => sending = true);

                      final telegramMsg = "👑 *নতুন VIP সাবস্ক্রিপশন অর্ডার!*\n\n"
                          "👤 ইউজার: ${AppUserSession.userName}\n"
                          "🆔 আইডি: `${AppUserSession.userId}`\n"
                          "👑 প্ল্যান: $planTitle\n"
                          "💰 মূল্য: ৳$price BDT\n"
                          "💳 মাধ্যম: $method\n"
                          "📱 প্রেরক: `$pNum`\n"
                          "🧾 TrxID: `$trx`";

                      try {
                        final url = Uri.parse("https://api.telegram.org/bot$botToken/sendMessage");
                        await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({"chat_id": chatId, "text": telegramMsg, "parse_mode": "Markdown"}),
                        );
                      } catch (_) {}

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('VIP রিকোয়েস্ট জমা হয়েছে! অ্যাডমিন সক্রিয় করে দেবে।'), backgroundColor: Colors.green),
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
              child: sending
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('নিশ্চিত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        elevation: 0,
        title: const Text('Prio VIP Club 👑', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // গোল্ডেন হেডার কার্ড
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF533100), Color(0xFF221400)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 48),
                  SizedBox(height: 10),
                  Text('ভিআইপি প্রিভিলেজ আনলক করুন', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('সীমাহীন মেসেজিং, বিশেষ ভিআইপি ব্যাজ ও প্রায়োরিটি সাপোর্ট সুবিধা।', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ১. সাপ্তাহিক ভিআইপি প্ল্যান
            _vipCard('সাপ্তাহিক ভিআইপি ১ পাস (৭ দিন)', 250, 'প্রতিদিন ২০টি ফ্রি কয়েন ক্লেইম + ভিআইপি ব্যাজ', () {
              _showVipPurchaseDialog('সাপ্তাহিক ভিআইপি ১ পাস (৭ দিন)', 250);
            }),

            const SizedBox(height: 14),

            // ২. মাসিক গোল্ডেন ক্রাউন প্ল্যান
            _vipCard('মাসিক রয়্যাল ক্রাউন (৩০ দিন)', 850, '১০০ কয়েন তাৎক্ষণিক বোনাস + আনলিমিটেড ফ্রি চ্যাট + গোল্ডেন ফ্রেম', () {
              _showVipPurchaseDialog('মাসিক রয়্যাল ক্রাউন (৩০ দিন)', 850);
            }, isBest: true),
          ],
        ),
      ),
    );
  }

  Widget _vipCard(String title, int price, String desc, VoidCallback onTap, {bool isBest = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF160F2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isBest ? const Color(0xFFFFD700) : Colors.white12, width: isBest ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('৳$price', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isBest ? const Color(0xFFFFD700) : const Color(0xFFFF2A85),
                foregroundColor: isBest ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ভিআইপি সক্রিয় করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
