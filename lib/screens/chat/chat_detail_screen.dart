import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/telegram_service.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final msgCtrl = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      appBar: AppBar(backgroundColor: const Color(0xFF160F2A), title: const Text('হেল্প ডেস্ক')),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('কীভাবে সাহায্য করতে পারি?', style: TextStyle(color: Colors.white54)))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: msgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'মেসেজ...', filled: true, fillColor: Color(0xFF160F2A)))),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF2A85)),
                  onPressed: () {
                    TelegramService.sendMessage("<b>📩 Help:</b> ${AppUserSession.userName}: ${msgCtrl.text}");
                    msgCtrl.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
