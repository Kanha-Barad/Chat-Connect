// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import '../view/offline_Screen.dart';
//
// class ConnectivityWrapper extends StatefulWidget {
//   final Widget child;
//
//   const ConnectivityWrapper({required this.child, super.key});
//
//   @override
//   State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
// }
//
// class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
//   late StreamSubscription<ConnectivityResult> _subscription;
//   bool isOffline = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _subscription = Connectivity().onConnectivityChanged.listen((result) {
//       final hasConnection = result != ConnectivityResult.none;
//       if (!hasConnection && !isOffline) {
//         setState(() => isOffline = true);
//       } else if (hasConnection && isOffline) {
//         setState(() => isOffline = false);
//       }
//     });
//
//     _checkInitialConnectivity();
//   }
//
//   Future<void> _checkInitialConnectivity() async {
//     final result = await Connectivity().checkConnectivity();
//     setState(() {
//       isOffline = result == ConnectivityResult.none;
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isOffline ? const OfflineScreen() : widget.child;
//   }
// }
