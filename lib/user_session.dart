import 'package:shared_preferences/shared_preferences.dart';

class AppUserSession {
  static String userId = "User_849201";
  static String userName = "Prio User";
  static bool isGuest = true;
  static String gender = "male"; // 'male' or 'female'
  static bool isHost = false;
  static bool isVip = false;
  static String vipType = "ফ্রি ইউজার";
  static int coins = 15;
  static int freeMatchesLeft = 5;
  static int completedCallsCount = 0;
  static String? userPhoto;

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? "User_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    userName = prefs.getString('userName') ?? "Prio User";
    gender = prefs.getString('gender') ?? "male";
    isHost = (gender == 'female');
    isVip = prefs.getBool('isVip') ?? false;
    vipType = prefs.getString('vipType') ?? "ফ্রি ইউজার";
    coins = prefs.getInt('coins') ?? 15;
    freeMatchesLeft = prefs.getInt('freeMatchesLeft') ?? 5;
    completedCallsCount = prefs.getInt('completedCallsCount') ?? 0;
    userPhoto = prefs.getString('userPhoto');
  }

  static Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('userName', userName);
    await prefs.setString('gender', gender);
    await prefs.setBool('isVip', isVip);
    await prefs.setString('vipType', vipType);
    await prefs.setInt('coins', coins);
    await prefs.setInt('freeMatchesLeft', freeMatchesLeft);
    await prefs.setInt('completedCallsCount', completedCallsCount);
    if (userPhoto != null) {
      await prefs.setString('userPhoto', userPhoto!);
    }
  }
}
