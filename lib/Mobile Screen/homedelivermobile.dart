// ignore_for_file: deprecated_member_use, avoid_types_as_parameter_names

import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/freshpage.dart';
import 'package:bluebite/Mobile%20Screen/mobilecart.dart';
import 'package:bluebite/Mobile%20Screen/mobilehomepage.dart';
import 'package:bluebite/firebasequery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Homedelivermobile extends StatelessWidget {
  final String selectedtype;
  final String? customerName;
  final String? customerPhone;

  Homedelivermobile({
    super.key,
    required this.selectedtype,
    required this.customerName,
      required this.customerPhone

  });

  final GetxCtrl getxcontroller = GetxCtrl();

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Home Delivery Order",
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: themeColor,
      ),
      drawer: customDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CartPageMobile());
        },
        backgroundColor: themeColor,
        child: const Icon(Icons.shop, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        child: Column(
          children: [
            Text(
              "Order Details",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('orders')
                      .where('orderType', isEqualTo: selectedtype).
                      where('name', isEqualTo : customerName).
                      where('phone', isEqualTo: customerPhone)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red, fontSize: 16.sp),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data!.docs;

                if (allOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders yet!',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }

                
                Map<String, dynamic>? orderToShow;
                String? orderId;

                for (var doc in allOrders) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';

                  if (status == 'delivered') {
                    break; // stop when delivered appears
                  }

                  if (status == 'pending' ||
                      status == 'processing' ||
                      status == 'cancelled') {
                    orderToShow = data;
                    orderId = doc.id;
                    break;
                  }
                }

                if (orderToShow == null) {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50.h),
                        Text(
                          'No pending or cancelled orders!',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () => Get.to(() => MobileHomepage()),
                          child: Text(
                            'Order Food',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final items = List<Map<String, dynamic>>.from(
                  orderToShow['items'] ?? [],
                );
                final status = orderToShow['status'] ?? 'pending';
                final feedback = orderToShow['adminFeedback'] ?? '';
                final customername = orderToShow['name'] ?? '';
                final customerphone = orderToShow['phone'] ?? '';
                final customeraddress = orderToShow['address'] ?? '';
                final Timestamp? ts = orderToShow['timestamp'] as Timestamp?;
                final String formattedDate =
                    ts != null ? dateFormat.format(ts.toDate()) : "No date";

                double total = items.fold(0.0, (sum, item) {
                  final int q = (item['quantity'] ?? 1).toInt();
                  final double p =
                      item['selectedVariant'] != null
                          ? (item['selectedVariant']['price'] ?? 0).toDouble()
                          : (item['price'] ?? 0).toDouble();
                  return sum + (p * q);
                });

                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 8.w,
                      ),
                      shadowColor: Colors.blue.shade100,
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.circleCheck,
                                  color:
                                      status == "cancelled"
                                          ? Colors.red
                                          : themeColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color:
                                        status == "cancelled"
                                            ? Colors.red
                                            : themeColor,
                                  ),
                                ),
                               
                              ],
                            ),
                            
                            
                            if (status == "cancelled")
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.commentSlash,
                                    color: Colors.red.shade700,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      feedback.isNotEmpty
                                          ? 'Reason: $feedback'
                                          : 'No reason provided by admin.',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: 10.h),
                                Text(
                                  'Name: $customername',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: themeColor,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Address: $customeraddress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: themeColor,
                                  ),
                                ),
                                                                SizedBox(width: 6.w),

                                Text(
                                  'Phone: $customerphone',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: themeColor,
                                  ),
                                ),


                            ...items.map((item) {
                              final String name = item['name'] ?? 'Item';
                              final int quantity =
                                  (item['quantity'] ?? 1).toInt();
                              final Map<String, dynamic>? variantMap =
                                  item['selectedVariant'] != null
                                      ? Map<String, dynamic>.from(
                                        item['selectedVariant'],
                                      )
                                      : null;
                              final double unitPrice =
                                  variantMap != null
                                      ? (variantMap['price'] ?? 0).toDouble()
                                      : (item['price'] ?? 0).toDouble();
                              final String variantText =
                                  variantMap != null
                                      ? "(${variantMap['size']})"
                                      : "";
                              final String imgUrl =
                                  item['imgUrl']?.toString() ?? '';

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.h),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Container(
                                        width: 80.w,
                                        height: 80.w,
                                        color: Colors.grey.shade200,
                                        child:
                                            imgUrl.isNotEmpty
                                                ? CachedNetworkImage(
                                                  imageUrl: imgUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (context, url) =>
                                                          Container(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                  errorWidget:
                                                      (
                                                        _,
                                                        __,
                                                        ___,
                                                      ) => const Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$name $variantText",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            "$quantity × $unitPrice BDT",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          Text(
                                            "Subtotal: ${unitPrice * quantity} BDT",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            SizedBox(height: 8.h),
                            Text(
                              'Total: $total BDT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                                fontSize: 16.sp,
                              ),
                            ),

                            SizedBox(height: 10.h),

                            if (status == 'pending')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text('Cancel Order?'),
                                          content: const Text(
                                            'Do you want to cancel this order?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm) {
                                    await getxcontroller.cancelOrder(
                                      orderId!,
                                      orderToShow!,
                                    );
                                    Get.off(() => FreshMobile());
                                    Get.snackbar(
                                      'Success',
                                      'Order cancelled successfully!',
                                      backgroundColor: Colors.green.shade300,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.xmark,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    const Text(
                                      'Cancel Order',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),

                            if (status != "cancelled" && feedback.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.commentDots,
                                      color: Colors.grey.shade800,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        'Feedback: $feedback',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade800,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.clock,
                                  size: 14.sp,
                                  color: themeColor,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Order Time: $formattedDate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15.h),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 60.h,
                        width: 220.w,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () => Get.to(() => MobileHomepage()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.bowlFood,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              const Text(
                                'Order More Food',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
