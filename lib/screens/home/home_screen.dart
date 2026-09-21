import 'package:flutter/material.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/screens/call/video_call_screen.dart';
import 'package:priomeet_app/screens/wallet/wallet_screen.dart';
import 'package:priomeet_app/screens/wallet/host_earnings_screen.dart';
import 'package:priomeet_app/screens/vip/vip_screen.dart';
import 'package:priomeet_app/screens/chat/chat_detail_screen.dart';
import 'package:priomeet_app/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    AppUserSession.loadSession().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildRadar(),
      const Center(child: Text('অনলাইন মানুষ', style: TextStyle(color: Colors.white54))),
      const Center(child: Text('লাইভ রুম', style: TextStyle(color: Colors.white54))),
      const ChatDetailScreen(),
      _buildMe(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF07040D),
      body: tabs[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        backgroundColor: const Color(0xFF100D1C),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF2A85),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Match'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'People'),
          BottomNavigationBarItem(icon: Icon(Icons.roofing), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  Widget _buildRadar() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/coin_logo.png', width: 22, height: 22, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Colors.amber)),
              const SizedBox(width: 8),
              Text('${AppUserSession.coins} কয়েন', style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoCallScreen(channelName: 'prio_room', remoteUserName: 'অনলাইন হোস্ট 💖'))).then((_) => setState(() {}));
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8B5CF6)]), boxShadow: [BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.5), blurRadius: 25)]),
              child: const Center(child: Text('GO', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 20),
          Text('ফ্রি ম্যাচ বাকি: ${AppUserSession.freeMatchesLeft}', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMe() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFF2A85), child: Icon(Icons.person, color: Colors.white)),
              title: Text(AppUserSession.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('ব্যালেন্স: ${AppUserSession.coins} কয়েন', style: const TextStyle(color: Colors.amberAccent)),
            ),
            const Divider(color: Colors.white12),
            if (AppUserSession.isHost)
              ListTile(
                leading: const Icon(Icons.diamond, color: Colors.cyanAccent),
                title: const Text('হোস্ট আর্নিং ও পেআউট 💎', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostEarningsScreen())),
              ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Color(0xFFFF2A85)),
              title: const Text('কয়েন রিচার্জ ওয়ালেট', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())).then((_) => setState(() {})),
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amberAccent),
              title: const Text('ভিআইপি মেম্বারশিপ পাস 👑', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VipScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('লগআউট', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                AppUserSession.userId = "";
                AppUserSession.saveSession();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
