import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:priomeet_app/user_session.dart';
import 'package:priomeet_app/services/agora_config.dart';
import 'package:priomeet_app/screens/wallet/wallet_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String remoteUserName;
  final String remoteUserRole;
  final String? remoteUserPhoto;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.remoteUserName,
    required this.remoteUserRole,
    this.remoteUserPhoto,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  Timer? _callTimer;
  int _secondsRemaining = 60;
  bool _isFreeTrial = false;
  bool _isMuted = false;
  String? _giftAnimationText;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _setupCallTimer();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraConfig.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (mounted) setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (mounted) setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          if (mounted) setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _setupCallTimer() {
    int callCount = AppUserSession.completedCallsCount;
    if (callCount == 0) {
      _secondsRemaining = 60;
      _isFreeTrial = true;
    } else if (callCount == 1) {
      _secondsRemaining = 20;
      _isFreeTrial = true;
    } else if (callCount == 2) {
      _secondsRemaining = 15;
      _isFreeTrial = true;
    } else if (callCount == 3) {
      _secondsRemaining = 10;
      _isFreeTrial = true;
    } else {
      _isFreeTrial = false;
      _secondsRemaining = 60;
      if (AppUserSession.coins < 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showNoCoinsDialog());
        return;
      }
      AppUserSession.coins -= 3;
    }

    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          if (_isFreeTrial) {
            _callTimer?.cancel();
            AppUserSession.completedCallsCount++;
            _showTrialEndedDialog();
          } else {
            if (AppUserSession.coins >= 3) {
              AppUserSession.coins -= 3;
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
          'আপনার ফ্রি ট্রায়ালটি শেষ হয়েছে। কথা চালিয়ে যেতে সাশ্রয়ী কয়েন রিচার্জ করুন।\n\nবর্তমান ব্যালেন্স: ${AppUserSession.coins} কয়েন',
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
          'ভিডিও কল চালিয়ে যেতে প্রতি মিনিটে ৩টি কয়েন প্রয়োজন। এখনই রিচার্জ করে লাইভ থাকুন।',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
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

  void _sendGift(String name, int cost, String icon) {
    if (AppUserSession.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name পাঠাতে $cost কয়েন লাগবে!')));
      return;
    }
    setState(() {
      AppUserSession.coins -= cost;
      _giftAnimationText = "আপনি $icon $name পাঠিয়েছেন!";
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _giftAnimationText = null);
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // রিমোট ব্যবহারকারীর আসল Agora ভিডিও ফিড
          Center(
            child: _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFFFF2A85)),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.remoteUserName}-এর সাথে যুক্ত হচ্ছে...',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text('ক্যামেরা চালু হচ্ছে', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
          ),

          // নিজের সেলফ পিআইপি ক্যামেরা ভিউ
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              width: 110,
              height: 155,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const Center(child: Icon(Icons.person, color: Colors.white54, size: 40)),
              ),
            ),
          ),

          // টাইমার
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
                  Icon(_isFreeTrial ? Icons.timer_outlined : Icons.monetization_on, color: _isFreeTrial ? Colors.greenAccent : Colors.amberAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _isFreeTrial ? 'ফ্রি ট্রায়াল: $_secondsRemaining সে.' : 'পেইড: $_secondsRemaining সে. (৩ কয়েন/মি.)',
                    style: TextStyle(color: _isFreeTrial ? Colors.greenAccent : Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          if (_giftAnimationText != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFF8E00FF)]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(_giftAnimationText!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

          // কন্ট্রোল বাটন
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: IconButton(
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                      _engine.muteLocalAudioStream(_isMuted);
                    },
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.amber.withOpacity(0.25),
                  child: IconButton(
                    icon: const Icon(Icons.card_giftcard_rounded, color: Colors.amberAccent, size: 28),
                    onPressed: () => _sendGift('গোলাপ', 1, '🌹'),
                  ),
                ),
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                    onPressed: () => _engine.switchCamera(),
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      _callTimer?.cancel();
                      AppUserSession.completedCallsCount++;
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
