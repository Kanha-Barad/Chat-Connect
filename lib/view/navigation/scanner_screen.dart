import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../view model/auth_view_model.dart';
import '../chat/chat_screen.dart';

class QRScannerPage extends StatefulWidget {
  final String currentUserId;
  const QRScannerPage({super.key, required this.currentUserId});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (!_isScanned && rawValue != null) {
                  _isScanned = true;

                  final user = await userProvider.getUserByUid(rawValue);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            currentUserId: widget.currentUserId,
                            otherUserId: user!.uid,
                            otherEmail: user!.email,
                            otherUserName: user!.userName)),
                  );
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
