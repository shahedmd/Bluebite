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
    required this.customerPhone,
  });

  final GetxCtrl getxcontroller = GetxCtrl();

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Get today's start and end time
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home Delivery Orders", style: TextStyle(fontSize: 18.sp)),
        backgroundColor: themeColor,
      ),
      drawer: customDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CartPageMobile()),
        backgroundColor: themeColor,
        child: const Icon(Icons.shop, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('orderType', isEqualTo: selectedtype)
              .where('name', isEqualTo: customerName)
              .where('phone', isEqualTo: customerPhone)
              .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final allOrders = snapshot.data!.docs;

            if (allOrders.isEmpty) return Center(child: Text('No orders yet today!', style: TextStyle(fontSize: 16.sp)));

            // Filter out delivered orders
            final todaysOrders = allOrders
                .map((doc) => {
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    })
                .where((order) => order['status'] != 'delivered')
                .toList();

            if (todaysOrders.isEmpty) return Center(child: Text('No pending/cancelled orders today!', style: TextStyle(fontSize: 16.sp)));

            return Column(
              children: todaysOrders.map((orderToShow) {
                final orderId = orderToShow['id'] as String;
                final items = List<Map<String, dynamic>>.from(orderToShow['items'] ?? []);
                final status = orderToShow['status'] ?? 'pending';
                final feedback = orderToShow['adminFeedback'] ?? '';
                final customername = orderToShow['name'] ?? '';
                final customerphone = orderToShow['phone'] ?? '';
                final customeraddress = orderToShow['address'] ?? '';
                final tableno = orderToShow['tableNo'] ?? '';
                final Timestamp? ts = orderToShow['timestamp'] as Timestamp?;
                final String formattedDate = ts != null ? dateFormat.format(ts.toDate()) : "No date";

                double total = items.fold(0.0, (sum, item) {
                  final int q = (item['quantity'] ?? 1).toInt();
                  final double p = item['selectedVariant'] != null
                      ? (item['selectedVariant']['price'] ?? 0).toDouble()
                      : (item['price'] ?? 0).toDouble();
                  return sum + (p * q);
                });

                Color statusColor = status == 'cancelled'
                    ? Colors.red
                    : status == 'pending'
                        ? Colors.orange
                        : Colors.green;

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // STATUS
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.circleCheck, color: statusColor, size: 16.sp),
                            SizedBox(width: 6.w),
                            Text('Status: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        if (tableno.isNotEmpty)
                          Text('Selected Table - $tableno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),

                        // CUSTOMER INFO
                        Text('Customer Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Divider(),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.user, size: 14.sp, color: themeColor),
                            SizedBox(width: 6.w),
                            Expanded(child: Text(customername, style: TextStyle(fontSize: 14.sp))),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.phone, size: 14.sp, color: themeColor),
                            SizedBox(width: 6.w),
                            Expanded(child: Text(customerphone, style: TextStyle(fontSize: 14.sp))),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FaIcon(FontAwesomeIcons.locationDot, size: 14.sp, color: themeColor),
                            SizedBox(width: 6.w),
                            Expanded(child: Text(customeraddress, style: TextStyle(fontSize: 14.sp))),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // ORDER ITEMS
                        Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Divider(),
                        ...items.map((item) {
                          final String name = item['name'] ?? '';
                          final int quantity = (item['quantity'] ?? 1).toInt();
                          final Map<String, dynamic>? variantMap =
                              item['selectedVariant'] != null ? Map<String, dynamic>.from(item['selectedVariant']) : null;
                          final double unitPrice =
                              variantMap != null ? (variantMap['price'] ?? 0).toDouble() : (item['price'] ?? 0).toDouble();
                          final String variantText = variantMap != null ? "(${variantMap['size']})" : "";
                          final String imgUrl = item['imgUrl']?.toString() ?? '';

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    width: 70.w,
                                    height: 70.w,
                                    color: Colors.grey.shade200,
                                    child: imgUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imgUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(color: Colors.grey.shade300),
                                            errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                                          )
                                        : const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$name $variantText', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                                      SizedBox(height: 4.h),
                                      Text('$quantity × $unitPrice BDT', style: TextStyle(color: Colors.grey.shade700)),
                                      Text('Subtotal: ${unitPrice * quantity} BDT', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Divider(),
                        Text('Total: $total BDT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: themeColor)),
                        SizedBox(height: 12.h),

                        // FEEDBACK
                        if (status == 'cancelled' && feedback.isNotEmpty)
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.commentSlash, size: 14.sp, color: Colors.red.shade700),
                              SizedBox(width: 6.w),
                              Expanded(child: Text('Reason: $feedback', style: TextStyle(color: Colors.red.shade700, fontStyle: FontStyle.italic))),
                            ],
                          ),
                        if (status != 'cancelled' && feedback.isNotEmpty)
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.commentDots, size: 14.sp, color: Colors.grey.shade800),
                              SizedBox(width: 6.w),
                              Expanded(child: Text('Feedback: $feedback', style: TextStyle(color: Colors.grey.shade800, fontStyle: FontStyle.italic))),
                            ],
                          ),
                        SizedBox(height: 12.h),

                        // ORDER TIME
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.clock, size: 14.sp, color: themeColor),
                            SizedBox(width: 6.w),
                            Text('Order Time: $formattedDate', style: TextStyle(color: themeColor)),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ACTION BUTTONS
                        if (status == 'pending')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, padding: EdgeInsets.symmetric(vertical: 12.h)),
                            icon: FaIcon(FontAwesomeIcons.xmark, color: Colors.white),
                            label: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Cancel Order?'),
                                  content: const Text('Do you want to cancel this order?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                                  ],
                                ),
                              );
                              if (confirm) {
                                await getxcontroller.cancelOrder(orderId, orderToShow);
                                Get.off(() => FreshMobile());
                                Get.snackbar('Success', 'Order cancelled successfully!', backgroundColor: Colors.green.shade300, colorText: Colors.white);
                              }
                            },
                          ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: themeColor, padding: EdgeInsets.symmetric(vertical: 12.h)),
                            icon: FaIcon(FontAwesomeIcons.bowlFood, color: Colors.white),
                            label: const Text('Order More Food', style: TextStyle(color: Colors.white)),
                            onPressed: () => Get.to(() => MobileHomepage()),
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
    );
  }
}
