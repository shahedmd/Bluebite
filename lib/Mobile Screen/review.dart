// ignore_for_file: deprecated_member_use
import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/addreview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CustomerReview extends StatefulWidget {
  const CustomerReview({super.key});

  @override
  State<CustomerReview> createState() => _CustomerReviewState();
}

class _CustomerReviewState extends State<CustomerReview> {
  final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(ReviewDialog()),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      drawer: customDrawer(context),
      appBar: AppBar(
        title: const Text("Customer Reviews"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "We believe in customer satisfaction. See what our customers say!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            SizedBox(height: 20.h),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('reviews')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No reviews available at the moment 😔'),
                  );
                }

                final reviews = snapshot.data!.docs;

                return Wrap(
                  spacing: 15.w,
                  runSpacing: 15.h,
                  children:
                      reviews.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title'] ?? '';
                        final desc = data['description'] ?? '';
                        final imgUrl = data['imgUrl'] ?? '';
                        final Timestamp timestamp = data['timestamp'];
                        final date = timestamp.toDate();

                        return SizedBox(
                          width:
                              (MediaQuery.of(context).size.width / 2) -
                              20.w, // ~2 per row
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 5,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16.r),
                                    ),
                                    child:
                                        imgUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                              imageUrl: imgUrl,
                                              height: 150.h,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) => Container(
                                                    height: 150.h,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        height: 150.h,
                                                        color: Colors.grey[300],
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 40.sp,
                                                          ),
                                                        ),
                                                      ),
                                            )
                                            : Container(
                                              height: 150.h,
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
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // TITLE
                                        Row(
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.heading,
                                              size: 14,
                                              color: Colors.blueAccent,
                                            ),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.sp,
                                                  color: Colors.blue.shade700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),

                                        // DESCRIPTION
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.alignLeft,
                                              size: 14,
                                              color: Colors.blueAccent,
                                            ),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              child: Text(
                                                desc,
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),

                                        // DATE
                                        // DATE
                                        Row(
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.calendarAlt,
                                              size: 14,
                                              color: Colors.blueAccent,
                                            ),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              // Makes text wrap or ellipsis inside card width
                                              child: Text(
                                                dateFormat.format(date),
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 12.sp,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis, // Truncate if too long
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 8.h,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(30.r),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
