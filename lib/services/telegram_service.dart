import 'package:http/http.dart' as http;

class TelegramService {
  static const String botToken = "8940834785:AAFC0JbrhUxEi8CCzVWwai_iAKDpSTRJ2ok";
  static const String chatId = "5330021607";

  static Future<bool> sendMessage(String text) async {
    try {
      final url = Uri.parse("https://api.telegram.org/bot$botToken/sendMessage");
      final res = await http.post(url, body: {'chat_id': chatId, 'text': text, 'parse_mode': 'HTML'});
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
