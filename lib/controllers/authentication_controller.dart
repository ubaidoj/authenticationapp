import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthenticatorController extends GetxController {
  var otpValues = <String, String>{}.obs;
  var timeLeft = 30.obs;

@override
void onInit() {
  super.onInit();
  _loadOtpFromFirestore(); // ✅ Load OTPs from Firestore
  _startOtpTimer();
}


  String _generateOtp() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  void addAccount(String issuer, String account) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String otp = _generateOtp();
  Map<String, dynamic> newAccount = {
    "issuer": issuer,
    "account": account,
    "pinned": false,
    "otp": otp,  // ✅ Save OTP in Firestore
  };

  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts")
        .add(newAccount);

    otpValues[account] = otp; // ✅ Store in memory too
    print("✅ Account added successfully: $newAccount");
  } catch (e) {
    print("❌ Error adding account: $e");
  }
}



  void deleteAccount(String account) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var accountsCollection = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("accounts");

    var query = await accountsCollection.where("account", isEqualTo: account).get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    }

    otpValues.remove(account);
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

  void _startOtpTimer() {
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (timeLeft.value == 0) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      for (var key in otpValues.keys) {
        String newOtp = _generateOtp();
        otpValues[key] = newOtp;

        // ✅ Update OTP in Firestore
        var accountsCollection = FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("accounts");

        var query = await accountsCollection.where("account", isEqualTo: key).get();
        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({"otp": newOtp});
        }
      }
      timeLeft.value = 30;
    } else {
      timeLeft.value--;
    }
  });
}

void _loadOtpFromFirestore() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  var snapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("accounts")
      .get();

  for (var doc in snapshot.docs) {
    String account = doc["account"];
    otpValues[account] = _generateOtp(); // Generate OTP for each account
  }
}
}