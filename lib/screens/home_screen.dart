import 'package:flutter/material.dart';
import 'video_call_screen.dart';
import 'wallet_screen.dart';
import 'support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LumiMatchTab(),
    const LumiLiveTab(),
    const LumiMessageTab(),
    const LumiProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16122B),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_rounded),
              activeIcon: Icon(Icons.flash_on_rounded, color: Color(0xFFFF2A85), size: 28),
              label: 'ম্যাচ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam_outlined),
              activeIcon: Icon(Icons.videocam_rounded, color: Color(0xFFFF2A85), size: 28),
              label: 'লাইভ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF2A85), size: 28),
              label: 'মেসেজ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, color: Color(0xFFFF2A85), size: 28),
              label: 'প্রোফাইল',
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================================================================
   ট্যাব ১: Lumi রিয়েল-টাইম রাডার ও ১:১ ম্যাচ (1-on-1 Instant Match Tab)
========================================================================= */
class LumiMatchTab extends StatelessWidget {
  const LumiMatchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF2A164D), Color(0xFF0D0A1A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // টপ বার
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Color(0xFFFF2A85), size: 26),
                      SizedBox(width: 8),
                      Text('Lumi Match', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFFF3D00)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('১৫ কয়েন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // রাডার পালসিং সার্কেল
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.2), width: 2),
                    ),
                  ),
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF2A85).withOpacity(0.4), width: 2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const VideoCallScreen(hostName: 'র্যান্ডম লাইভ পার্টনার')),
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF2A85), Color(0xFF9D00FF)],
                        ),
                        boxShadow: [
                          BoxShadow(color: Color(0xFFFF2A85), blurRadius: 25, spreadRadius: 3),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_rounded, color: Colors.white, size: 40),
                          SizedBox(height: 4),
                          Text('START', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text('১-অন-১ লাইভ ভিডিও ম্যাচ শুরু করুন', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('প্রতি মিনিটে ৩ কয়েন • সম্পূর্ণ নিরাপদ ও ব্যক্তিগত', style: TextStyle(color: Colors.white54, fontSize: 12)),

            const Spacer(),

            // কুইক ফিল্টার বাটন (Lumi Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _matchOption(Icons.female_rounded, 'মেয়েদের সাথে', true),
                  _matchOption(Icons.all_inclusive_rounded, 'সবার সাথে', false),
                  _matchOption(Icons.location_on_rounded, 'বাংলাদেশ', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _matchOption(IconData icon, String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF2A85).withOpacity(0.25) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? const Color(0xFFFF2A85) : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? const Color(0xFFFF2A85) : Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

/* =========================================================================
   ট্যাব ২: Lumi লাইভ হোস্ট ও গ্রিড (Live Stream Tab)
========================================================================= */
class LumiLiveTab extends StatelessWidget {
  const LumiLiveTab({super.key});

  final List<Map<String, dynamic>> hosts = const [
    {
      'name': 'নুসরাত জাহান',
      'age': '21',
      'location': 'ঢাকা',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
      'tag': 'মিষ্টি আড্ডা 🌸',
    },
    {
      'name': 'প্রিয়া দাস',
      'age': '20',
      'location': 'চট্টগ্রাম',
      'image': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600',
      'tag': 'গান আর বন্ধুত্ব ✨',
    },
    {
      'name': 'তানিয়া চৌধুরী',
      'age': '22',
      'location': 'সিলেট',
      'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600',
      'tag': 'লেট নাইট টক 🌙',
    },
    {
      'name': 'মেহজাবিন মিলি',
      'age': '19',
      'location': 'রাজশাহী',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
      'tag': 'নতুন বন্ধু চাই 💖',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16122B),
        title: const Text('লাইভ হোস্ট রুম', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: hosts.length,
        itemBuilder: (context, i) {
          final h = hosts[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => VideoCallScreen(hostName: h['name']))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(h['image'], fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2A85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: Colors.white),
                          SizedBox(width: 4),
                          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${h['name']}, ${h['age']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(h['tag'], style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFF2A85),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 16),
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

/* =========================================================================
   ট্যাব ৩: Lumi মেসেঞ্জার ও চ্যাট (Messages Tab)
========================================================================= */
class LumiMessageTab extends StatelessWidget {
  const LumiMessageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16122B),
        title: const Text('মেসেজ ও নোটিফিকেশন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFF2A85),
              child: Icon(Icons.support_agent, color: Colors.white),
            ),
            title: const Text('PrioMeet অফিসিয়াল সাপোর্ট', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('যেকোনো সমস্যা জানাতে এখানে মেসেজ দিন...', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white30),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen())),
          ),
          const Divider(color: Colors.white10),
          _chatItem('নুসরাত জাহান', 'হাই! কল দিচ্ছ না কেন? 🥰', '২ মি. আগে', true),
          _chatItem('প্রিয়া দাস', 'ধন্যবাদ গিফটের জন্য ❤️', '১০ মি. আগে', false),
          _chatItem('সিস্টেম নোটিশ', 'নতুন ইউজার বোনাস হিসেবে ১৫টি ফ্রি কয়েন যোগ হয়েছে!', '১ ঘণ্টা আগে', false),
        ],
      ),
    );
  }

  Widget _chatItem(String name, String lastMsg, String time, bool unread) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple.shade800,
        child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(lastMsg, style: TextStyle(color: unread ? Colors.pinkAccent : Colors.white54, fontSize: 12)),
      trailing: Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    );
  }
}

/* =========================================================================
   ট্যাব ৪: Lumi ইউজার প্রোফাইল ও সেটিংস (Profile/Me Tab)
========================================================================= */
class LumiProfileTab extends StatelessWidget {
  const LumiProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // প্রোফাইল কার্ড
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Color(0xFFFF2A85), Colors.purpleAccent]),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundColor: Color(0xFF281E57),
                            child: Icon(Icons.person, size: 50, color: Colors.white70),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFFF2A85), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('মিরাজ (অ্যাডমিন)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('আইডি: 5330021607 • বাংলাদেশ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ওয়ালেট কুইক কার্ড
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2E1A54), Color(0xFF1E133A)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('আমার কয়েন ব্যালেন্স', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                            SizedBox(width: 6),
                            Text('১৫ কয়েন', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2A85),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('রিচার্জ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // মেনু অপশনস
              _profileOption(Icons.wallet, 'ওয়ালেট ও পেমেন্ট (বিকাশ/নগদ)', () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen()));
              }),
              _profileOption(Icons.support_agent, 'সরাসরি অ্যাডমিন হেল্পলাইন', () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen()));
              }),
              _profileOption(Icons.privacy_tip, 'গোপনীয়তা ও নিরাপত্তা', () {}),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _profileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16122B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF2A85)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
