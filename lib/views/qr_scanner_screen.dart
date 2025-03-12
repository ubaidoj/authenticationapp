import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:authenticationapp/controllers/authentication_controller.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticatorController controller = Get.find();
    final MobileScannerController scannerController = MobileScannerController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => _pickQrImage(controller),
          ),
        ],
      ),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty || barcodes.first.rawValue == null) {
            Get.snackbar("Error", "Failed to scan QR code",
                backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }

          String qrData = barcodes.first.rawValue!;
          _handleScannedData(qrData, controller);
        },
      ),
    );
  }

  // ✅ Extract platform name & authentication key from otpauth:// QR
  Map<String, String>? _parseOTPAuth(String qrData) {
  final Uri? uri = Uri.tryParse(qrData);
  if (uri == null || !uri.scheme.contains("otpauth")) return null;

  String platform = uri.queryParameters["issuer"] ?? "Unknown";
  String? authKey = uri.queryParameters["secret"];

  if (authKey == null) return null;

  return {
    "platform": platform,
    "authKey": authKey
  };
}


  // ✅ Handle QR data and add account
  void _handleScannedData(String qrData, AuthenticatorController controller) {
    Map<String, String>? parsedData = _parseOTPAuth(qrData);

    if (parsedData != null) {
      controller.addAccount(parsedData["platform"]!, parsedData["authKey"]!);
      Get.back(); // Close scanner after successful scan
    } else {
      Get.snackbar("Invalid QR Code", "QR code format is incorrect",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ Pick QR code from Gallery and scan it
  Future<void> _pickQrImage(AuthenticatorController controller) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final MobileScannerController scannerController = MobileScannerController();
      final BarcodeCapture? capture = await scannerController.analyzeImage(image.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        String? qrData = capture.barcodes.first.rawValue;
        if (qrData != null) {
          _handleScannedData(qrData, controller);
        } else {
          Get.snackbar("Error", "Invalid QR code image", backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "No QR code found in image", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }
}
