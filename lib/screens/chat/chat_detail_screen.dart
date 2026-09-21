import 'package:priomeet_app/user_session.dart';
import 'package:flutter/material.dart';
import 'package:priomeet_app/screens/home/home_screen.dart';
import 'package:priomeet_app/screens/wallet/wallet_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String hostName;
  final int messageCost; // হোস্টের প্রতি মেসেজের নির্ধারিত ফি

  const ChatDetailScreen({
    super.key,
    required this.hostName,
    this.messageCost = 2,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _freeMessagesLeft = 1; // ১ম মেসেজ ফ্রি
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'হাই সুইটহার্ট! ফ্রি থাকলে একটু ভিডিও কল দাও না 🥰',
      'isMe': false,
      'time': '১২:৩০ PM',
    },
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    // ভিআইপি ইউজারদের জন্য কোনো কয়েন কাটে না
    if (!AppUserSession.isVip) {
      if (_freeMessagesLeft > 0) {
        // ফ্রি মেসেজ খরচ
        _freeMessagesLeft--;
      } else {
        // কয়েন ব্যালেন্স চেক
        if (AppUserSession.coins < widget.messageCost) {
          _showCoinNeededDialog();
          return;
        }
        // ইউজারের ব্যালেন্স থেকে হোস্টের নির্ধারিত মেসেজ ফি কাটা
        setState(() {
          AppUserSession.coins -= widget.messageCost;
        });
      }
    }

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': 'এখন',
      });
      _msgController.clear();
    });

    // মেসেজ লিস্ট নিচে স্ক্রল করা
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCoinNeededDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E143A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('কয়েন প্রয়োজন 💌', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '${widget.hostName}-কে মেসেজ পাঠাতে প্রতি মেসেজে ${widget.messageCost}টি কয়েন প্রয়োজন।\n\nআপনার বর্তমান কয়েন ব্যালেন্স: ${AppUserSession.coins}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('বাতিল', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const WalletScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
            child: const Text('রিচার্জ করুন 💳', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFF2A85).withOpacity(0.3),
              child: const Icon(Icons.face_3, color: Color(0xFFFF2A85), size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hostName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  AppUserSession.isVip ? 'ভিআইপি ফ্রি চ্যাট সক্রিয়' : 'মেসেজ ফি: ${widget.messageCost} কয়েন/মেসেজ',
                  style: const TextStyle(color: Color(0xFFFF2A85), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // নোটিস রিবন
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: const Color(0xFF191133),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 6),
                Text(
                  AppUserSession.isVip
                      ? 'ভিআইপি পাস সক্রিয়: আপনার জন্য সকল মেসেজ সম্পূর্ণ ফ্রি'
                      : _freeMessagesLeft > 0
                          ? 'আপনার জন্য ১ম মেসেজটি সম্পূর্ণ ফ্রি!'
                          : 'প্রতি মেসেজে ${widget.messageCost}টি কয়েন কাটা হবে',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          // মেসেজ হিস্ট্রি
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isMe = m['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF2A85) : const Color(0xFF1E143A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m['text'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text(m['time'], style: const TextStyle(color: Colors.white38, fontSize: 9.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ইনপুট বক্স
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
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'একটি মিষ্টি মেসেজ লিখুন...',
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
