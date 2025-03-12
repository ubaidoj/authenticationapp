import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:authenticationapp/controllers/authentication_controller.dart';
import 'package:authenticationapp/views/qr_scanner_screen.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final TextEditingController platformController = TextEditingController();
  final TextEditingController authKeyController = TextEditingController();
  final AuthenticatorController controller = Get.find();

  void _addAccount() {
    if (platformController.text.isNotEmpty && authKeyController.text.isNotEmpty) {
      controller.addAccount(platformController.text, authKeyController.text);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Authentication Key", style: TextStyle(fontSize: 16, color: Colors.black)),
            TextField(
              controller: authKeyController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(hintText: "Enter authentication key", hintStyle: TextStyle(color: Colors.black26)),
            ),
            const SizedBox(height: 20),
            const Text("Platform Name", style: TextStyle(fontSize: 16, color: Colors.black)),
            TextField(
              controller: platformController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(hintText: "e.g. Google", hintStyle: TextStyle(color: Colors.black26)),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _addAccount,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Manually"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const QRScannerScreen());
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("Scan QR Code"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
