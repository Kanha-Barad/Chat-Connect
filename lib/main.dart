import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/web_fcm_service_stub.dart'
    if (dart.library.html) 'services/web_fcm_service.dart';
import 'utils/theme.dart';
import 'view model/auth_view_model.dart';
import 'view/bottom_nav_screen.dart';
import 'view/login_or_register.dart';
import 'view/splash_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode = prefs.getString('selectedLocale');
  final startLocale =
      savedLocaleCode != null ? Locale(savedLocaleCode) : const Locale('en');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Safe on all platforms
  await registerServiceWorker();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('ar')],
      path: 'assets/lang',
      startLocale: startLocale,
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔕 Background message received: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: lightMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool? isLoggedIn;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showSplash = false;
      });
      checkLoginStatus();

      _setupPushNotifications();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null && mounted) {
        print('📩 Foreground notification: ${notification.title}');
        // You can show a snackbar or dialog here
      }
    });
  }

  Future<void> _setupPushNotifications() async {
    final messaging = FirebaseMessaging.instance;

    if (kIsWeb) {
      // Web push
      final settings = await messaging.requestPermission();
      print('🔔 Web Notification Permission: ${settings.authorizationStatus}');

      final token = await messaging.getToken(
        vapidKey:
            'BIsbavOUcGWhPZmmUiwCjPh1m4XekWYNLPU-JHiB3zD3OanJW46XHFCZiHefqGrDchIQm8n6sDSmuWECfhDz6S4',
      );
      print('🌐 Web FCM Token: $token');
    } else if (Platform.isAndroid) {
      // Android push
      final settings = await messaging.requestPermission();
      print(
          '📲 Android Notification Permission: ${settings.authorizationStatus}');

      final token = await messaging.getToken();
      print('🤖 Android FCM Token: $token');
    } else if (Platform.isIOS) {
      // iOS push
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('📱 iOS Notification Permission: ${settings.authorizationStatus}');

      // Retry fetching APNs token (optional)
      String? apnsToken;
      int retries = 0;
      while (apnsToken == null && retries < 5) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await messaging.getAPNSToken();
        retries++;
      }

      if (apnsToken != null) {
        print('📱 APNs Token: $apnsToken');
      } else {
        print('⚠️ Could not get APNs token');
      }

      final token = await messaging.getToken();
      print('📱 iOS FCM Token: $token');
    } else {
      print('❌ Unsupported platform for FCM');
    }
  }

  Future<void> checkLoginStatus() async {
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    final loggedIn = await authProvider.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return const SplashScreen();
    }

    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isLoggedIn!
        ? BottomNavScreen(
            currentUserId:
                Provider.of<AuthViewModel>(context, listen: false).user!.uid,
          )
        : const LoginOrRegisterScreen();
  }
}
