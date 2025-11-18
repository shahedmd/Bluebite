// ignore_for_file: deprecated_member_use

import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/menuitems.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../globalvar.dart';
import 'mobilecart.dart';

class MobileOfferpage extends StatefulWidget {
  const MobileOfferpage({super.key});

  @override
  State<MobileOfferpage> createState() => _MobileOfferpageState();
}

class _MobileOfferpageState extends State<MobileOfferpage> {
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customSlide(1, 180),
                SizedBox(height: 20.h),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
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
                    final double screenWidth = MediaQuery.of(context).size.width;
                    final double horizontalPadding = 10.w * 2; // parent padding
                    final double spacing = 12.w; // Wrap spacing
                    final double cardWidth =
                        (screenWidth - horizontalPadding - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 15.h,
                      children: List.generate(offers.length, (index) {
                        var data = offers[index].data() as Map<String, dynamic>;
                        String name = data['name'] ?? '';
                        double price = (data['price'] ?? 0).toDouble();
                        String imgUrl = data['imgUrl'] ?? '';
                        Timestamp validate = data['validate'];
                        DateTime validDate = validate.toDate();
                    
                        return SizedBox(
                          width: cardWidth,
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
                                // IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16.r)),
                                  child: imgUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          height: 150.h,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 150.h,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
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
                                // DETAILS
                                Padding(
                                  padding: EdgeInsets.all(8.0.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // NAME
                                      Row(
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.tag,
                                            size: 14,
                                            color: Colors.blueAccent,
                                          ),
                                          SizedBox(width: 5.w),
                                          Expanded(
                                            child: Text(
                                              name,
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
                                      // PRICE
                                      Row(
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.moneyBill1,
                                            size: 14,
                                            color: Colors.blueAccent,
                                          ),
                                          SizedBox(width: 5.w),
                                          Expanded(
                                            child: Text(
                                              "৳$price",
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      // VALID DATE
                                      Row(
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.calendarAlt,
                                            size: 14,
                                            color: Colors.blueAccent,
                                          ),
                                          SizedBox(width: 5.w),
                                          Expanded(
                                            child: Text(
                                              "Valid: ${dateFormat.format(validDate)}",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 12.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // ADD TO CART BUTTON
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 8.h),
                                  child: InkWell(
                                    onTap: () {
                                      final menuitem = MenuItem(
                                          name: name,
                                          category: "Offer",
                                          price: price,
                                          imgUrl: imgUrl);
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
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF1976D2),
                                            Color(0xFF42A5F5),
                                          ],
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.cartPlus,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            "Add to Cart",
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
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
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
