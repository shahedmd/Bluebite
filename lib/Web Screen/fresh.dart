import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'responsiveappbar.dart';
import 'webhomepage.dart';



class Freshpage extends StatelessWidget {
  const Freshpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
    CustomNavbar(),
      SizedBox(height: 30.h,),
      Text("Your order is cancelled"),
      SizedBox(height: 15.h,),

      Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 65.h,
                            width: 250.w,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () => Get.to(() => WebHomepage()),
                              child: const Text(
                                'Order More Food',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

    ],),);
  }
}