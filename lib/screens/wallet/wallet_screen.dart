import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:priomeet_app/screens/home_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final String bkashNumber = "01746232340";
  final String nagadNumber = "01859785435";
  final String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  final String chatId = "5330021607";

  final List<Map<String, dynamic>> coinPacks = [
    {'coins': 50, 'bonus': '+5 ফ্রি', 'price': 100},
    {'coins': 120, 'bonus': '+20 ফ্রি', 'price': 200},
    {'coins': 200, 'bonus': '+40 ফ্রি', 'price': 300},
    {'coins': 550, 'bonus': '+100 ফ্রি', 'price': 700},
  ];

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label নম্বর কপি করা হয়েছে: $text'), backgroundColor: const Color(0xFFFF2A85)),
    );
  }

  void _showTrxDialog(String packageName, int price) {
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
          title: Text('$packageName (৳$price)', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('টাকা পাঠানোর মাধ্যম সিলেক্ট করুন:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => method = 'bKash'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: method == 'bKash' ? const Color(0xFFE2136E) : Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          decoration: BoxDecoration(
                            color: method == 'Nagad' ? const Color(0xFFF7941D) : Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('নগদ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'নম্বর: ${method == 'bKash' ? bkashNumber : nagadNumber} (Send Money)',
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'যে নম্বর থেকে পাঠিয়েছেন',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: sending
                  ? null
                  : () async {
                      final pNum = phoneController.text.trim();
                      final trx = trxController.text.trim();
                      if (pNum.isEmpty || trx.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সবগুলো ঘর পূরণ করুন!')));
                        return;
                      }

                      setDialogState(() => sending = true);

                      final telegramMsg = "💳 *নতুন কয়েন রিচার্জ আবেদন!*\n\n"
                          "👤 ইউজার: ${AppUserSession.userName}\n"
                          "🆔 আইডি: `${AppUserSession.userId}`\n"
                          "📦 প্যাকেজ: $packageName\n"
                          "💰 মূল্য: ৳$price BDT\n"
                          "💳 মাধ্যম: $method\n"
                          "📱 প্রেরক নম্বর: `$pNum`\n"
                          "🧾 TrxID: `$trx`\n"
                          "⏰ সময়: ${DateTime.now().toLocal().toString().substring(0, 16)}";

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
                        const SnackBar(
                          content: Text('পেমেন্ট রিকোয়েস্ট সফল হয়েছে! অ্যাডমিন যাচাই করে কয়েন যোগ করে দেবে।'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
              child: sending
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('সাবমিট করুন', style: TextStyle(color: Colors.white)),
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
        title: const Text('কয়েন ওয়ালেট রিচার্জ 💎', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ব্যালেন্স কার্ড
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.4), blurRadius: 20),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('আপনার বর্তমান ব্যালেন্স', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 28),
                          const SizedBox(width: 8),
                          Text('${AppUserSession.coins} কয়েন', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.flash_on, color: Colors.amberAccent, size: 30),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ১-ট্যাপ কপি পেমেন্ট নম্বর বক্স
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ম্যানুয়াল পেমেন্ট নম্বর (Send Money):', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(bkashNumber, 'বিকাশ'),
                          icon: const Icon(Icons.copy, size: 14, color: Color(0xFFE2136E)),
                          label: Text('বিকাশ: $bkashNumber', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2136E))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(nagadNumber, 'নগদ'),
                          icon: const Icon(Icons.copy, size: 14, color: Color(0xFFF7941D)),
                          label: Text('নগদ: $nagadNumber', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF7941D))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('সাশ্রয়ী কয়েন প্যাকেজ সমূহ 👇', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // প্যাকেজ গ্রিড
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: coinPacks.length,
              itemBuilder: (context, i) {
                final pack = coinPacks[i];
                return GestureDetector(
                  onTap: () => _showTrxDialog("${pack['coins']} কয়েন প্যাক", pack['price'] as int),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF160F2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${pack['coins']} কয়েন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text(pack['bonus'] as String, style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFFF2A85), borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text('৳${pack['price']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
