import 'package:authenticationapp/controllers/auth_controller.dart';
import 'package:authenticationapp/views/addaccount_screen.dart';
import 'package:authenticationapp/widgets/account_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // ✅ Add GlobalKey
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
      key: _scaffoldKey, // ✅ Assign the key to Scaffold
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Menu Icon
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // ✅ Use GlobalKey to open the drawer
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1), // Slight transparency
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: const InputDecoration(
              hintText: "Search Platform...",
              hintStyle: TextStyle(color: Colors.black),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            onChanged: (query) {
              setState(() {
                searchQuery = query.toLowerCase();
              });
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurpleAccent,
              child: Text(
                userInitial,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
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

                // ✅ Remove duplicates using a Set and filter search results
                // ✅ Remove duplicates based on authKey and platform
                Set<String> seenAuthKeys = {};

                var uniqueAccounts = snapshot.data!.docs.where((account) {
                  final data = account.data() as Map<String, dynamic>? ?? {};
                  String platform = data["platform"] ?? "Unknown";
                  String authKey = data["authKey"] ??
                      ""; // Ensure each auth has a unique key

                  // Combine platform and authKey to check uniqueness
                  String uniqueIdentifier = "$platform-$authKey";

                  // Filter search results
                  bool matchesSearch =
                      platform.toLowerCase().contains(searchQuery);

                  if (seenAuthKeys.contains(uniqueIdentifier) ||
                      !matchesSearch) {
                    return false;
                  } else {
                    seenAuthKeys.add(uniqueIdentifier);
                    return true;
                  }
                }).toList();

                return uniqueAccounts.isEmpty
                    ? const Center(child: Text("No matching accounts found."))
                    : ListView(
                        children: uniqueAccounts.map((account) {
                          final data =
                              account.data() as Map<String, dynamic>? ?? {};

                          return AccountCard(account: {
                            "platform": data["platform"] ?? "Unknown",
                            "issuer": data["issuer"] ?? "Unknown",
                            "pinned": (data["pinned"] ?? false).toString(),
                          });
                        }).toList(),
                      );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          await Get.to(() => const AddAccountScreen());
          setState(() {});
        },
      ),
    );
  }
}
