import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserSession {
  static String userId = "";
  static String userName = "";
  static String userEmail = "";
  static String userPhone = "";
  static String userPassword = "";
  static String userReferralCode = "";
  static String referredBy = "";
  static String gender = "male";
  static bool isHost = false;
  static bool isVip = false;
  static int coins = 15;
  static int freeMatchesLeft = 3;
  static int completedCallsCount = 0;

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? "";
    userName = prefs.getString('userName') ?? "";
    userEmail = prefs.getString('userEmail') ?? "";
    userPhone = prefs.getString('userPhone') ?? "";
    userPassword = prefs.getString('userPassword') ?? "";
    userReferralCode = prefs.getString('userReferralCode') ?? _genRef();
    referredBy = prefs.getString('referredBy') ?? "";
    gender = prefs.getString('gender') ?? "male";
    isHost = (gender == 'female');
    isVip = prefs.getBool('isVip') ?? false;
    coins = prefs.getInt('coins') ?? 15;
    freeMatchesLeft = prefs.getInt('freeMatchesLeft') ?? 3;
    completedCallsCount = prefs.getInt('completedCallsCount') ?? 0;
  }

  static String _genRef() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }

  static Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
    await prefs.setString('userPhone', userPhone);
    await prefs.setString('userPassword', userPassword);
    await prefs.setString('userReferralCode', userReferralCode);
    await prefs.setString('referredBy', referredBy);
    await prefs.setString('gender', gender);
    await prefs.setBool('isVip', isVip);
    await prefs.setInt('coins', coins);
    await prefs.setInt('freeMatchesLeft', freeMatchesLeft);
    await prefs.setInt('completedCallsCount', completedCallsCount);
  }
}
