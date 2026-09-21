import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';

class CallSignalingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> initiateCall({
    required String targetUserId,
    required String targetUserName,
    required String channelName,
  }) async {
    try {
      await _db.collection('calls').doc(targetUserId).set({
        'callerId': AppUserSession.userId,
        'callerName': AppUserSession.userName,
        'channelName': channelName,
        'status': 'ringing',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Stream<DocumentSnapshot> listenIncomingCalls() {
    return _db.collection('calls').doc(AppUserSession.userId).snapshots();
  }

  static Future<void> endCall(String targetUserId) async {
    try {
      await _db.collection('calls').doc(targetUserId).delete();
    } catch (_) {}
  }
}
