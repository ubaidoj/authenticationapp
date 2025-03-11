import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authentication_controller.dart';

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
        color: Colors.black87,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          title: Text(
            account['account'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            account['issuer'] ?? 'Unknown',
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ),
          trailing: Obx(() {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.otpValues[account['account']] ?? '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        value: controller.timeLeft.value / 30,
                        strokeWidth: 3,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      controller.timeLeft.value.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
              leading: const Icon(Icons.push_pin, color: Colors.blueAccent),
              title: Text(account["pinned"] == "true" ? "Unpin Account" : "Pin Account"),
              onTap: () {
                controller.togglePin(account["account"]!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Account"),
              onTap: () {
                controller.deleteAccount(account["account"]!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
