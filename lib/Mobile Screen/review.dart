// ignore_for_file: deprecated_member_use
import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/addreview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerReview extends StatefulWidget {
  const CustomerReview({super.key});

  @override
  State<CustomerReview> createState() => _CustomerReviewState();
}

class _CustomerReviewState extends State<CustomerReview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(ReviewDialog());
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.add, color: Colors.white),
      ),
      drawer: customDrawer(context),
      appBar: AppBar(
        title: const Text("Customer Review"),
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
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "We belive in customer satisfaction. Our reviews shows that!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            SizedBox(height: 20.h),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('reviews').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No reviews right now 😔'));
                }

                final offers = snapshot.data!.docs;

                return Padding(
                  padding: EdgeInsets.all(10.0.r),
                  child: GridView.builder(
                    itemCount: offers.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.w,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 15.h,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      var data = offers[index].data() as Map<String, dynamic>;
                      String title = data['title'] ?? '';
                      String des = data['description'] ?? '';

                      String imgUrl = data['imgUrl'] ?? '';
                      Timestamp timedate = data['timestamp'];
                      DateTime validDate = timedate.toDate();

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min, //
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r),
                              ),
                              child:
                                  imgUrl.isNotEmpty
                                      ? SizedBox(height: 120.h,
                                        child: Image.network(imgUrl, fit: BoxFit.cover, ))
                                      : Container(
                                        color: Colors.grey[300],
                                        height: 120.h,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40.sp,
                                          ),
                                        ),
                                      ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, //
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(des, style: TextStyle(fontSize: 11.sp)),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "date: $validDate",
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12.sp,
                                    ),
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
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
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
                                    "View Rreview",
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
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
