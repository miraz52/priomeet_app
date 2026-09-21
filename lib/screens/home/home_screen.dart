import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/firebase_service.dart';
import 'package:priomeet_app/services/call_signaling_service.dart';
import 'package:priomeet_app/screens/call/video_call_screen.dart';
import 'package:priomeet_app/screens/wallet/wallet_screen.dart';
import 'package:priomeet_app/screens/support_screen.dart';
import 'package:priomeet_app/screens/vip/vip_screen.dart';
import 'package:priomeet_app/screens/chat/chat_detail_screen.dart';
import 'package:priomeet_app/screens/wallet/host_earnings_screen.dart';
import 'package:priomeet_app/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _activeSubTab = 'Popular';
  StreamSubscription<DocumentSnapshot>? _incomingCallSub;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    AppUserSession.loadSession().then((_) => setState(() {}));
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
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
        content: Text('$callerName আপনার সাথে লাইভ ভিডিও কলে যুক্ত হতে চাইছে।', style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
    _radarController.dispose();
    _incomingCallSub?.cancel();
    super.dispose();
  }

  void _startLiveMatch({String? targetId, String? targetName, String? photoUrl}) async {
    // ফায়ারবেস থেকে রিয়েল কোনো সক্রিয় হোস্ট খুঁজে বের করা
    String actualTargetId = targetId ?? "";
    String actualTargetName = targetName ?? "";

    if (actualTargetId.isEmpty) {
      final activeHosts = await FirebaseFirestore.instance
          .collection('users')
          .where('gender', isEqualTo: 'female')
          .where('isOnline', isEqualTo: true)
          .limit(1)
          .get();

      if (activeHosts.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('বর্তমানে কোনো লাইভ হোস্ট অনলাইনে নেই! অনুগ্রহ করে কিছুক্ষণ পর চেষ্টা করুন।')),
          );
        }
        return;
      }
      final hostData = activeHosts.docs.first.data();
      actualTargetId = activeHosts.docs.first.id;
      actualTargetName = hostData['userName'] ?? 'লাইভ হোস্ট';
    }

    final channel = "prio_${DateTime.now().millisecondsSinceEpoch}";
    CallSignalingService.initiateCall(
      targetUserId: actualTargetId,
      targetUserName: actualTargetName,
      channelName: channel,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => VideoCallScreen(
          channelName: channel,
          remoteUserName: actualTargetName,
          remoteUserRole: "অনলাইন ভেরিফাইড হোস্ট 💖",
          remoteUserPhoto: photoUrl,
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
      _buildPeopleTab(),
      _buildRoomsTab(),
      _buildMessageTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF100D1C),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF8A5CFF),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked_rounded), label: 'Match'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'People'),
            BottomNavigationBarItem(icon: Icon(Icons.roofing_rounded), label: 'Rooms'),
            BottomNavigationBarItem(
              icon: Badge(label: Text('1'), child: Icon(Icons.chat_bubble_rounded)),
              label: 'Message',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Me'),
          ],
        ),
      ),
    );
  }

  // ১. ম্যাচিং স্ক্রিন (১০০% অথেন্টিক)
  Widget _buildMatchTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.1),
          radius: 1.1,
          colors: [Color(0xFF6714A8), Color(0xFF3B0068), Color(0xFF16002A)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())).then((_) => setState(() {})),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/coin_logo.png', width: 22, height: 22, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Color(0xFFFFCC00), size: 20)),
                          const SizedBox(width: 6),
                          Text('${AppUserSession.coins}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.support_agent_rounded, color: Colors.white70), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen()))),
                      IconButton(icon: const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VipScreen()))),
                    ],
                  ),
                ],
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _radarCircle(320 * _radarController.value, 0.15 * (1 - _radarController.value)),
                      _radarCircle(240, 0.2),
                      _radarCircle(160, 0.35),
                      _radarCircle(90, 0.5),
                    ],
                  );
                },
              ),
            ),

            Positioned(
              bottom: 30,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _startLiveMatch(),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD6A4FF), Color(0xFF8B5CF6), Color(0xFF5B8DEF)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Go',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF7E22CE), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.confirmation_num_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('x${AppUserSession.freeMatchesLeft}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(12)),
                        child: const Text('ফ্রি ট্রায়াল', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radarCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(opacity), width: 1.5),
      ),
    );
  }

  // ২. পিপল ট্যাব (১০০% রিয়েল ক্লাউড ফেচিং - নো ডামি হোস্ট)
  Widget _buildPeopleTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _activeSubTab = 'Popular'),
                      child: Text(
                        'Popular',
                        style: TextStyle(
                          color: _activeSubTab == 'Popular' ? Colors.white : Colors.white38,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _activeSubTab = 'New'),
                      child: Text(
                        'New',
                        style: TextStyle(
                          color: _activeSubTab == 'New' ? Colors.white : Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (AppUserSession.gender == 'female' || AppUserSession.isHost)
                  ElevatedButton.icon(
                    onPressed: () {
                      FirebaseService.toggleHostOnline(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('আপনি এখন অনলাইন হোস্ট হিসেবে সক্রিয় আছেন!')),
                      );
                    },
                    icon: const Icon(Icons.sensors, size: 16),
                    label: const Text('Go Live', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getActiveHostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF2A85)));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_tethering_off_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text(
                            'বর্তমানে কোনো লাইভ হোস্ট অনলাইনে নেই',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'যেকোনো মেয়ে হোস্ট অ্যাকাউন্টে প্রবেশ করে "Go Live" করলেই তার আসল প্রোফাইল এখানে স্বয়ংক্রিয়ভাবে ভেসে উঠবে।',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final hostId = data['userId'] ?? docs[i].id;
                    final hostName = data['userName'] ?? 'হোস্ট';
                    final photoUrl = data['photoUrl'] as String?;

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B2E),
                        borderRadius: BorderRadius.circular(16),
                        image: (photoUrl != null && photoUrl.isNotEmpty)
                            ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (photoUrl == null || photoUrl.isEmpty)
                            const Center(child: Icon(Icons.face_3, size: 64, color: Color(0xFFFF2A85))),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                children: [
                                  CircleAvatar(radius: 3, backgroundColor: Colors.white),
                                  SizedBox(width: 4),
                                  Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      hostName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _startLiveMatch(targetId: hostId, targetName: hostName, photoUrl: photoUrl),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF5B8DEF)]),
                                      ),
                                      child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ৩. রুমস ট্যাব
  Widget _buildRoomsTab() {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.roofing_rounded, color: Colors.white30, size: 60),
            SizedBox(height: 12),
            Text('মাল্টি-ইউজার লাইভ ব্রডকাস্ট রুম শীঘ্রই আসছে', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ৪. মেসেঞ্জার ট্যাব (১০০% অথেন্টিক হেল্পডেস্ক ও ফ্রেন্ড চ্যাট)
  Widget _buildMessageTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('মেসেঞ্জার 💌', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen())),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF160F2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFF2A85),
                      child: Icon(Icons.support_agent_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PrioMeet হেল্প ডেস্ক (অফিশিয়াল)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('কয়েন রিচার্জ বা অ্যাকাউন্ট সমস্যার জন্য মেসেজ দিন', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('২৪/৭ লাইভ', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ৫. মি / প্রোফাইল ট্যাব
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
                        Text('ফোন: ${AppUserSession.userPhone}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        if (AppUserSession.userReferralCode.isNotEmpty)
                          Text('রেফারেল কোড: ${AppUserSession.userReferralCode}', style: const TextStyle(color: Color(0xFFFFCC00), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset('assets/images/coin_logo.png', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Color(0xFFFFCC00), size: 18)),
                      const SizedBox(width: 4),
                      Text('${AppUserSession.coins}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (AppUserSession.gender == 'female' || AppUserSession.isHost)
              _menuItem(Icons.diamond_rounded, 'হোস্ট আর্নিং ও পেআউট 💎', () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const HostEarningsScreen()));
              }),
            _menuItem(Icons.account_balance_wallet_rounded, 'ওয়ালেট ও কয়েন রিচার্জ', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())).then((_) => setState(() {}));
            }),
            _menuItem(Icons.workspace_premium_rounded, 'ভিআইপি মেম্বারশিপ পাস 👑', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const VipScreen()));
            }),
            _menuItem(Icons.support_agent_rounded, '২৪/৭ অফিসিয়াল লাইভ সাপোর্ট', () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen()));
            }),
            _menuItem(Icons.logout_rounded, 'লগআউট', () {
              AppUserSession.userId = "";
              AppUserSession.saveSession();
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
