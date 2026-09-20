import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;

  final String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  final String chatId = "5330021607";

  Future<void> _sendMessage() async {
    final msg = _messageController.text.trim();
    final contact = _contactController.text.trim();

    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে মেসেজ লিখুন!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final payload = "📩 PrioMeet নতুন সাপোর্ট মেসেজ:\n"
        "👤 যোগাযোগের নম্বর/নাম: ${contact.isEmpty ? 'দেওয়া হয়নি' : contact}\n"
        "💬 মেসেজ: $msg";

    final url = Uri.parse(
        'https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=${Uri.encodeComponent(payload)}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _messageController.clear();
        _contactController.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মেসেজটি সফলভাবে অ্যাডমিনের কাছে পাঠানো হয়েছে!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মেসেজ পাঠানো যায়নি, পুনরায় চেষ্টা করুন!'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16102E),
        title: const Text('লাইভ সাপোর্ট ও হেল্প', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16102E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.support_agent, color: Color(0xFFFF2A85), size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'যেকোনো সমস্যা, রিচার্জ সমস্যা বা অভিযোগ সরাসরি অ্যাডমিনকে জানান।',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contactController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'আপনার মোবাইল নম্বর বা নাম (ঐচ্ছিক)',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF16102E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'আপনার সমস্যা বা মতামত বিস্তারিত লিখুন...',
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
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('মেসেজ পাঠান',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
