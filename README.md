# priomeet_app

cat << 'EOF' > lib/main.dart
imprt 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:http/http.dart' as http;

// আপনার Agora App ID (Agora কনসোল থেকে নেওয়া)
const String agoraAppId = "YOUR_AGORA_APP_ID"; 

void main() => runApp(const MaterialApp(
  home: PrioMeetApp(),
  debugShowCheckedModeBanner: false,
));

class PrioMeetApp extends StatefulWidget {
  const PrioMeetApp({super.key});
  @override
  State<PrioMeetApp> createState() => _PrioMeetAppState();
}

class _PrioMeetAppState extends State<PrioMeetApp> {
  int _balance = 500;
  int _navIndex = 0;

  void _addCoins(int coins) {
    setState(() => _balance += coins);
  }

  void _deductCoins(int coins) {
    setState(() => _balance = (_balance - coins).clamp(0, 999999));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HostListScreen(
        balance: _balance,
        onCallStarted: (cost) => _deductCoins(cost),
      ),
      WalletScreen(balance: _balance, onRechargeSuccess: _addCoins),
      const TelegramSupportScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      body: screens[_navIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        backgroundColor: const Color(0xFF16102E),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videocam_rounded), label: 'লাইভ মিট'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'ওয়ালেট'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'সাপোর্ট'),
        ],
      ),
    );
  }
}

// ১:১ রিয়েল-টাইম ভিডিও কল স্ক্রিন (Agora RTC ভিত্তিক)
class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final Function(int) onDeductPerMinute;
  final int currentBalance;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.onDeductPerMinute,
    required this.currentBalance,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  Timer? _billingTimer;
  int _coinsLeft = 0;

  @override
  void initState() {
    super.initState();
    _coinsLeft = widget.currentBalance;
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _localUserJoined = true);
          _startBillingTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() => _remoteUid = null);
          _endCall();
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: '', // আপনার ডায়নামিক RTC টোকেন
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _startBillingTimer() {
    _billingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_coinsLeft >= 100) {
        widget.onDeductPerMinute(100);
        setState(() => _coinsLeft -= 100);
      } else {
        _endCall();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ব্যালেন্স শেষ! কল বন্ধ হয়ে গেছে।')),
        );
      }
    });
  }

  void _endCall() {
    _billingTimer?.cancel();
    _engine.leaveChannel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _billingTimer?.cancel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : const Text('হোস্টের ভিডিও কানেক্ট হচ্ছে...', style: TextStyle(color: Colors.white)),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              height: 160,
              child: _localUserJoined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text('কয়েন বাকি: $_coinsLeft', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: _endCall,
                child: const Icon(Icons.call_end),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// লাইভ হোস্ট তালিকা
class HostListScreen extends StatelessWidget {
  final int balance;
  final Function(int) onCallStarted;

  const HostListScreen({super.key, required this.balance, required this.onCallStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16102E),
        title: const Text('PrioMeet লাইভ হোস্ট'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('$balance কয়েন', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHostCard(
            context,
            name: 'Anika Rahman',
            city: 'ঢাকা • অনলাইন',
            imgUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
            channelId: 'room_anika',
          ),
        ],
      ),
    );
  }

  Widget _buildHostCard(BuildContext context, {required String name, required String city, required String imgUrl, required String channelId}) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(city, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
              onPressed: () {
                if (balance < 100) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কল করতে ন্যূনতম ১০০ কয়েন লাগবে!')));
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => VideoCallScreen(
                      channelName: channelId,
                      currentBalance: balance,
                      onDeductPerMinute: onCallStarted,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.videocam),
              label: const Text('১:১ ভিডিও কল শুরু করুন'),
            )
          ],
        ),
      ),
    );
  }
}

// ওয়ালেট ও বিকাশ/নগদ পেমেন্ট
class WalletScreen extends StatelessWidget {
  final int balance;
  final Function(int) onRechargeSuccess;

  const WalletScreen({super.key, required this.balance, required this.onRechargeSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      appBar: AppBar(backgroundColor: const Color(0xFF16102E), title: const Text('কয়েন ওয়ালেট')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF673AB7)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('মোট ব্যালেন্স', style: TextStyle(color: Colors.white70)),
                Text('$balance কয়েন', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('ম্যানুয়াল পেমেন্ট মেথড:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: const Color(0xFF16102E),
            leading: const Icon(Icons.phone_android, color: Colors.pinkAccent),
            title: const Text('বিকাশ (পার্সোনাল): 01746232340', style: TextStyle(color: Colors.white)),
            subtitle: const Text('১০০ টাকা = ১০০০ কয়েন', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: const Color(0xFF16102E),
            leading: const Icon(Icons.account_balance, color: Colors.orangeAccent),
            title: const Text('নগদ (পার্সোনাল): 01859785435', style: TextStyle(color: Colors.white)),
            subtitle: const Text('১০০ টাকা = ১০০০ কয়েন', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

// টেলিগ্রাম রিলে সাপোর্ট
class TelegramSupportScreen extends StatefulWidget {
  const TelegramSupportScreen({super.key});
  @override
  State<TelegramSupportScreen> createState() => _TelegramSupportScreenState();
}

class _TelegramSupportScreenState extends State<TelegramSupportScreen> {
  final _msgController = TextEditingController();

  Future<void> _sendToTelegram(String text) async {
    const botToken = "YOUR_BOT_TOKEN";
    const chatId = "YOUR_CHAT_ID";
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$text');
    await http.get(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D081E),
      appBar: AppBar(backgroundColor: const Color(0xFF16102E), title: const Text('টেলিগ্রাম সাপোর্ট')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _msgController,
              decoration: const InputDecoration(hintText: 'মেসেজ বা TrxID লিখুন...', filled: true, fillColor: Color(0xFF16102E)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (_msgController.text.isNotEmpty) {
                  _sendToTelegram(_msgController.text);
                  _msgController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অ্যাডমিনের কাছে মেসেজ চলে গেছে!')));
                }
              },
              child: const Text('সেন্ড'),
            )
          ],
        ),
      ),

  }



