import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:priomeet_app/screens/home_screen.dart';

class HostEarningsScreen extends StatefulWidget {
  const HostEarningsScreen({super.key});

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();
}

class _HostEarningsScreenState extends State<HostEarningsScreen> {
  int _diamonds = 450; // হোস্টের অর্জিত ডায়মন্ড
  int _currentMessageFee = 2;
  final TextEditingController _payoutNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'bKash';
  bool _isProcessing = false;

  final String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  final String chatId = "5330021607";

  Future<void> _submitWithdrawRequest() async {
    final num = _payoutNumberController.text.trim();
    final amtText = _amountController.text.trim();

    if (num.length < 11 || amtText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক ১১ ডিজিটের নম্বর ও উইথড্র পরিমাণ লিখুন!')),
      );
      return;
    }

    final amount = int.tryParse(amtText) ?? 0;
    if (amount < 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সর্বনিম্ন ২০০ টাকা উইথড্র করা যাবে!')),
      );
      return;
    }

    if (amount > _diamonds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপনার অ্যাকাউন্টে পর্যাপ্ত ডায়মন্ড নেই!')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // টেলিগ্রামে উইথড্র নোটিফিকেশন অ্যালার্ট পাঠানো
    final telegramMsg = "💸 *নতুন হোস্ট ক্যাশআউট রিকোয়েস্ট!*\n\n"
        "👤 হোস্ট: ${AppUserSession.userName}\n"
        "🆔 আইডি: `${AppUserSession.userId}`\n"
        "💳 মাধ্যম: $_selectedMethod\n"
        "📱 নম্বর: `$num`\n"
        "💰 পরিমাণ: ৳$amount ($amount ডায়মন্ড)\n"
        "⏰ সময়: ${DateTime.now().toLocal().toString().substring(0, 16)}";

    try {
      final url = Uri.parse("https://api.telegram.org/bot$botToken/sendMessage");
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chat_id": chatId,
          "text": telegramMsg,
          "parse_mode": "Markdown",
        }),
      );

      setState(() {
        _diamonds -= amount;
        _isProcessing = false;
      });

      _amountController.clear();
      _payoutNumberController.clear();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: const Color(0xFF1E143A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('রিকোয়েস্ট সফল! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            '৳$amount টাকা আপনার $_selectedMethod নম্বরে পাঠানোর আবেদন গৃহীত হয়েছে। অ্যাডমিন ভেরিফাই করে অল্প সময়ের মধ্যে টাকা পাঠাবে।',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(c),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
              child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        elevation: 0,
        title: const Text('হোস্ট ইনকাম ও পেআউট সেন্টার', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ডায়মন্ড আর্নিং কার্ড
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8E00FF), Color(0xFFFF2A85)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('মোট আর্নিং ব্যালেন্স', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.diamond_rounded, color: Colors.cyanAccent, size: 28),
                          const SizedBox(width: 8),
                          Text('$_diamonds ডায়মন্ড', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('সমমূল্য: ৳$_diamonds BDT', style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.currency_exchange_rounded, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // চ্যাট ফি কন্ট্রোল কার্ড
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('মেসেজ প্রতি ফি নির্ধারণ করুন 💌', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('ছেলেরা আপনাকে মেসেজ পাঠালে কত কয়েন করে আপনার অ্যাকাউন্টে জমা হবে:', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [1, 2, 3, 5].map((fee) {
                      final isSelected = _currentMessageFee == fee;
                      return GestureDetector(
                        onTap: () => setState(() => _currentMessageFee = fee),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF2A85) : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.white : Colors.white24),
                          ),
                          child: Text('$fee কয়েন', style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // বিকাশ ও নগদ ক্যাশআউট ফর্ম
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('বিকাশ / নগদ ক্যাশআউট রিকোয়েস্ট', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMethod = 'bKash'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedMethod == 'bKash' ? const Color(0xFFE2136E) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Text('বিকাশ (bKash)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMethod = 'Nagad'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedMethod == 'Nagad' ? const Color(0xFFF7941D) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Text('নগদ (Nagad)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _payoutNumberController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFFF2A85)),
                      hintText: 'আপনার $_selectedMethod নম্বর',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.money, color: Colors.greenAccent),
                      hintText: 'উইথড্র পরিমাণ (টাকা)',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _submitWithdrawRequest,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: _isProcessing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('ক্যাশআউট রিকোয়েস্ট পাঠান 💸', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
