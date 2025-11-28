import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/mobilehomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class FreshMobile extends StatelessWidget {
  const FreshMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      backgroundColor: Colors.blue.shade800,
      title: Text("Your order is cancelled"),
    ), 
    drawer: customDrawer(context),
    body: Column(children: [
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
                              onPressed: () => Get.to(() => MobileHomepage()),
                              child: const Text(
                                'Order More Food',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
    ],),
    
    );
  }
}