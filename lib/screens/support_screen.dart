import 'package:priomeet_app/user_session.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:priomeet_app/screens/home/home_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  final String chatId = "5330021607";
  bool _isSending = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'হ্যালো! PrioMeet অফিসিয়াল হেল্পডেস্কে স্বাগতম। আপনার পেমেন্ট, কয়েন বা অ্যাকাউন্ট সংক্রান্ত যেকোনো সমস্যা নিচে বিস্তারিত লিখে পাঠান।',
      'isMe': false,
      'time': 'সাপোর্ট বট',
    },
  ];

  String _selectedIssue = 'পেমেন্ট / কয়েন সমস্যা';
  final List<String> _issues = [
    'পেমেন্ট / কয়েন সমস্যা',
    'ভিআইপি মেম্বারশিপ অ্যাক্টিভেশন',
    'হোস্ট ক্যাশআউট সাপোর্ট',
    'অন্যান্য জিজ্ঞাসা',
  ];

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': 'এখন',
      });
      _isSending = true;
    });

    _messageController.clear();

    // টেলিগ্রামে রিয়েল-টাইম সাপোর্ট রিলে মেসেজ পাঠানো
    final telegramMsg = "📩 *নতুন কাস্টমার সাপোর্ট মেসেজ!*\n\n"
        "👤 ইউজার: ${AppUserSession.userName}\n"
        "🆔 আইডি: `${AppUserSession.userId}`\n"
        "📌 বিষয়: $_selectedIssue\n"
        "💬 মেসেজ: $text\n"
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

      // সফল রেসপন্স সিমুলেশন
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _isSending = false;
          _messages.add({
            'text': 'ধন্যবাদ! আপনার বার্তাটি সরাসরি অ্যাডমিন টিমের কাছে পৌঁছে দেওয়া হয়েছে। অতি দ্রুত আপনার সমস্যা সমাধান করা হবে।',
            'isMe': false,
            'time': 'সাপোর্ট বট',
          });
        });
      });
    } catch (e) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('২৪/৭ লাইভ সাপোর্ট সেন্টার', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('সরাসরি অফিসিয়াল হেল্পডেস্ক', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          // দ্রুত বিষয় নির্বাচন চিপস
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: const Color(0xFF160F2A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _issues.map((issue) {
                  final isSelected = _selectedIssue == issue;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIssue = issue),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF2A85) : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        issue,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // চ্যাট মেসেজ হিস্ট্রি
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isMe = m['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF2A85) : const Color(0xFF1E143A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m['text'], style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.3)),
                        const SizedBox(height: 4),
                        Text(m['time'], style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Color(0xFFFF2A85), strokeWidth: 2),
              ),
            ),

          // মেসেজ ইনপুট বার
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF140F27),
              border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'আপনার সমস্যা বা প্রশ্ন লিখুন...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Color(0xFFFF2A85), size: 26),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
