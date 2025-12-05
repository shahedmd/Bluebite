import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../bottomnav.dart';
import 'customobject.dart';
import 'responsiveappbar.dart';
import 'webcart.dart';

class WebHomepage extends StatefulWidget {
  const WebHomepage({super.key});

  @override
  State<WebHomepage> createState() => _WebHomepageState();
}

class _WebHomepageState extends State<WebHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(()=> CartPageWeb());
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.shop, color: Colors.white,),
      ),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomNavbar(),

            SizedBox(height: 40.h),
            webCustomSlide(),
            SizedBox(height: 20.h),
            webCustomDot(),
            SizedBox(height: 40.h),

            webTabItems(),
            SizedBox(height: 40.h,),
            tabScreenWeb(),
            SizedBox(height: 100.h,),

            BlueBiteBottomNavbar(),
          ],
        ),
      ),
    );
  }
}
