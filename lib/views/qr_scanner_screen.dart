import 'package:flutter/material.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 100, color: Colors.white54),
            const SizedBox(height: 20),
            const Text(
              "Scan a QR code to add an account",
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate scan (Replace with real scanner later)
                Navigator.pop(context);
              },
              child: const Text("Start Scanning"),
            ),
          ],
        ),
      ),
    );
  }
}
