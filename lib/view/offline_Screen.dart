// import 'package:chatconnect/utils/defaultAppbar.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// class OfflineScreen extends StatelessWidget {
//   const OfflineScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: DefaultAppBar(label: '',
//         // showProfileIcon: true,
//         // leadingImage: Padding(
//         //   padding: const EdgeInsets.only(left: 12.0),
//         //   child: Image.asset('assets/images/DrugDetailsLogo.png', height: 40),
//         // ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi_off, size: 80, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               'You are offline',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Please check your internet connection',
//               style: TextStyle(fontSize: 16),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final result = await Connectivity().checkConnectivity();
//                 if (result != ConnectivityResult.none) {
//                   Navigator.pop(context); // or use a notifier to go back
//                 }
//               },
//               child: Text("Retry"),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
