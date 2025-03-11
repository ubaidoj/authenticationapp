import 'package:authenticationapp/views/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../views/homescreen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(auth.authStateChanges());
  }

  Future<void> signUp(String fullName, String email, String password) async {
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }
    try {
      isLoading(true);
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);

      await firestore.collection("users").doc(userCredential.user!.uid).set({
        "fullName": fullName,
        "email": email,
        "uid": userCredential.user!.uid,
      });

      Get.snackbar("Success", "Account Created Successfully");
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred. Please try again.");
    } finally {
      isLoading(false);
    }
  }

  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password are required");
      return;
    }
    try {
      isLoading(true);
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Login Successful");
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred. Please try again.");
    } finally {
      isLoading(false);
    }
  }

  void signOut() async {
    await auth.signOut();
    Get.offAll(() => SignInScreen());
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case "invalid-email":
        return "Invalid email format.";
      case "user-disabled":
        return "This user account has been disabled.";
      case "user-not-found":
      case "wrong-password":
        return "Incorrect email or password.";
      case "email-already-in-use":
        return "This email is already registered.";
      case "weak-password":
        return "Password should be at least 6 characters.";
      default:
        return "Authentication failed. Please try again.";
    }
  }
}
