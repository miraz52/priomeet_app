import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/firebase_service.dart';
import 'package:priomeet_app/services/call_signaling_service.dart';
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
  StreamSubscription<DocumentSnapshot>? _incomingCallSub;

  @override
  void initState() {
    super.initState();
    AppUserSession.loadSession().then((_) => setState(() {}));
    _listenIncomingCalls();
  }

  void _listenIncomingCalls() {
    if (AppUserSession.gender == 'female' || AppUserSession.isHost) {
      _incomingCallSub = CallSignalingService.listenIncomingCalls().listen((snap) {
        if (!mounted) return;
        if (snap.exists) {
          final data = snap.data() as Map<String, dynamic>?;
          if (data != null && data['status'] == 'ringing') {
            _showIncomingCallDialog(
              callerName: data['callerName'] ?? 'Prio User',
              channelName: data['channelName'] ?? 'prio_room',
            );
          }
        }
      });
    }
  }

  void _showIncomingCallDialog({required String callerName, required String channelName}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E143A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.ring_volume_rounded, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text('ইনকামিং ভিডিও কল! 📞', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('$callerName আপনার সাথে লাইভ ভিডিও কলে কথা বলতে চায়।', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () {
              CallSignalingService.endCall(AppUserSession.userId);
              Navigator.pop(c);
            },
            child: const Text('কেটে দিন', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              CallSignalingService.endCall(AppUserSession.userId);
              Navigator.pop(c);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => VideoCallScreen(
                    channelName: channelName,
                    remoteUserName: callerName,
                    remoteUserRole: 'ব্যবহারকারী',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('রিসিভ করুন 📹', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _incomingCallSub?.cancel();
    super.dispose();
  }

  void _startLiveMatch({String? targetId, String? targetName}) {
    final channel = "prio_${DateTime.now().millisecondsSinceEpoch}";
    if (targetId != null) {
      CallSignalingService.initiateCall(
        targetUserId: targetId,
        targetUserName: targetName ?? "Host",
        channelName: channel,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => VideoCallScreen(
          channelName: channel,
          remoteUserName: targetName ?? "মাহিরা জাহান",
          remoteUserRole: "অনলাইন হট হোস্ট 🔥",
        ),
      ),
    ).then((_) {
      AppUserSession.saveSession();
      setState(() {});
    });
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

  Widget _buildMatchTab() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.videocam_rounded, color: Color(0xFFFF2A85), size: 28),
                    SizedBox(width: 8),
                    Text('PrioMeet', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())).then((_) => setState(() {})),
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
                    '🎁 ব্যালেন্স: ${AppUserSession.coins} কয়েন • ${AppUserSession.freeMatchesLeft}টি ফ্রি ম্যাচ বাকি',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.2), width: 2)),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.4), width: 2)),
                ),
                GestureDetector(
                  onTap: () => _startLiveMatch(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)]),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.6), blurRadius: 30, spreadRadius: 6),
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
          const Text('১-ক্লিকে রিয়েল হোস্টের সাথে লাইভ কানেক্ট হোন', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('অনলাইন লাইভ হোস্টস 🔥', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                if (AppUserSession.gender == 'female')
                  ElevatedButton.icon(
                    onPressed: () {
                      FirebaseService.toggleHostOnline(true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আপনি এখন অনলাইন হোস্ট হিসেবে সক্রিয় আছেন!')));
                    },
                    icon: const Icon(Icons.sensors, size: 16),
                    label: const Text('Go Live', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.getActiveHostsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_tethering_off, size: 54, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          const Text('বর্তমানে কোনো হোস্ট অনলাইনে নেই', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 6),
                          const Text('মেয়েরা লাইভে আসা মাত্রই এখানে কার্ড ভেসে উঠবে', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final hName = data['userName'] ?? 'Host';
                      final hId = data['userId'] ?? docs[i].id;
                      return GestureDetector(
                        onTap: () => _startLiveMatch(targetId: hId, targetName: hName),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF160F2A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: const Color(0xFFFF2A85).withOpacity(0.2),
                                  child: const Icon(Icons.face_3, size: 45, color: Color(0xFFFF2A85)),
                                ),
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
                                    Text(hName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const Text('অনলাইন হোস্ট 💖', style: TextStyle(color: Colors.white60, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                Navigator.push(context, MaterialPageRoute(builder: (c) => const ChatDetailScreen(hostName: 'নুসরাত জাহান', messageCost: 2)))
                    .then((_) => setState(() {}));
              },
              child: _chatRow('নুসরাত জাহান', 'হাই সুইটহার্ট! ফ্রি থাকলে ভিডিও কল দিও 🥰', 'এখন', true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatRow(String name, String msg, String time, bool unread) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(14)),
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
                Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF160F2A), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFFF2A85),
                    child: Icon(AppUserSession.gender == 'female' ? Icons.face_3 : Icons.face, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppUserSession.userName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        Text('আইডি: ${AppUserSession.userId}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('${AppUserSession.coins} কয়েন', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (AppUserSession.gender == 'female' || AppUserSession.isHost) ...[
              _menuItem(Icons.diamond_rounded, 'হোস্ট ইনকাম ও ক্যাশআউট সেন্টার 💎', () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const HostEarningsScreen()));
              }),
            ],
            _menuItem(Icons.account_balance_wallet_rounded, 'ওয়ালেট ও বিকাশ/নগদ কয়েন রিচার্জ', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())).then((_) => setState(() {}));
            }),
            _menuItem(Icons.workspace_premium_rounded, 'ভিআইপি মেম্বারশিপ পাস 👑', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const VipScreen()));
            }),
            _menuItem(Icons.support_agent_rounded, '২৪/৭ অফিসিয়াল লাইভ সাপোর্ট', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen()));
            }),
            _menuItem(Icons.logout_rounded, 'লগআউট', () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
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
