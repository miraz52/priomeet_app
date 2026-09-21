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
  String _selectedMethod = 'bKash';
  int _selectedCoins = 250;
  double _calculatedAmount = 100.0;

  final TextEditingController _customCoinController = TextEditingController(text: '250');
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();
  bool _isSubmitting = false;

  final String _bkashNumber = "01746232340";
  final String _nagadNumber = "01859785435";
  final List<int> _coinOptions = [50, 125, 250, 500, 1250, 2500];

  void _onCoinSelection(int coins) {
    setState(() {
      _selectedCoins = coins;
      _calculatedAmount = coins * 0.40;
      _customCoinController.text = coins.toString();
    });
  }

  void _submitPayment() async {
    final phone = _senderPhoneController.text.trim();
    final trx = _trxIdController.text.trim();

    if (phone.length < 11 || trx.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রেরকের নম্বর ও TrxID দিন!')));
      return;
    }

    setState(() => _isSubmitting = true);

    final alert = """
<b>💰 নতুন কয়েন রিচার্জ!</b>
👤 ইউজার: <b>${AppUserSession.userName}</b>
🆔 আইডি: <code>${AppUserSession.userId}</code>
📞 ফোন: <code>$phone</code>
💳 মেথড: <b>$_selectedMethod</b>
🪙 কয়েন: <b>$_selectedCoins কয়েন (৳${_calculatedAmount.toStringAsFixed(0)} টাকা)</b>
🧾 TrxID: <code>$trx</code>
""";

    final ok = await TelegramService.sendMessage(alert);
    setState(() => _isSubmitting = false);

    if (mounted && ok) {
      _senderPhoneController.clear();
      _trxIdController.clear();
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: const Color(0xFF1E143A),
          title: const Text('পেমেন্ট সাবমিট হয়েছে!', style: TextStyle(color: Colors.white)),
          content: Text('আপনার ৳${_calculatedAmount.toStringAsFixed(0)} টাকার (${_selectedCoins} কয়েন) পেমেন্ট তথ্য পাঠানো হয়েছে। দ্রুত কয়েন যুক্ত হবে।', style: const TextStyle(color: Colors.white70)),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(c), child: const Text('ঠিক আছে')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeNum = _selectedMethod == 'bKash' ? _bkashNumber : _nagadNumber;

    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('কয়েন ওয়ালেট', style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6714A8), Color(0xFF1E0C4F)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ব্যালেন্স', style: TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                          Image.asset('assets/images/coin_logo.png', width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Color(0xFFFFCC00))),
                          const SizedBox(width: 8),
                          Text('${AppUserSession.coins}', style: const TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Text('১ কয়েন = ০.৪০ টাকা 🔥', style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('প্যাকেজ নির্বাচন করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.2),
              itemCount: _coinOptions.length,
              itemBuilder: (ctx, i) {
                final coins = _coinOptions[i];
                final bdt = (coins * 0.40).toStringAsFixed(0);
                final isSel = _selectedCoins == coins;
                return GestureDetector(
                  onTap: () => _onCoinSelection(coins),
                  child: Container(
                    decoration: BoxDecoration(color: isSel ? const Color(0xFF38104E) : const Color(0xFF160F2A), borderRadius: BorderRadius.circular(14), border: Border.all(color: isSel ? const Color(0xFFFF2A85) : Colors.white12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$coins কয়েন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('৳$bdt টাকা', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedMethod = 'bKash'),
                    style: ElevatedButton.styleFrom(backgroundColor: _selectedMethod == 'bKash' ? const Color(0xFFE2136E) : const Color(0xFF160F2A)),
                    child: const Text('বিকাশ'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedMethod = 'Nagad'),
                    style: ElevatedButton.styleFrom(backgroundColor: _selectedMethod == 'Nagad' ? const Color(0xFFF7941D) : const Color(0xFF160F2A)),
                    child: const Text('নগদ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(child: Text('$_selectedMethod সেন্ড মানি: $activeNum', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFFFF2A85)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: activeNum));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$activeNum কপি হয়েছে!')));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _senderPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'প্রেরকের মোবাইল নম্বর', hintStyle: TextStyle(color: Colors.white30), filled: true, fillColor: Color(0xFF160F2A)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _trxIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'TrxID (ট্রানজেকশন আইডি)', hintStyle: TextStyle(color: Colors.white30), filled: true, fillColor: Color(0xFF160F2A)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPayment,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text('৳${_calculatedAmount.toStringAsFixed(0)} টাকা সাবমিট করুন ($_selectedCoins কয়েন)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
