import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priomeet_app/user_session.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> syncUserProfile({String? photoUrl}) async {
    try {
      await _db.collection('users').doc(AppUserSession.userId).set({
        'userId': AppUserSession.userId,
        'userName': AppUserSession.userName,
        'gender': AppUserSession.gender,
        'isHost': AppUserSession.isHost,
        'coins': AppUserSession.coins,
        'isOnline': true,
        'photoUrl': photoUrl ?? '',
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> toggleHostOnline(bool status) async {
    try {
      await _db.collection('users').doc(AppUserSession.userId).update({
        'isOnline': status,
        'lastActive': FieldValue.serverTimestamp(),
      });
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
