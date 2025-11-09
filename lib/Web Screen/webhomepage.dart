import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bottomnav.dart';
import 'customobject.dart';
import 'responsiveappbar.dart';

class WebHomepage extends StatefulWidget {
  const WebHomepage({super.key});

  @override
  State<WebHomepage> createState() => _WebHomepageState();
}

class _WebHomepageState extends State<WebHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
