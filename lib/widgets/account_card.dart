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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: ListTile(
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                account['platform']?.isNotEmpty == true
                    ? account['platform']!
                    : account['issuer'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: account['platform']?.isNotEmpty == true &&
                    account['platform'] != account['issuer']
                ? Text(account['issuer'] ?? 'Unknown')
                : null,
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  String platform = account['platform'] ?? "";
                  String otp = controller.otpValues[platform] ?? "------";

                  return Text(
                    otp,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                const SizedBox(height: 5),
                Obx(() {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          value: controller.timeLeft.value / 30,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        controller.timeLeft.value.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, AuthenticatorController controller) {
  TextEditingController editController = TextEditingController(text: account["platform"]);

  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Edit Platform Name"),
            onTap: () {
              Navigator.pop(context);
              _showEditDialog(context, controller, editController);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Account"),
            onTap: () {
              controller.deleteAccount(account["platform"]!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

void _showEditDialog(BuildContext context, AuthenticatorController controller, TextEditingController editController) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Platform Name"),
      content: TextField(
        controller: editController,
        decoration: const InputDecoration(hintText: "Enter new platform name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (editController.text.trim().isNotEmpty) {
              controller.editPlatformName(account["platform"]!, editController.text.trim());
            }
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

}
