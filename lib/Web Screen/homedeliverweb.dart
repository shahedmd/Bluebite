// ignore_for_file: deprecated_member_use, avoid_types_as_parameter_names

import 'package:bluebite/Web%20Screen/responsiveappbar.dart';
import 'package:bluebite/Web%20Screen/webcart.dart';
import 'package:bluebite/Web%20Screen/webhomepage.dart';
import 'package:bluebite/bottomnav.dart';
import 'package:bluebite/firebasequery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'customobject.dart';

class DeliveryOrderWeb extends StatelessWidget {
  final String selectedtype;
  final String? customerName;
  final String? customerPhone;

  const DeliveryOrderWeb({
    super.key,
    required this.selectedtype,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final GetxCtrl getxcontroller = Get.put(GetxCtrl());

    // Get today's start and end time
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CartPageWeb()),
        backgroundColor: themeColor,
        child: const Icon(Icons.shop, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),
            SizedBox(height: 20.h),
            centeredContent(
              child: Text(
                "Home Delivery Order Details",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            centeredContent(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('orders')
                          .where('orderType', isEqualTo: selectedtype)
                          .where('name', isEqualTo: customerName)
                          .where('phone', isEqualTo: customerPhone)
                          .where(
                            'timestamp',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(
                              startOfDay,
                            ),
                          )
                          .where(
                            'timestamp',
                            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
                          )
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
                        child: Column(
                          children: [
                            SizedBox(height: 50.h),
                            Text(
                              'No orders yet today!',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: () => Get.to(() => WebHomepage()),
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
                              child: const Text(
                                'Order Food',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Filter out delivered orders
                    final todaysOrders =
                        allOrders
                            .map(
                              (doc) => {
                                ...doc.data() as Map<String, dynamic>,
                                'id': doc.id,
                              },
                            )
                            .where((order) => order['status'] != 'delivered')
                            .toList();

                    if (todaysOrders.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50.h),
                            Text(
                              'No pending/cancelled orders today!',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: () => Get.to(() => WebHomepage()),
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
                              child: const Text(
                                'Order Food',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children:
                          todaysOrders.map((orderToShow) {
                            final orderId = orderToShow['id'] as String;
                            final items = List<Map<String, dynamic>>.from(
                              orderToShow['items'] ?? [],
                            );
                            final status = orderToShow['status'] ?? 'pending';
                            final feedback = orderToShow['adminFeedback'] ?? '';
                            final customername = orderToShow['name'] ?? '';
                            final customerphone = orderToShow['phone'] ?? '';
                            final customeraddress =
                                orderToShow['address'] ?? '';
                            final Timestamp? ts =
                                orderToShow['timestamp'] as Timestamp?;
                            final String formattedDate =
                                ts != null
                                    ? dateFormat.format(ts.toDate())
                                    : "No date";

                            double total = items.fold(0.0, (sum, item) {
                              final int q = (item['quantity'] ?? 1).toInt();
                              final double p =
                                  item['selectedVariant'] != null
                                      ? (item['selectedVariant']['price'] ?? 0)
                                          .toDouble()
                                      : (item['price'] ?? 0).toDouble();
                              return sum + (p * q);
                            });

                            Color statusColor =
                                status == 'cancelled'
                                    ? Colors.red
                                    : status == 'pending'
                                    ? Colors.orange
                                    : Colors.green;

                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              margin: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 8.w,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // STATUS
                                    Row(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.circleCheck,
                                          color: statusColor,
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Status: $status',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),

                                    // CUSTOMER INFO
                                    // CUSTOMER INFO
                                    Text(
                                      'Customer Info',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    Divider(),
                                    Text(
                                      'Name: $customername',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                    Text(
                                      'Phone: $customerphone',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                    Text(
                                      'Address: $customeraddress',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),

                                    // Show table number if exists
                                    if (orderToShow['tableNo'] != null &&
                                        orderToShow['tableNo']
                                            .toString()
                                            .isNotEmpty)
                                      Text(
                                        'Table No: ${orderToShow['tableNo']}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    SizedBox(height: 12.h),

                                    // ORDER ITEMS
                                    Text(
                                      'Order Items',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    Divider(),
                                    ...items.map((item) {
                                      final String name = item['name'] ?? '';
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
                                              ? (variantMap['price'] ?? 0)
                                                  .toDouble()
                                              : (item['price'] ?? 0).toDouble();
                                      final String variantText =
                                          variantMap != null
                                              ? "(${variantMap['size']})"
                                              : "";
                                      final String imgUrl =
                                          item['imgUrl']?.toString() ?? '';

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
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
                                                              (
                                                                _,
                                                                __,
                                                              ) => Container(
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
                                                                    .broken_image,
                                                              ),
                                                        )
                                                        : const Icon(
                                                          Icons.broken_image,
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
                                                    '$name $variantText',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    '$quantity × $unitPrice BDT',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Subtotal: ${unitPrice * quantity} BDT',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    Divider(),
                                    Text(
                                      'Total: $total BDT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: themeColor,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),

                                    // FEEDBACK
                                    if (status == 'cancelled' &&
                                        feedback.isNotEmpty)
                                      Text(
                                        'Reason: $feedback',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    if (status != 'cancelled' &&
                                        feedback.isNotEmpty)
                                      Text(
                                        'Feedback: $feedback',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    SizedBox(height: 12.h),

                                    // ORDER TIME
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
                                          style: TextStyle(color: themeColor),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),

                                    // CANCEL BUTTON
                                    if (status == 'pending')
                                      SizedBox(
                                        width: 300.w,
                                        child: ElevatedButton.icon(
                                          icon: const FaIcon(
                                            FontAwesomeIcons.xmark,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Cancel Order',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade600,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                          ),
                                          onPressed: () async {
                                            bool confirm = await showDialog(
                                              context: context,
                                              builder:
                                                  (_) => AlertDialog(
                                                    title: const Text(
                                                      'Cancel Order?',
                                                    ),
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
                                                        child: const Text(
                                                          'Yes',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );

                                            if (confirm) {
                                              // Show a loading indicator while cancelling
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (_) => const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              );

                                              try {
                                                // Wait for cancelOrder to finish
                                                await getxcontroller
                                                    .cancelOrder(
                                                      orderId,
                                                      orderToShow,
                                                    );

                                                // Close the loading dialog
                                                Navigator.pop(context);

                                                // Navigate to Freshpage (or DeliveryOrderWeb)
                                                Get.off(
                                                  () => DeliveryOrderWeb(
                                                    selectedtype: selectedtype,
                                                    customerName: customerName,
                                                    customerPhone:
                                                        customerPhone,
                                                  ),
                                                );

                                                // Show success snackbar
                                                Get.snackbar(
                                                  'Success',
                                                  'Order cancelled successfully!',
                                                  backgroundColor:
                                                      Colors.green.shade300,
                                                  colorText: Colors.white,
                                                );
                                              } catch (e) {
                                                Navigator.pop(
                                                  context,
                                                ); // Close loading dialog on error
                                                Get.snackbar(
                                                  'Error',
                                                  'Failed to cancel order.',
                                                  backgroundColor:
                                                      Colors.red.shade300,
                                                  colorText: Colors.white,
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),

                                    SizedBox(height: 12.h),
                                    SizedBox(
                                      width: 300.w,
                                      child: ElevatedButton.icon(
                                        icon: FaIcon(
                                          FontAwesomeIcons.bowlFood,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Order More Food',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: themeColor,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.h,
                                          ),
                                        ),
                                        onPressed:
                                            () => Get.to(() => WebHomepage()),
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
              ),
            ),
            SizedBox(height: 400.h),
            BlueBiteBottomNavbar(),
          ],
        ),
      ),
    );
  }
}
