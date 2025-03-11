import 'package:authenticationapp/views/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isFilled = false;

  void checkFields() {
    setState(() {
      isFilled = fullNameController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(checkFields);
    emailController.addListener(checkFields);
    passwordController.addListener(checkFields);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(fullNameController, "Full Name", "Enter your full name", TextInputType.text),
            SizedBox(height: 12),
            _buildTextField(emailController, "Email", "Enter your email", TextInputType.emailAddress),
            SizedBox(height: 12),
            _buildTextField(passwordController, "Password", "Enter your password", TextInputType.visiblePassword, obscureText: true),
            SizedBox(height: 20),

            // Corrected: No Obx here, using isLoading only inside Obx
            Obx(() {
              return authController.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: isFilled
                          ? () {
                              authController.signUp(
                                fullNameController.text.trim(),
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFilled
                            ? Color.fromRGBO(71, 79, 234, 1)
                            : Color.fromRGBO(159, 163, 240, 1),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: isFilled ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
            }),

            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.off(SignInScreen()),
              child: Text(
                "Already have an account? Sign In",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint, TextInputType keyboardType,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black26),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
    );
  }
}
