import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authentication_controller.dart';
import '../views/addaccount_screen.dart';
import '../widgets/account_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticatorController controller = Get.put(AuthenticatorController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator'),
      ),
      body: Obx(() {
        if (controller.accounts.isEmpty) {
          return const Center(
            child: Text(
              'No accounts added.\nTap "+" to add an account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.accounts.length,
          itemBuilder: (context, index) {
            return AccountCard(account: controller.accounts[index]);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Get.to(() => const AddAccountScreen());
          controller.loadAccounts(); // 🔄 Reload accounts after adding
        },
      ),
    );
  }
}
