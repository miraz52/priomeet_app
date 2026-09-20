import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// আপনার Agora App ID (Agora কনসোল থেকে টেস্ট মোডের App ID)
const String agoraAppId = "YOUR_AGORA_APP_ID";

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final int currentBalance;
  final Function(int) onDeductCoins;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.currentBalance,
    required this.onDeductCoins,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  Timer? _billingTimer;
  late int _coinsLeft;
  int _callSeconds = 0;
  Timer? _callDurationTimer;

  @override
  void initState() {
    super.initState();
    _coinsLeft = widget.currentBalance;
    _initAgora();
  }

  Future<void> _initAgora() async {
    // ক্যামেরা ও অডিও পারমিশন রিকোয়েস্ট
    await [Permission.microphone, Permission.camera].request();

    // Agora রিয়েল-টাইম ইঞ্জিন ইনিশিয়ালাইজেশন
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
          _startBilling();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
          _endCall();
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    // চ্যানেলে জয়েন করা
    await _engine.joinChannel(
      token: '',
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void _startBilling() {
    // কল ডিউরেশন টাইমার
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callSeconds++;
      });
    });

    // প্রতি ৬০ সেকেন্ডে ৩ কয়েন ডিডাকশন টাইমার (১ মিনিট = ৩ কয়েন)
    _billingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_coinsLeft >= 3) {
        setState(() {
          _coinsLeft -= 3;
        });
        widget.onDeductCoins(3);
      } else {
        _billingTimer?.cancel();
        _callDurationTimer?.cancel();
        _endCall();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('আপনার ব্যালেন্স শেষ! কলটি সমাপ্ত হলো।'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _endCall() {
    _billingTimer?.cancel();
    _callDurationTimer?.cancel();
    _engine.leaveChannel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _billingTimer?.cancel();
    _callDurationTimer?.cancel();
    _engine.release();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // রিমোট হোস্টের ভিডিও ভিউ
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
                    children: const [
                      CircularProgressIndicator(color: Color(0xFFFF2A85)),
                      SizedBox(height: 16),
                      Text(
                        'হোস্টের সাথে সংযোগ স্থাপন করা হচ্ছে...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
          ),

          // নিজের সেলফ ক্যামেরা (PiP ভিউ)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF2A85), width: 1.5),
                color: Colors.black54,
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
                    : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          ),

          // লাইভ ব্যালেন্স ও টাইমার হেডার
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossMetaData.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_coinsLeft কয়েন',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(_callSeconds),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // কল কাটার বাটন কন্ট্রোল
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _endCall,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CrossMetaData {
  static const end = CrossAxisAlignment.end;
}
