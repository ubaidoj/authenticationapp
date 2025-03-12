import 'package:authenticationapp/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountCard extends StatelessWidget {
  final Map<String, String> account;
  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final AuthenticatorController controller = Get.find();

    return GestureDetector(
      onLongPress: () {
        _showOptions(context, controller);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListTile(
          title: Align(
            alignment: Alignment.centerLeft, // ✅ Left-align the text
            child: Text(
              account['platform'] ?? '', // ✅ Correct field name
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, // ✅ Bold font
              ),
            ),
          ),

          subtitle: Text(account['issuer'] ?? 'Unknown'), // ✅ Show issuer name

          trailing: Obx(() {
            String otp =
                controller.otpValues[account['platform'] ?? ""] ?? "------";
            // ✅ Use platform as key

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  otp,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(71, 79, 234, 1),
                  ),
                ),
                const SizedBox(height: 5),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        value: controller.timeLeft.value / 30,
                        backgroundColor: Colors.grey.shade300,
                        color: Color.fromRGBO(71, 79, 234, 1),
                        strokeWidth: 4,
                      ),
                    ),
                    Text(
                      controller.timeLeft.value.toString(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, AuthenticatorController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.push_pin,
                color: Color.fromRGBO(71, 79, 234, 1),
              ),
              title: Text(account["pinned"] == "true"
                  ? "Unpin Account"
                  : "Pin Account"),
              onTap: () {
                controller.togglePin(account["account"]!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Account"),
              onTap: () {
  controller.deleteAccount(account["platform"]!); // ✅ Use platform name
  Navigator.pop(context);
},

            ),
          ],
        ),
      ),
    );
  }
}
