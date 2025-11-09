
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Web Screen/webhomepage.dart';
import 'Mobile Screen/mobilehomepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      
      final screenWidth = MediaQuery.of(context).size.width;

      if (screenWidth < 650) {
        Get.offAll(() => MobileHomepage());
      } else {
        Get.offAll(() => const WebHomepage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              "Blue Bite Restaurant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
