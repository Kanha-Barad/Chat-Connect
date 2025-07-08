import 'package:flutter/material.dart';

class QRScannerPage extends StatelessWidget {
  final String currentUserId;

  const QRScannerPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('QR Scanner is not available on Web'),
      ),
    );
  }
}
