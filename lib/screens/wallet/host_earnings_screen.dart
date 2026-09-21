import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class HostEarningsScreen extends StatefulWidget {
  const HostEarningsScreen({super.key});

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();
}

class _HostEarningsScreenState extends State<HostEarningsScreen> {
  int _diamonds = 1250; // হোস্টের আর্ন করা ডায়মন্ড ব্যালেন্স
  final double _diamondRate = 0.20; // ১ ডায়মন্ড = ২০ পয়সা (৳০.২০)

  String _payoutMethod = 'bKash'; // 'bKash' or 'Nagad'
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  bool _isWithdrawing = false;

  void _requestCashout() async {
    final amountText = _amountController.text.trim();
    final phone = _numberController.text.trim();

    final requestedDiamonds = int.tryParse(amountText) ?? 0;

    if (requestedDiamonds < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ন্যূনতম ৫০০ ডায়মন্ড (৳১০০ টাকা) ক্যাশআউট করতে হবে!')),
      );
      return;
    }

    if (requestedDiamonds > _diamonds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপনার ব্যালেন্সে পর্যাপ্ত ডায়মন্ড নেই!')),
      );
      return;
    }

    if (phone.length < 11 || !phone.startsWith('01')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক ১১ ডিজিটের বিকাশ/নগদ নম্বর দিন!')),
      );
      return;
    }

    setState(() => _isWithdrawing = true);

    final bdt = requestedDiamonds * _diamondRate;

    final alertMsg = """
<b>💸 নতুন হোস্ট ক্যাশআউট আবেদন! (PrioMeet)</b>
--------------------------------------
👤 হোস্টের নাম: <b>${AppUserSession.userName}</b>
🆔 হোস্ট আইডি: <code>${AppUserSession.userId}</code>
📞 যোগাযোগের ফোন: <code>${AppUserSession.userPhone}</code>
💳 ক্যাশআউট মেথড: <b>$_payoutMethod</b>
📱 ক্যাশআউট নম্বর: <code>$phone</code>
💎 উইথড্র ডায়মন্ড: <b>$requestedDiamonds 💎</b>
💵 প্রদেয় টাকা: <b>৳${bdt.toStringAsFixed(2)} টাকা</b>
⏰ সময়: <b>${DateTime.now().toLocal()}</b>
--------------------------------------
অ্যাকাউন্ট ভেরিফাই করে টাকা পাঠিয়ে দিন।
""";

    final success = await TelegramService.sendMessage(alertMsg);

    setState(() => _isWithdrawing = false);

    if (mounted) {
      if (success) {
        setState(() {
          _diamonds -= requestedDiamonds;
        });
        _amountController.clear();
        _numberController.clear();

        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: const Color(0xFF1E143A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text('ক্যাশআউট আবেদন সফল!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'আপনার ৳${bdt.toStringAsFixed(0)} টাকার ক্যাশআউট রিকোয়েস্ট অ্যাডমিন টিমের কাছে পৌঁছেছে। আগামী ১২ ঘণ্টার মধ্যে আপনার $_payoutMethod নম্বরে টাকা পৌঁছে যাবে।',
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ইন্টারনেট সংযোগ চেক করুন অথবা সরাসরি সাপোর্টে যোগাযোগ করুন!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBdt = (_diamonds * _diamondRate).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF160F2A),
        elevation: 0,
        title: const Text('হোস্ট আর্নিং ও ক্যাশআউট 💎', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // আর্নিং ব্যালেন্স কার্ড
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A00D4), Color(0xFF3B0068), Color(0xFF16002A)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF8A00D4).withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('মোট ডায়মন্ড ব্যালেন্স 💎', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('$_diamonds 💎', style: const TextStyle(color: Colors.cyanAccent, fontSize: 32, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('আনুমানিক আয়: ৳$currentBdt টাকা', style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                        child: const Icon(Icons.diamond_rounded, color: Colors.cyanAccent, size: 40),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 26),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('রেট: ১ ডায়মন্ড = ০.২০ টাকা (২০ পয়সা)', style: TextStyle(color: Colors.white60, fontSize: 11.5)),
                      Text('মিনিমাম: ৫০০ 💎', style: TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('ক্যাশআউট মেথড নির্বাচন করুন', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _payoutMethod = 'bKash'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _payoutMethod == 'bKash' ? const Color(0xFFE2136E).withOpacity(0.2) : const Color(0xFF160F2A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _payoutMethod == 'bKash' ? const Color(0xFFE2136E) : Colors.white12, width: 2),
                      ),
                      child: const Center(
                        child: Text('বিকাশ (Personal)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _payoutMethod = 'Nagad'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _payoutMethod == 'Nagad' ? const Color(0xFFF7941D).withOpacity(0.2) : const Color(0xFF160F2A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _payoutMethod == 'Nagad' ? const Color(0xFFF7941D) : Colors.white12, width: 2),
                      ),
                      child: const Center(
                        child: Text('নগদ (Personal)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text('ক্যাশআউট তথ্য পূরণ করুন', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.diamond_outlined, color: Colors.cyanAccent),
                hintText: 'উইথড্র ডায়মন্ড পরিমাণ (যেমন: ৫০০, ১০০০)',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12.5),
                filled: true,
                fillColor: const Color(0xFF160F2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFFFF2A85)),
                hintText: 'আপনার $_payoutMethod নম্বর (01XXXXXXXXX)',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12.5),
                filled: true,
                fillColor: const Color(0xFF160F2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isWithdrawing ? null : _requestCashout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 5,
                ),
                child: _isWithdrawing
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ক্যাশআউট রিকোয়েস্ট পাঠান 💸', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('🔒 উইথড্র দেওয়ার সাথে সাথে অ্যাডমিন টেলিগ্রামে নোটিফিকেশন পৌঁছে যাবে।', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
