import 'package:authenticationapp/theme/app_theme.dart';
import 'package:authenticationapp/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authenticator',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
