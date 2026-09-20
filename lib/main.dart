import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/support_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFF0D081E),
        primaryColor: const Color(0xFFFF2A85),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int _userCoins = 15; // নতুন ব্যবহারকারীর প্রারম্ভিক কয়েন ব্যালেন্স

  void _deductCoins(int amount) {
    setState(() {
      _userCoins = (_userCoins - amount).clamp(0, 999999);
    });
  }

  void _addCoins(int amount) {
    setState(() {
      _userCoins += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        balance: _userCoins,
        onDeductCoins: _deductCoins,
      ),
      WalletScreen(
        balance: _userCoins,
        onRechargeSuccess: _addCoins,
      ),
      const SupportScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF16102E),
        selectedItemColor: const Color(0xFFFF2A85),
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'হোস্ট',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'ওয়ালেট',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headset_mic),
            label: 'সাপোর্ট',
          ),
        ],
      ),
    );
  }
}
