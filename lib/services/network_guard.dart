import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkGuard {
  static Future<bool> checkInternet() async {
    final res = await Connectivity().checkConnectivity();
    return res != ConnectivityResult.none;
  }

  static void showNoInternetDialog(BuildContext context, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E143A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('ইন্টারনেট সংযোগ নেই!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'PrioMeet ব্যবহার করতে আপনার ফোনে মোবাইল ডাটা বা ওয়াইফাই কানেকশন চালু করুন।',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              onRetry();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2A85)),
            child: const Text('পুনরায় চেষ্টা করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
