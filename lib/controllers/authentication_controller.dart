import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthenticatorController extends GetxController {
  var accounts = <Map<String, String>>[].obs;
  var otpValues = <String, String>{}.obs;
  var timeLeft = 30.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts(); // ✅ Ensure accounts load on app start
    _startOtpTimer();
  }

  // ✅ Generate a random 6-digit OTP
  String _generateOtp() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  // ✅ Add an account and save it persistently
  void addAccount(String issuer, String account) async {
    String otp = _generateOtp();
    accounts.add({"issuer": issuer, "account": account, "pinned": "false"});
    otpValues[account] = otp;
    saveAccounts();
  }

  // ✅ Delete an account and update storage
  void deleteAccount(String account) async {
    accounts.removeWhere((item) => item["account"] == account);
    otpValues.remove(account);
    saveAccounts();
  }

  // ✅ Pin/unpin account and update storage
  void togglePin(String account) {
    int index = accounts.indexWhere((item) => item["account"] == account);
    if (index != -1) {
      accounts[index]["pinned"] = (accounts[index]["pinned"] == "true") ? "false" : "true";
      accounts.sort((a, b) => b["pinned"]!.compareTo(a["pinned"]!));
      saveAccounts();
    }
  }

  // ✅ Save accounts to SharedPreferences
  Future<void> saveAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accounts', jsonEncode(accounts));
  }

  // ✅ Load accounts from SharedPreferences
  Future<void> loadAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('accounts');

    if (data != null && data.isNotEmpty) {
      accounts.value = List<Map<String, String>>.from(jsonDecode(data));
    }
  }

  // 🔄 OTP refresh every 30 seconds
  void _startOtpTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value == 0) {
        for (var account in accounts) {
          otpValues[account['account']!] = _generateOtp();
        }
        timeLeft.value = 30;
      } else {
        timeLeft.value--;
      }
    });
  }
}
