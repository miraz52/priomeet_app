import 'package:flutter/material.dart';

void main() => runApp(const PrioMeetApp());

class PrioMeetApp extends StatelessWidget {
  const PrioMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrioMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0B1E),
        primaryColor: const Color(0xFFE91E63),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LiveHostScreen(),
    WalletScreen(),
    SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1B1435),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videocam_rounded), label: 'লাইভ মিট'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'কয়েন ও রিচার্জ'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'সাপোর্ট'),
        ],
      ),
    );
  }
}

class LiveHostScreen extends StatelessWidget {
  const LiveHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1435),
        elevation: 0,
        title: const Text('PrioMeet লাইভ হোস্ট', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text('৫০০ কয়েন', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('Anika Rahman', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 6),
                          Icon(Icons.verified, color: Color(0xFF00E5FF), size: 22),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('ঢাকা • সফটওয়্যার ইঞ্জিনিয়ার • অনলাইন', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('১:১ ভিডিও কল শুরু হচ্ছে...')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.videocam),
                              label: const Text('১:১ ভিডিও কল (১০০/মিনিট)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('উপহার পাঠানো হয়েছে!')),
                              );
                            },
                            icon: const Icon(Icons.card_giftcard, color: Color(0xFFE91E63), size: 30),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1435),
        title: const Text('কয়েন রিচার্জ গেটওয়ে'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF673AB7)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('আপনার মোট ব্যালেন্স', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('৫০০ কয়েন', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('ম্যানুয়াল পেমেন্ট মেথড (বাংলাদেশ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const ListTile(
              tileColor: Color(0xFF1B1435),
              leading: Icon(Icons.phone_android, color: Colors.pinkAccent),
              title: Text('বিকাশ (পার্সোনাল)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('নম্বর: 01746232340\n১০০ টাকা = ১০০০ কয়েন'),
            ),
            const SizedBox(height: 10),
            const ListTile(
              tileColor: Color(0xFF1B1435),
              leading: Icon(Icons.account_balance, color: Colors.orangeAccent),
              title: Text('নগদ (পার্সোনাল)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('নম্বর: 01859785435\n১০০ টাকা = ১০০০ কয়েন'),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1435),
        title: const Text('অ্যাডমিন সাপোর্ট'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.telegram, size: 80, color: Color(0xFF00E5FF)),
            const SizedBox(height: 12),
            const Text(
              'টেলিগ্রাম রিয়েল-টাইম সাপোর্ট',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'মেসেজ দিলে সরাসরি অ্যাডমিনের পার্সোনাল ইনবক্সে পৌঁছাবে।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                hintText: 'আপনার সমস্যা বা ট্রানজ্যাকশন আইডি লিখুন...',
                filled: true,
                fillColor: Color(0xFF1B1435),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('মেসেজ পাঠানো হয়েছে!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.send),
              label: const Text('মেসেজ পাঠান', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
