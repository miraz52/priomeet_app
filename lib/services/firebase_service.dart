import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> syncUserProfile() async {
    try {
      if (AppUserSession.userId.isEmpty) return;
      await _db.collection('users').doc(AppUserSession.userId).set({
        'userId': AppUserSession.userId,
        'userName': AppUserSession.userName,
        'email': AppUserSession.userEmail,
        'phone': AppUserSession.userPhone,
        'referralCode': AppUserSession.userReferralCode,
        'gender': AppUserSession.gender,
        'isHost': AppUserSession.isHost,
        'coins': AppUserSession.coins,
        'isOnline': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static Stream<QuerySnapshot> getActiveHostsStream() {
    return _db.collection('users').where('gender', isEqualTo: 'female').where('isOnline', isEqualTo: true).snapshots();
  }
}
