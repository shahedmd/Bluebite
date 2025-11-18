// ignore_for_file: deprecated_member_use

import 'package:bluebite/bottomnav.dart';
import 'package:bluebite/Mobile%20Screen/addreview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'customobject.dart';
import 'responsiveappbar.dart';

class CustomerReviewWeb extends StatefulWidget {
  const CustomerReviewWeb({super.key});

  @override
  State<CustomerReviewWeb> createState() => _CustomerReviewWebState();
}

class _CustomerReviewWebState extends State<CustomerReviewWeb> {
  final themeColor = Colors.blue.shade800;
  final dateFormatter = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
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
                      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No reviews right now 😔'));
                        }

                        final reviews = snapshot.data!.docs;

                        return Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Wrap(
                            spacing: 20.w,
                            runSpacing: 20.h,
                            children: reviews.map((review) {
                              final data = review.data() as Map<String, dynamic>;
                              final title = data['title'] ?? '';
                              final des = data['description'] ?? '';
                              final imgUrl = data['imgUrl'] ?? '';
                              final timestamp = (data['timestamp'] as Timestamp).toDate();
                              final formattedDate = dateFormatter.format(timestamp);

                              return Container(
                                constraints: BoxConstraints(maxWidth: 250.w, minWidth: 180.w),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 6,
                                  shadowColor: Colors.blue.shade100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                                        child: imgUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: imgUrl,
                                                height: 250.h,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    const Center(child: CircularProgressIndicator()),
                                                errorWidget: (_, __, ___) => Container(
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Icon(Icons.broken_image, size: 40.sp),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[300],
                                                height: 250.h,
                                                child: Center(
                                                  child: Icon(Icons.broken_image, size: 40.sp),
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
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                                color: themeColor,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(
                                              des,
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(
                                              "Date: $formattedDate",
                                              style: TextStyle(color: themeColor, fontSize: 12.sp),
                                            ),
                                            SizedBox(height: 10.h),
                                            InkWell(
                                              onTap: () => Get.dialog(ReviewDialog()),
                                              borderRadius: BorderRadius.circular(30.r),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30.r),
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const FaIcon(FontAwesomeIcons.eye, color: Colors.white, size: 16),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      "View Review",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 650.h),
            BlueBiteBottomNavbar(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(centeredContent(child: ReviewDialog())),
        backgroundColor: themeColor,
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }
}
