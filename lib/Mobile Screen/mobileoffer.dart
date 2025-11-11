// ignore_for_file: deprecated_member_use

import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/menuitems.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../globalvar.dart';
import 'mobilecart.dart';

class MobileOfferpage extends StatefulWidget {
  const MobileOfferpage({super.key});

  @override
  State<MobileOfferpage> createState() => _MobileOfferpageState();
}

class _MobileOfferpageState extends State<MobileOfferpage> {

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: customDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CartPageMobile());
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.shop, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text("Food Offer's"),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              customSlide(1, 220),
              SizedBox(height: 20.h),

              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('offers')
                        .where(
                          'validate',
                          isGreaterThanOrEqualTo: Timestamp.fromDate(today),
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No active offers right now 😔'),
                    );
                  }

                  final offers = snapshot.data!.docs;

                  return Padding(
  padding: EdgeInsets.all(10.0.r),
  child: LayoutBuilder(
    builder: (context, constraints) {
      return Wrap(
        spacing: 15.w, // space between cards horizontally
        runSpacing: 15.h, // space between rows
        children: List.generate(offers.length, (index) {
          var data = offers[index].data() as Map<String, dynamic>;
          String name = data['name'] ?? '';
          double price = (data['price'] ?? 0).toDouble();
          String imgUrl = data['imgUrl'] ?? '';
          Timestamp validate = data['validate'];
          DateTime validDate = validate.toDate();

          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130.w,
              maxWidth: 180.w,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 5,
              shadowColor: Colors.blue.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: imgUrl.isNotEmpty
                        ? SizedBox(
                            height: 150.h,
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.cover, // keeps consistent aspect ratio
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            height: 150.h,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40.sp,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "৳$price",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Valid till: $validDate",
                          style: TextStyle(
                            color: Colors.black,
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
                      onTap: () {
                        final menuitem = MenuItem(
                          name: name,
                          category: "Offer",
                          price: price,
                          imgUrl: imgUrl,
                        );
                        cartController.addToCart(menuitem);
                        Get.snackbar(
                          "Added to Cart",
                          "$name added successfully!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.shade600,
                          colorText: Colors.white,
                          margin: EdgeInsets.all(10.r),
                        );
                      },
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
                          "Add to Cart",
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
          );
        }),
      );
    },
  ),
);

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
