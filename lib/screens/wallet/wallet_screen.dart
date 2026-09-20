import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WalletScreen extends StatefulWidget {
  final int balance;
  final Function(int) onRechargeSuccess;

  const WalletScreen({
    super.key,
    required this.balance,
    required this.onRechargeSuccess,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _trxController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedMethod = 'bKash';
  bool _isSubmitting = false;

  final String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  final String chatId = "5330021607";

  Future<void> _submitPayment() async {
    final trx = _trxController.text.trim();
    final senderPhone = _phoneController.text.trim();

    if (trx.isEmpty || senderPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে মোবাইল নম্বর এবং TrxID লিখুন!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final message = "🔔 নতুন পেমেন্ট সাবমিশন:\n"
        "💳 মেথড: $_selectedMethod\n"
        "📱 প্রেরক নম্বর: $senderPhone\n"
        "🧾 TrxID: $trx\n"
        "💰 বর্তমান ব্যালেন্স: ${widget.balance} কয়েন";

    final url = Uri.parse(
        'https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=${Uri.encodeComponent(message)}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _trxController.clear();
        _phoneController.clear();
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF16102E),
            title: const Text('পেমেন্ট রিকোয়েস্ট গৃহীত হয়েছে', style: TextStyle(color: Colors.white)),
            content: const Text(
              'আপনার TrxID সফলভাবে অ্যাডমিনের কাছে পৌঁছেছে। ভেরিফাই সম্পন্ন হলে কয়েন যুক্ত হয়ে যাবে।',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ঠিক আছে', style: TextStyle(color: Color(0xFFFF2A85))),
              ),
            ],
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সার্ভার এরর! পুনরায় চেষ্টা করুন।'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _copyNumber(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$number কপি করা হয়েছে!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16102E),
        title: const Text('কয়েন ওয়ালেট ও রিচার্জ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ব্যালেন্স কার্ড
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF7928CA)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('বর্তমান ব্যালেন্স', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.balance} কয়েন',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('১ কয়েন = ৬০ পয়সা | ১ মিনিট ভিডিও কল = ৩ কয়েন',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // অফার প্যাকেজ তালিকা
          const Text('কয়েন প্যাকেজ সমূহ (৬০ পয়সা রেট)',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPackageRow('১০০ কয়েন', '৬০ টাকা'),
          _buildPackageRow('৫০০ কয়েন', '৩০০ টাকা'),
          _buildPackageRow('১,০০০ কয়েন', '৬০০ টাকা'),

          const SizedBox(height: 24),
          const Text('টাকা পাঠানোর নম্বর (Personal Send Money):',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // বিকাশ কার্ড
          Container(
            decoration: BoxDecoration(color: const Color(0xFF16102E), borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.pinkAccent, size: 28),
              title: const Text('বিকাশ (পার্সোনাল)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('01746232340', style: TextStyle(color: Colors.white70, fontSize: 16)),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.pinkAccent),
                onPressed: () => _copyNumber('01746232340'),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // নগদ কার্ড
          Container(
            decoration: BoxDecoration(color: const Color(0xFF16102E), borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.orangeAccent, size: 28),
              title: const Text('নগদ (পার্সোনাল)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('01859785435', style: TextStyle(color: Colors.white70, fontSize: 16)),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.orangeAccent),
                onPressed: () => _copyNumber('01859785435'),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('টাকা পাঠিয়ে TrxID সাবমিট করুন:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // মেথড সিলেক্টর
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('বিকাশ')),
                  selected: _selectedMethod == 'bKash',
                  selectedColor: Colors.pinkAccent,
                  labelStyle: TextStyle(color: _selectedMethod == 'bKash' ? Colors.white : Colors.white70),
                  backgroundColor: const Color(0xFF16102E),
                  onSelected: (val) => setState(() => _selectedMethod = 'bKash'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('নগদ')),
                  selected: _selectedMethod == 'Nagad',
                  selectedColor: Colors.orangeAccent,
                  labelStyle: TextStyle(color: _selectedMethod == 'Nagad' ? Colors.white : Colors.white70),
                  backgroundColor: const Color(0xFF16102E),
                  onSelected: (val) => setState(() => _selectedMethod = 'Nagad'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'যে নম্বর থেকে টাকা পাঠিয়েছেন...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF16102E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _trxController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'TrxID (ট্রানজ্যাকশন আইডি)...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF16102E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2A85),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isSubmitting ? null : _submitPayment,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('কয়েন যোগ করার রিকোয়েস্ট পাঠান',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPackageRow(String coins, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF16102E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(coins, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(price, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
