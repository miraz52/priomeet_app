import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:priomeet_app/screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PrioMeetApp());
}

class PrioMeetApp extends StatelessWidget {
  const PrioMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrioMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0818),
        primaryColor: const Color(0xFFFF2A85),
      ),
      home: const LoginScreen(),
    );
  }
}
