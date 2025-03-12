import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/addaccount_screen.dart';
import '../widgets/account_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String userInitial = "";
  String userName = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc["fullName"];
          userInitial = userName.isNotEmpty ? userName[0] : "?";
        });
      }
    }
  }

  @override
Widget build(BuildContext context) {
  User? user = FirebaseAuth.instance.currentUser;

  return Scaffold(
    appBar: AppBar(
      title: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: "Search Platform...",
          border: InputBorder.none,
        ),
        onChanged: (query) {
          setState(() {
            searchQuery = query.toLowerCase();
          });
        },
      ),
      actions: [
        CircleAvatar(
          backgroundColor: const Color.fromRGBO(71, 79, 234, 1),
          child: Text(
            userInitial,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
      ],
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromRGBO(71, 79, 234, 1)),
            child: Text(
              "Authenticator App",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              authController.signOut();
            },
          ),
        ],
      ),
    ),
    
    body: user == null
        ? const Center(child: Text("Please log in"))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("accounts")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No accounts found."));
              }

              return ListView(
                children: snapshot.data!.docs.map((account) {
                  final data = account.data() as Map<String, dynamic>? ?? {};

                  return AccountCard(account: {
                    "platform": data["platform"] ?? "Unknown", // ✅ Corrected field name
                    "issuer": data["issuer"] ?? "Unknown",
                    "pinned": (data["pinned"] ?? false).toString(),
                  });
                }).toList(),
              );
            },
          ),

    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        await Get.to(() => const AddAccountScreen());
        setState(() {}); // ✅ Refresh UI after adding an account
      },
    ),
  );
}
}
