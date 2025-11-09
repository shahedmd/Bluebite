import 'package:bluebite/bottomnav.dart';
import 'package:bluebite/Mobile%20Screen/addreview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'customobject.dart';
import 'responsiveappbar.dart';

class CustomerReviewWeb extends StatefulWidget {
  const CustomerReviewWeb({super.key});

  @override
  State<CustomerReviewWeb> createState() => _CustomerReviewWebState();
}

class _CustomerReviewWebState extends State<CustomerReviewWeb> {
  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),

            centeredContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    Center(
                      child: Text(
                        "We believe in customer satisfaction. Our reviews show that!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No reviews right now 😔'),
                          );
                        }

                        final reviews = snapshot.data!.docs;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300.w,
                            crossAxisSpacing: 20.w,
                            mainAxisSpacing: 20.h,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            var data = reviews[index].data() as Map<String, dynamic>;
                            String title = data['title'] ?? '';
                            String des = data['description'] ?? '';
                            String imgUrl = data['imgUrl'] ?? '';
                            Timestamp timedate = data['timestamp'];
                            DateTime validDate = timedate.toDate();

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 6,
                              shadowColor: Colors.blue.shade100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.r)),
                                    child: imgUrl.isNotEmpty
                                        ? SizedBox(
                                            height: 140.h,
                                            child: Image.network(
                                              imgUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            height: 140.h,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40.sp,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.r),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: themeColor,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(des, style: TextStyle(fontSize: 12.sp)),
                                        SizedBox(height: 6.h),
                                        Text(
                                          "Date: $validDate",
                                          style: TextStyle(
                                            color: themeColor,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        InkWell(
                                          onTap: () {
                                            Get.dialog(ReviewDialog());
                                          },
                                          borderRadius: BorderRadius.circular(30.r),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.r),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF1976D2),
                                                  Color(0xFF42A5F5),
                                                ],
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "View Review",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 100.h),
            BlueBiteBottomNavbar(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(ReviewDialog());
        },
        backgroundColor: themeColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
