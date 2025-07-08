import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/defaultAppbar.dart';
import '../view model/auth_view_model.dart';
import 'login_or_register.dart';
import 'navigation/home_screen.dart';
import 'navigation/profile_screen.dart';
import 'navigation/scanner_screen_stub.dart'
    if (dart.library.io) 'navigation/scanner_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final String currentUserId;
  const BottomNavScreen({super.key, required this.currentUserId});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(currentUserId: widget.currentUserId),
      if (!kIsWeb) QRScannerPage(currentUserId: widget.currentUserId),
      ProfilePage(),
    ];

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);

    // Ensure _currentIndex is not out of range
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: _currentIndex != (_screens.length - 1)
          ? DefaultAppBar(showBackIcon: false, label: "app_name".tr())
          : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index < _screens.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr()),
          if (!kIsWeb)
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner), label: 'scan'.tr()),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'profile'.tr()),
        ],
      ),
    );
  }
}
