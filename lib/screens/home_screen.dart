import 'package:flutter/material.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatelessWidget {
  final int balance;
  final Function(int) onDeductCoins;

  const HomeScreen({
    super.key,
    required this.balance,
    required this.onDeductCoins,
  });

  final List<Map<String, String>> hosts = const [
    {
      'name': 'Anika Rahman',
      'city': 'ঢাকা • অনলাইন',
      'imgUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
      'channelId': 'room_anika',
      'bio': 'গল্প করতে পছন্দ করি ❤️'
    },
    {
      'name': 'Nusrat Jahan',
      'city': 'চট্টগ্রাম • অনলাইন',
      'imgUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500',
      'channelId': 'room_nusrat',
      'bio': 'মিষ্টি মিষ্টি আড্ডা হবে 🌸'
    },
    {
      'name': 'Priya Das',
      'city': 'সিলেট • অনলাইন',
      'imgUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500',
      'channelId': 'room_priya',
      'bio': 'লাইভ আড্ডা ও বন্ধুত্ব ✨'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16102E),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.favorite, color: Color(0xFFFF2A85), size: 24),
            SizedBox(width: 8),
            Text(
              'PrioMeet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$balance কয়েন',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hosts.length,
        itemBuilder: (context, index) {
          final host = hosts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(host['imgUrl']!),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Colors.white),
                            SizedBox(width: 4),
                            Text('LIVE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        host['city']!,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    host['name']!,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    host['bio']!,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2A85),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (balance < 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('কল করতে ন্যূনতম ৩ কয়েন লাগবে! ওয়ালেট থেকে রিচার্জ করুন।'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => VideoCallScreen(
                              channelName: host['channelId']!,
                              currentBalance: balance,
                              onDeductCoins: onDeductCoins,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.videocam_rounded, size: 20),
                      label: const Text('১:১ ভিডিও কল (৩ কয়েন/মিনিট)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
