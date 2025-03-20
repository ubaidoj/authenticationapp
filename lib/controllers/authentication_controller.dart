import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otp/otp.dart';
import 'package:get/get.dart';

class AuthenticatorController extends GetxController {
  var otpValues = <String, String>{}.obs;
  var timeLeft = 30.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadAccountsFromFirestore();
    _startOtpTimer();
  }

  void addAccount(String platform, String authKey) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> newAccount = {
      "platform": platform,
      "authKey": authKey,
      "issuer": platform,
      "pinned": false,
    };

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("accounts")
          .add(newAccount);

      otpValues[platform] = _generateOtp(authKey);
      print("✅ Account added successfully: $newAccount");
    } catch (e) {
      print("❌ Error adding account: $e");
    }
  }

  void deleteAccount(String platform) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var accountsCollection = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts");

    var query =
        await accountsCollection.where("platform", isEqualTo: platform).get();

    if (query.docs.isNotEmpty) {
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      otpValues.remove(platform);
      print("✅ Account deleted: $platform");
    } else {
      print("❌ No account found for: $platform");
    }
  }

  void _startOtpTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timeLeft.value == 0) {
        await _refreshOtpValues();
        timeLeft.value = 30;
      } else {
        timeLeft.value--;
      }
    });
  }

  Future<void> _refreshOtpValues() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print("🔄 Refreshing OTPs...");

    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts")
        .get();

    var newOtpValues = <String, String>{};

    for (var doc in snapshot.docs) {
      String platform = doc["platform"] ?? "";
      String authKey = doc["authKey"] ?? "";

      if (authKey.isNotEmpty) {
        newOtpValues[platform] = _generateOtp(authKey);
        print("✅ New OTP for $platform: ${newOtpValues[platform]}");
      }
    }

    otpValues.assignAll(newOtpValues); // ✅ Ensures UI updates
    otpValues.refresh();
  }

  void _loadAccountsFromFirestore() async {
    await _refreshOtpValues();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts")
        .get();

    for (var doc in snapshot.docs) {
      String platform = doc["platform"] ?? "Unknown";
      String authKey = doc["authKey"] ?? "";

      if (authKey.isNotEmpty) {
        otpValues[platform] = _generateOtp(authKey);
      }
    }

    otpValues.refresh();
  }

  /// ✅ **Fixed OTP Generation Logic**
  String _generateOtp(String authKey) {
  try {
    String normalizedKey = authKey.replaceAll(" ", "").toUpperCase();

    /// ✅ Corrected timeCounter calculation
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int timeCounter = timestamp ~/ 30;  

    /// ✅ Corrected OTP generation with SHA1 (same as Google Authenticator)
    String otp = OTP.generateTOTPCodeString(
      normalizedKey,
      timeCounter * 30 * 1000,  
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true, // Ensuring Google Authenticator compatibility
    );

    print("🔄 Generating OTP at timeCounter: $timeCounter -> OTP: $otp");
    return otp;
  } catch (e) {
    print("❌ OTP Generation Error: $e");
    return "ERROR";
  }
}


  void togglePin(String platform) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var accountsCollection = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts");

    var query =
        await accountsCollection.where("platform", isEqualTo: platform).get();

    if (query.docs.isNotEmpty) {
      var doc = query.docs.first;
      bool isPinned = doc["pinned"] ?? false;
      await doc.reference.update({"pinned": !isPinned});
    }
  }

  void editPlatformName(String oldPlatform, String newPlatform) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  var accountsCollection = FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("accounts");

  var query = await accountsCollection.where("platform", isEqualTo: oldPlatform).get();

  if (query.docs.isNotEmpty) {
    for (var doc in query.docs) {
      await doc.reference.update({"platform": newPlatform});
    }

    // Update UI
    otpValues[newPlatform] = otpValues.remove(oldPlatform) ?? "------";
    otpValues.refresh();
    print("✅ Platform name updated: $oldPlatform -> $newPlatform");
  } else {
    print("❌ No account found for: $oldPlatform");
  }
}


  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
