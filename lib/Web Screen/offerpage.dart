// ignore_for_file: deprecated_member_use

import 'package:bluebite/bottomnav.dart';
import 'package:bluebite/menuitems.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../cartcontroller.dart';
import '../globalvar.dart';
import 'customobject.dart';
import 'responsiveappbar.dart';
import 'webcart.dart';

class OfferPageWeb extends StatefulWidget {
  const OfferPageWeb({super.key});

  @override
  State<OfferPageWeb> createState() => _OfferPageWebState();
}

class _OfferPageWebState extends State<OfferPageWeb> {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CartPageWeb());
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.shop, color: Colors.white),
      ),
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
                    // Optional: you can add a web slider here
                    // customSlide(1, 220), // if you have slider for web
                    SizedBox(height: 20.h),

                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('offers')
                              .where(
                                'validate',
                                isGreaterThanOrEqualTo: Timestamp.fromDate(
                                  today,
                                ),
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No active offers right now 😔'),
                          );
                        }

                        final offers = snapshot.data!.docs;

                        return Wrap(
                          spacing: 20.w,
                          runSpacing: 20.h,
                          alignment: WrapAlignment.center,
                          children:
                              offers.map((offer) {
                                var data = offer.data() as Map<String, dynamic>;
                                String name = data['name'] ?? '';
                                double price = (data['price'] ?? 0).toDouble();
                                String imgUrl = data['imgUrl'] ?? '';
                                Timestamp validate = data['validate'];
                                DateTime validDate = validate.toDate();

                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 250.w,
                                      minWidth: 180.w,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF5F9FF),
                                          Color(0xFFE3F2FD),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // 🖼️ Image section
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.r),
                                          ),
                                          child:
                                              imgUrl.isNotEmpty
                                                  ? Image.network(
                                                    imgUrl,
                                                    height: 300.h,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    height: 300.h,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                        ),

                                        // 🧾 Info section
                                        Padding(
                                          padding: EdgeInsets.all(12.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.sp,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 6.h),
                                              Text(
                                                "৳${price.toStringAsFixed(0)}",
                                                style: TextStyle(
                                                  color: const Color(
                                                    0xFF1976D2,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                "Valid till: ${validDate.day}-${validDate.month}-${validDate.year}",
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15.w,
                                            vertical: 10.h,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              final menuitem = MenuItem(
                                                name: name,
                                                category: "Offer",
                                                price: price,
                                                imgUrl: imgUrl,
                                              );
                                              cartController.addToCart(
                                                menuitem,
                                              );
                                              Get.snackbar(
                                                "Added to Cart",
                                                "$name added successfully!",
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                backgroundColor:
                                                    Colors.blue.shade600,
                                                colorText: Colors.white,
                                                margin: EdgeInsets.all(15.w),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              30.r,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30.r),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF1976D2),
                                                    Color(0xFF42A5F5),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Add to Cart",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
            ),

            SizedBox(height: 650.h),
            BlueBiteBottomNavbar(),
          ],
        ),
      ),
    );
  }
}
