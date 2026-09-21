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
  String _selectedMethod = 'bKash'; // 'bKash' or 'Nagad'
  int _selectedCoins = 250;
  double _calculatedAmount = 100.0; // 250 * 0.40 = 100 Taka

  final TextEditingController _customCoinController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();
  bool _isSubmitting = false;

  final String _bkashNumber = "01746232340";
  final String _nagadNumber = "01859785435";

  // ১ কয়েন = ০.৪০ টাকা (৪০ পয়সা)
  final List<int> _coinOptions = [50, 125, 250, 500, 1250, 2500];

  @override
  void initState() {
    super.initState();
    _customCoinController.text = '250';
  }

  void _onCoinSelection(int coins) {
    setState(() {
      _selectedCoins = coins;
      _calculatedAmount = coins * 0.40;
      _customCoinController.text = coins.toString();
    });
  }

  void _onCustomCoinChanged(String val) {
    final coins = int.tryParse(val.trim()) ?? 0;
    setState(() {
      _selectedCoins = coins;
      _calculatedAmount = coins * 0.40;
    });
  }

  void _submitPayment() async {
    final senderPhone = _senderPhoneController.text.trim();
    final trxId = _trxIdController.text.trim();

    if (_selectedCoins <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক কয়েন পরিমাণ নির্বাচন করুন!')),
      );
      return;
    }

    if (senderPhone.length < 11 || trxId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে প্রেরকের নম্বর এবং TrxID সঠিক দিন!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final alertMsg = """
<b>💰 নতুন কয়েন রিচার্জ আবেদন (১ কয়েন = ৪০ পয়সা)</b>
--------------------------------------
👤 ইউজার: <b>${AppUserSession.userName}</b>
🆔 ইউজার আইডি: <code>${AppUserSession.userId}</code>
📞 প্রেরকের নম্বর: <code>$senderPhone</code>
💳 মেথড: <b>$_selectedMethod</b>
🪙 কয়েনের পরিমাণ: <b>$_selectedCoins কয়েন</b>
💵 টাকার পরিমাণ: <b>৳${_calculatedAmount.toStringAsFixed(0)} টাকা</b> (রেট: ০.৪০ পয়সা)
🧾 TrxID: <code>$trxId</code>
⏰ সময়: <b>${DateTime.now().toLocal()}</b>
--------------------------------------
পেমেন্ট চেক করে অ্যাডমিন প্যানেল থেকে কয়েন যোগ করুন।
""";

    final success = await TelegramService.sendMessage(alertMsg);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        _trxIdController.clear();
        _senderPhoneController.clear();
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: const Color(0xFF1E143A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text('আবেদন সফল হয়েছে!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'আপনার ৳${_calculatedAmount.toStringAsFixed(0)} টাকার (${_selectedCoins} কয়েন) পেমেন্ট তথ্য অ্যাডমিনের টেলিগ্রামে পৌঁছেছে। যাচাই শেষে দ্রুত কয়েন যোগ হবে।',
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
          const SnackBar(content: Text('ইন্টারনেট চেক করুন অথবা সরাসরি সাপোর্টে যোগাযোগ করুন!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeNumber = _selectedMethod == 'bKash' ? _bkashNumber : _nagadNumber;

    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF160F2A),
        elevation: 0,
        title: const Text('কয়েন ওয়ালেট রিচার্জ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ব্যালেন্স ও অফিশিয়াল রেট কার্ড
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6714A8), Color(0xFF1E0C4F)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6714A8).withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
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
                          const Text('বর্তমান কয়েন ব্যালেন্স', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Image.asset('assets/images/coin_logo.png', width: 28, height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Color(0xFFFFCC00), size: 28)),
                              const SizedBox(width: 8),
                              Text('${AppUserSession.coins}', style: const TextStyle(color: Colors.amberAccent, fontSize: 26, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 6),
                              const Text('কয়েন', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                        ),
                        child: const Text('১ কয়েন = ০.৪০ টাকা 🔥', style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text('কয়েন প্যাকেজ নির্বাচন করুন (৪০ পয়সা/কয়েন)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // প্যাকেজ গ্রিড
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: _coinOptions.length,
              itemBuilder: (context, i) {
                final coins = _coinOptions[i];
                final bdt = (coins * 0.40).toStringAsFixed(0);
                final isSelected = _selectedCoins == coins;

                return GestureDetector(
                  onTap: () => _onCoinSelection(coins),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF38104E) : const Color(0xFF160F2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? const Color(0xFFFF2A85) : Colors.white12, width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/coin_logo.png', width: 14, height: 14, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Color(0xFFFFCC00), size: 14)),
                            const SizedBox(width: 4),
                            Text('$coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('৳$bdt টাকা', style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // কাস্টম কয়েন ক্যালকুলেটর ইনপুট
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF160F2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Text('কাস্টম কয়েন:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _customCoinController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'যেমন: ৫০০',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                      onChanged: _onCustomCoinChanged,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('মোট: ৳${_calculatedAmount.toStringAsFixed(0)} টাকা', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text('পেমেন্ট মেথড নির্বাচন করুন', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'bKash'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedMethod == 'bKash' ? const Color(0xFFE2136E).withOpacity(0.2) : const Color(0xFF160F2A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _selectedMethod == 'bKash' ? const Color(0xFFE2136E) : Colors.white12, width: 2),
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
                    onTap: () => setState(() => _selectedMethod = 'Nagad'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedMethod == 'Nagad' ? const Color(0xFFF7941D).withOpacity(0.2) : const Color(0xFF160F2A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _selectedMethod == 'Nagad' ? const Color(0xFFF7941D) : Colors.white12, width: 2),
                      ),
                      child: const Center(
                        child: Text('নগদ (Personal)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // পার্সোনাল নম্বর ও কপি বাটন
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF160F2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_iphone_rounded, color: Color(0xFFFF2A85)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_selectedMethod সেন্ড মানি নম্বর (Personal)', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(activeNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: activeNumber));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$activeNumber নম্বরটি কপি হয়েছে!')));
                    },
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('কপি', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ফর্ম ইনপুট
            const Text('পেমেন্ট কনফার্মেশন ফর্ম', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: _senderPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.send_to_mobile_rounded, color: Color(0xFFFF2A85), size: 20),
                hintText: 'যে নম্বর থেকে টাকা পাঠিয়েছেন (01XXXXXXXXX)',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12.5),
                filled: true,
                fillColor: const Color(0xFF160F2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _trxIdController,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFF2A85), size: 20),
                hintText: 'TrxID (ট্রানজেকশন আইডি)',
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
                onPressed: _isSubmitting ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 5,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('৳${_calculatedAmount.toStringAsFixed(0)} টাকা সাবমিট করুন ($_selectedCoins কয়েন)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('🔒 টাকা পাঠানোর সাথে সাথে অ্যাডমিনের টেলিগ্রামে TrxID চলে যাবে।', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
