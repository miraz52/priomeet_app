import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';

class CallSignalingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ছেলে যখন কল ইনিশিয়েট করবে
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

  // মেয়েদের ফোনে কল আসছে কিনা তা শোনার স্ট্রিম
  static Stream<DocumentSnapshot> listenIncomingCalls() {
    return _db.collection('calls').doc(AppUserSession.userId).snapshots();
  }

  // কল কেটে দেওয়া বা শেষ করা
  static Future<void> endCall(String targetUserId) async {
    try {
      await _db.collection('calls').doc(targetUserId).delete();
    } catch (_) {}
  }
}
