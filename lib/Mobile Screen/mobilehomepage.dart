import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/mobilecart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../bottomnav.dart';

class MobileHomepage extends StatefulWidget {
  const MobileHomepage({super.key});

  @override
  State<MobileHomepage> createState() => _MobileHomepageState();
}

class _MobileHomepageState extends State<MobileHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      drawer: customDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(()=> CartPageMobile());
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.shop, color: Colors.white,),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h), 
            customSlide(0.7, 180),
        
            SizedBox(height: 10.h),
            customDot(),
        
            SizedBox(height: 20.h),
        
            tabitems(),
            SizedBox(height: 15.h),
        
            tabScreen(),
            SizedBox(height: 40.h,),
            BlueBiteBottomNavbar()
          ],
        ),
      ),
    );
  }
}
