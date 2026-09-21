import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String hostName;
  final int messageCost;

  const ChatDetailScreen({super.key, required this.hostName, this.messageCost = 0});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<String> _msgs = ['হ্যালো! PrioMeet-এ আপনাকে স্বাগতম। কীভাবে সাহায্য করতে পারি?'];

  void _send() {
    final t = _msgCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() => _msgs.add(t));
    _msgCtrl.clear();
    TelegramService.sendMessage("<b>📩 নতুন মেসেজ (${widget.hostName}):</b>\n👤 ইউজার: ${AppUserSession.userName}\n💬 $t");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: Text(widget.hostName, style: const TextStyle(color: Colors.white, fontSize: 16))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (c, i) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: i == 0 ? const Color(0xFF160F2A) : const Color(0xFFFF2A85), borderRadius: BorderRadius.circular(14)),
                child: Text(_msgs[i], style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF160F2A),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'মেসেজ লিখুন...', border: InputBorder.none))),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF2A85)), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
