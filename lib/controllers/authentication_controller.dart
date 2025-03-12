import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otp/otp.dart';
import 'package:get/get.dart';

class AuthenticatorController extends GetxController {
  var otpValues = <String, String>{}.obs;
  var timeLeft = 30.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAccountsFromFirestore(); // ✅ Load accounts with authentication keys
    _startOtpTimer();
  }

  void addAccount(String platform, String authKey) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  Map<String, dynamic> newAccount = {
    "platform": platform,
    "authKey": authKey,
    "issuer": platform, // ✅ Ensure issuer is saved
    "pinned": false,
  };

  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts")
        .add(newAccount);

    otpValues[platform] = _generateOtp(authKey); // ✅ Use platform name as key
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

  var query = await accountsCollection.where("platform", isEqualTo: platform).get();

  if (query.docs.isNotEmpty) {
    for (var doc in query.docs) {
      await doc.reference.delete(); // ✅ Delete each matching document
    }
    otpValues.remove(platform); // ✅ Remove OTP from the map
    print("✅ Account deleted: $platform");
  } else {
    print("❌ No account found for: $platform");
  }
}


  void _startOtpTimer() {
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (timeLeft.value == 0) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Fetch all stored OTPs and update them
      var snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("accounts")
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String platform = data["platform"] ?? "";
        String authKey = data["authKey"] ?? "";

        if (authKey.isNotEmpty) {
          otpValues[platform] = _generateOtp(authKey);
        }
      }

      timeLeft.value = 30; // ✅ Restart Timer
    } else {
      timeLeft.value--;
    }
  });
}


  void _loadAccountsFromFirestore() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  var snapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("accounts")
      .get();

  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data();
    
    String platform = data["platform"] ?? "Unknown";
    String authKey = data["authKey"] ?? "";
    
    if (authKey.isNotEmpty) {
      otpValues[platform] = _generateOtp(authKey); // ✅ Generate OTP for platform
    }
  }
}


  String _generateOtp(String authKey) {
  return OTP.generateTOTPCodeString(
    authKey,
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // ✅ Convert to seconds
    interval: 30,
    length: 6,
    algorithm: Algorithm.SHA1,
    isGoogle: true, // ✅ Google Authenticator compatibility
  );
}



void togglePin(String account) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  var accountsCollection = FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("accounts");

  var query = await accountsCollection.where("account", isEqualTo: account).get();
  if (query.docs.isNotEmpty) {
    var doc = query.docs.first;
    bool isPinned = doc["pinned"] ?? false;
    await doc.reference.update({"pinned": !isPinned});
  }
}


}
