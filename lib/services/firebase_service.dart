import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> syncUserProfile({String? photoUrl}) async {
    try {
      if (AppUserSession.userId.isEmpty) return;
      await _db.collection('users').doc(AppUserSession.userId).set({
        'userId': AppUserSession.userId,
        'userName': AppUserSession.userName,
        'email': AppUserSession.userEmail,
        'phone': AppUserSession.userPhone,
        'referralCode': AppUserSession.userReferralCode,
        'referredBy': AppUserSession.referredBy,
        'gender': AppUserSession.gender,
        'isHost': AppUserSession.isHost,
        'coins': AppUserSession.coins,
        'isOnline': true,
        'photoUrl': photoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<bool> applyReferralCode(String refCode) async {
    try {
      if (refCode.trim().isEmpty || refCode.trim().toUpperCase() == AppUserSession.userReferralCode) {
        return false;
      }
      final snap = await _db.collection('users').where('referralCode', isEqualTo: refCode.trim().toUpperCase()).limit(1).get();
      if (snap.docs.isNotEmpty) {
        final referrerDoc = snap.docs.first;
        await _db.collection('users').doc(referrerDoc.id).update({
          'coins': FieldValue.increment(10),
        });
        AppUserSession.coins += 10;
        AppUserSession.referredBy = refCode.trim().toUpperCase();
        await AppUserSession.saveSession();
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<void> toggleHostOnline(bool status) async {
    try {
      if (AppUserSession.userId.isNotEmpty) {
        await _db.collection('users').doc(AppUserSession.userId).update({
          'isOnline': status,
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  static Stream<QuerySnapshot> getActiveHostsStream() {
    return _db
        .collection('users')
        .where('gender', isEqualTo: 'female')
        .where('isOnline', isEqualTo: true)
        .snapshots();
  }
}
