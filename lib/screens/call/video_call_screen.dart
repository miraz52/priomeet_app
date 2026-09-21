import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:priomeet_app/services/agora_config.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String remoteUserName;

  const VideoCallScreen({super.key, required this.channelName, required this.remoteUserName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await [Permission.camera, Permission.microphone].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (c, uid, e) => setState(() => _remoteUid = uid),
        onUserOffline: (c, uid, r) => setState(() => _remoteUid = null),
      ),
    );
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(token: AgoraConfig.token, channelId: widget.channelName, uid: 0, options: const ChannelMediaOptions());
  }

  @override
  void dispose() {
    _engine.leaveChannel();
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
                ? AgoraVideoView(controller: VideoViewController.remote(rtcEngine: _engine, canvas: VideoCanvas(uid: _remoteUid), connection: RtcConnection(channelId: widget.channelName)))
                : Text('${widget.remoteUserName}-এর সাথে লাইভ যুক্ত হচ্ছে...', style: const TextStyle(color: Colors.white)),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: const Icon(Icons.call_end),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
