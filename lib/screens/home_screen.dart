import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:flutter/material.dart';
import 'package:priomeet_app/screens/auth/login_screen.dart';
import 'package:priomeet_app/screens/call/video_call_screen.dart';
import 'package:priomeet_app/screens/wallet/wallet_screen.dart';
import 'package:priomeet_app/screens/support_screen.dart';
import 'package:priomeet_app/screens/vip/vip_screen.dart';
import 'package:priomeet_app/screens/chat/chat_detail_screen.dart';
import 'package:priomeet_app/screens/wallet/host_earnings_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _refresh() {
    setState(() {});
  }

  void _startLiveMatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => VideoCallScreen(
          channelName: "prio_match_${DateTime.now().millisecondsSinceEpoch}",
          remoteUserName: "মাহিরা জাহান",
          remoteUserRole: "অনলাইন হট হোস্ট 🔥",
        ),
      ),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildMatchTab(),
      _buildDiscoverTab(),
      _buildMessageTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0818),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF140F27),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF2A85),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.flash_on_rounded), label: 'ম্যাচিং'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'ডিসকভার'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'মেসেজ'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'প্রোফাইল'),
          ],
        ),
      ),
    );
  }

  // ১. ম্যাচ ট্যাব (পালসিং রাডার)
  Widget _buildMatchTab() {
    return SafeArea(
      child: Column(
        children: [
          // টপ বার ও কয়েন ইন্ডিকেটর
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.videocam_rounded, color: Color(0xFFFF2A85), size: 28),
                    const SizedBox(width: 8),
                    const Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())).then((_) => _refresh()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 16),
                        const SizedBox(width: 4),
                        Text('${AppUserSession.coins} কয়েন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ওয়েলকাম বোনাস ব্যানার ব্যাজ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, color: Colors.amberAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎁 ওয়েলকাম গিফট: +${AppUserSession.coins} কয়েন ও ${AppUserSession.freeMatchesLeft}টি ফ্রি ম্যাচ সক্রিয়!',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // সেন্ট্রাল রাডার অ্যানিমেশন ও স্টার্ট বাটন
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.2), width: 2),
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.4), width: 2),
                  ),
                ),
                GestureDetector(
                  onTap: _startLiveMatch,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2A85).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_call_rounded, color: Colors.white, size: 42),
                        SizedBox(height: 2),
                        Text('START', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            '১-ক্লিকে রেন্ডম হোস্টের সাথে লাইভ কানেক্ট হোন',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'ফ্রি ম্যাচ কার্ড বাকি: ${AppUserSession.freeMatchesLeft} টি',
            style: const TextStyle(color: Color(0xFFFF2A85), fontSize: 12, fontWeight: FontWeight.bold),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // ২. ডিসকভার ট্যাব
  Widget _buildDiscoverTab() {
    final hosts = [
      {'name': 'নুসরাত জাহান', 'age': '21', 'tag': 'মিষ্টি আড্ডা 🥰', 'color': Colors.pinkAccent},
      {'name': 'তানিশা আহমেদ', 'age': '23', 'tag': 'লেট নাইট টক 🌙', 'color': Colors.purpleAccent},
      {'name': 'আয়েশা আক্তার', 'age': '20', 'tag': 'ফ্রেন্ডলি হোস্ট 🌸', 'color': Colors.deepOrangeAccent},
      {'name': 'সাদিয়া ইসলাম', 'age': '22', 'tag': 'ভিআইপি স্পেশাল 💎', 'color': Colors.blueAccent},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('অনলাইন হট হোস্টস 🔥', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                itemCount: hosts.length,
                itemBuilder: (context, i) {
                  final h = hosts[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => VideoCallScreen(
                            channelName: "prio_host_$i",
                            remoteUserName: h['name'] as String,
                            remoteUserRole: h['tag'] as String,
                          ),
                        ),
                      ).then((_) => _refresh());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF160F2A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(Icons.face_3, size: 70, color: (h['color'] as Color).withOpacity(0.7)),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${h['name']}, ${h['age']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(h['tag'] as String, style: const TextStyle(color: Colors.white60, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ৩. মেসেজ ট্যাব
  Widget _buildMessageTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('মেসেঞ্জার 💌', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ChatDetailScreen(hostName: 'নুসরাত জাহান', messageCost: 2)),
                ).then((_) => _refresh());
              },
              child: _chatRow('নুসরাত জাহান', 'হাই সুইটহার্ট! ফ্রি থাকলে ভিডিও কল দিও 🥰', '২ মি. আগে', true),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ChatDetailScreen(hostName: 'তানিশা আহমেদ', messageCost: 1)),
                ).then((_) => _refresh());
              },
              child: _chatRow('তানিশা আহমেদ', 'তোমার সাথে আড্ডা দিয়ে খুব ভালো লাগলো!', '১ ঘণ্টা আগে', false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatRow(String name, String msg, String time, bool unread) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF160F2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFF2A85).withOpacity(0.2),
            child: const Icon(Icons.face_3, color: Color(0xFFFF2A85)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              if (unread) ...[
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFFF2A85), shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ৪. প্রোফাইল ট্যাব
  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ইউজার হেডার কার্ড
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF160F2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFF2A85),
                    child: Icon(AppUserSession.gender == 'female' ? Icons.face_3 : Icons.face, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppUserSession.userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('আইডি: ${AppUserSession.userId} • ${AppUserSession.gender == 'female' ? 'হোস্ট মোড' : 'ইউজার মোড'}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Text(AppUserSession.vipType, style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ভিআইপি ব্যানার
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5E3902), Color(0xFF2B1902)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LUMI VIP CLUB 👑', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('সাপ্তাহিক ও মাসিক পাস আনলক করুন', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VipScreen())).then((_) => _refresh()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                    child: const Text('ভিআইপি কিনুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // মেনু অপশনসমূহ
            if (AppUserSession.gender == 'female' || AppUserSession.isHost) ...[
              _menuItem(Icons.diamond_rounded, 'হোস্ট ইনকাম ও ক্যাশআউট সেন্টার 💎', () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const HostEarningsScreen())).then((_) => _refresh());
              }),
            ],

            _menuItem(Icons.account_balance_wallet_rounded, 'ওয়ালেট ও বিকাশ/নগদ কয়েন রিচার্জ', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())).then((_) => _refresh());
            }),

            _menuItem(Icons.support_agent_rounded, '২৪/৭ অফিসিয়াল লাইভ সাপোর্ট ও হেল্পডেস্ক', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen()));
            }),

            _menuItem(Icons.logout_rounded, 'লগআউট (Logout)', () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (route) => false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF2A85)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }
}

