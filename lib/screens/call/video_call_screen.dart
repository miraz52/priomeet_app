import 'dart:async';
import 'package:flutter/material.dart';
import 'package:priomeet_app/screens/home_screen.dart';
import 'package:priomeet_app/screens/wallet/wallet_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String remoteUserName;
  final String remoteUserRole;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.remoteUserName,
    required this.remoteUserRole,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Timer? _callTimer;
  int _secondsRemaining = 0;
  bool _isFreeTrial = false;
  int _coinsDeductionRate = 3; // প্রতি মিনিটে ৩ কয়েন

  bool _isMuted = false;
  bool _isFrontCamera = true;
  String? _giftAnimationText;

  @override
  void initState() {
    super.initState();
    _setupCallTimer();
  }

  void _setupCallTimer() {
    int callCount = AppUserSession.completedCallsCount;

    // ডিক্রিজিং ট্রায়াল অ্যালগরিদম
    if (callCount == 0) {
      _secondsRemaining = 60; // ১ম কল ৬০ সেকেন্ড
      _isFreeTrial = true;
    } else if (callCount == 1) {
      _secondsRemaining = 20; // ২য় কল ২০ সেকেন্ড
      _isFreeTrial = true;
    } else if (callCount == 2) {
      _secondsRemaining = 15; // ৩য় কল ১৫ সেকেন্ড
      _isFreeTrial = true;
    } else if (callCount == 3) {
      _secondsRemaining = 10; // ৪র্থ কল ১০ সেকেন্ড
      _isFreeTrial = true;
    } else {
      _isFreeTrial = false;
      _secondsRemaining = 60; // পেইড কল ৬০ সেকেন্ড চক্কর
      if (AppUserSession.coins < _coinsDeductionRate) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showNoCoinsDialog());
        return;
      }
      // প্রথম মিনিটের কয়েন কাটা
      AppUserSession.coins -= _coinsDeductionRate;
    }

    // টাইমার শুরু
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          if (_isFreeTrial) {
            // ফ্রি ট্রায়াল শেষ হলে কল অ্যান্ড
            _callTimer?.cancel();
            AppUserSession.completedCallsCount++;
            if (AppUserSession.freeMatchesLeft > 0) {
              AppUserSession.freeMatchesLeft--;
            }
            _showTrialEndedDialog();
          } else {
            // পেইড কলে পুনরায় কয়েন কাটা
            if (AppUserSession.coins >= _coinsDeductionRate) {
              AppUserSession.coins -= _coinsDeductionRate;
              _secondsRemaining = 60;
            } else {
              _callTimer?.cancel();
              _showNoCoinsDialog();
            }
          }
        }
      });
    });
  }

  void _showTrialEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E143A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ফ্রি ট্রায়াল শেষ! ⏳', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'আপনার এই ফ্রি কলটির মেয়াদ শেষ হয়েছে। আরো কথা বলতে এখনই ওয়ালেট থেকে সাশ্রয়ী কয়েন প্যাক রিচার্জ করুন।\n\nবর্তমান কয়েন ব্যালেন্স: ${AppUserSession.coins}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('পরে করব', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const WalletScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
            child: const Text('কয়েন কিনুন 💎', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNoCoinsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E143A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('কয়েন শেষ হয়ে গেছে! 💔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'ভিডিও কল চালিয়ে যেতে প্রতি মিনিটে ৩টি কয়েন প্রয়োজন। অবিলম্বে রিচার্জ করে আবার প্রিয়জনের সাথে যুক্ত হোন।',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('কেটে দিন', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const WalletScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
            child: const Text('এখনই রিচার্জ 💳', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendGift(String giftName, int cost, String icon) {
    if (AppUserSession.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$giftName পাঠাতে $cost কয়েন প্রয়োজন!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      AppUserSession.coins -= cost;
      _giftAnimationText = "আপনি $icon $giftName পাঠিয়েছেন!";
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _giftAnimationText = null);
    });
  }

  void _openGiftSheet() {
    final gifts = [
      {'name': 'গোলাপ', 'cost': 1, 'icon': '🌹'},
      {'name': 'লাভ হার্ট', 'cost': 5, 'icon': '💖'},
      {'name': 'রিং', 'cost': 20, 'icon': '💍'},
      {'name': 'সুপার কার', 'cost': 50, 'icon': '🏎️'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF160F2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('হোস্টকে উপহার পাঠান 🎁', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('ব্যালেন্স: ${AppUserSession.coins} কয়েন', style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: gifts.map((g) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendGift(g['name'] as String, g['cost'] as int, g['icon'] as String);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Text(g['icon'] as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(g['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('${g['cost']} কয়েন', style: const TextStyle(color: Color(0xFFFF2A85), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // রিমোট হোস্ট সিমুলেটেড লাইভ ভিডিও ফিড
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [Color(0xFF4A154B), Color(0xFF07040D)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color(0xFFFF2A85).withOpacity(0.25),
                    child: const Icon(Icons.face_3, size: 90, color: Colors.pinkAccent),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.remoteUserName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.remoteUserRole, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
          ),

          // সেলফ পিআইপি (নিজের ফ্রন্ট ক্যামেরা ভিউ প্রিভিউ)
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              width: 105,
              height: 145,
              decoration: BoxDecoration(
                color: const Color(0xFF1E143A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 45,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),

          // টপ টাইমার ও মোড ইন্ডিকেটর
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isFreeTrial ? Colors.greenAccent : Colors.amberAccent),
              ),
              child: Row(
                children: [
                  Icon(
                    _isFreeTrial ? Icons.timer_outlined : Icons.monetization_on,
                    color: _isFreeTrial ? Colors.greenAccent : Colors.amberAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isFreeTrial
                        ? 'ফ্রি ট্রায়াল: $_secondsRemaining সে.'
                        : 'পেইড কল: $_secondsRemaining সে. (৩ কয়েন/মি.)',
                    style: TextStyle(
                      color: _isFreeTrial ? Colors.greenAccent : Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // গিফট পাঠানোর পর অ্যানিমেটেড ফ্লোটিং ব্যানার
          if (_giftAnimationText != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF2A85).withOpacity(0.6), blurRadius: 20),
                  ],
                ),
                child: Text(
                  _giftAnimationText!,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // বটম ভিডিও কন্ট্রোল বাটন
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // মিউট বাটন
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: IconButton(
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                  ),
                ),

                // গিফট বাটন
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.amber.withOpacity(0.25),
                  child: IconButton(
                    icon: const Icon(Icons.card_giftcard_rounded, color: Colors.amberAccent, size: 28),
                    onPressed: _openGiftSheet,
                  ),
                ),

                // ক্যামেরা ফ্লিপ
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                    onPressed: () => setState(() => _isFrontCamera = !_isFrontCamera),
                  ),
                ),

                // কল কাট বাটন
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      _callTimer?.cancel();
                      AppUserSession.completedCallsCount++;
                      if (AppUserSession.freeMatchesLeft > 0) {
                        AppUserSession.freeMatchesLeft--;
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
