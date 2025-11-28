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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Prebookorder extends StatelessWidget {
  final String tableNo;
  final String selectedtype;
  final DateTime timeslot;

  Prebookorder({
    super.key,
    required this.tableNo,
    required this.selectedtype,
    required this.timeslot,
  });

  final GetxCtrl getxcontroller = Get.put(GetxCtrl());

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    const prebookingDuration = Duration(hours: 2);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Helper to check timeslot overlap
    bool overlaps(
      DateTime orderPrebook,
      DateTime slotStart,
      Duration slotDuration,
    ) {
      final slotEnd = slotStart.add(slotDuration);
      final orderEnd = orderPrebook.add(slotDuration);
      return slotStart.isBefore(orderEnd) && slotEnd.isAfter(orderPrebook);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Prebook Orders', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      drawer: customDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CartPageMobile()),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.shop, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "Prebook Orders For Table: $tableNo",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15.h),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('orders')
                      .where('tableNo', isEqualTo: tableNo)
                      .where('orderType', isEqualTo: selectedtype)
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

                final docs = snapshot.data!.docs;
                Map<String, dynamic>? displayData;
                String displayOrderId = '';

                // 1️⃣ Find most recent overlapping order
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final Timestamp? prebookTs =
                      data['prebookSlot'] as Timestamp?;
                  if (prebookTs == null) continue;
                  final orderPrebook = prebookTs.toDate();

                  if (overlaps(orderPrebook, timeslot, prebookingDuration)) {
                    final status =
                        (data['status'] ?? '').toString().toLowerCase();
                    if (status == 'delivered') {
                      displayData = null;
                      displayOrderId = '';
                    } else {
                      displayData = data;
                      displayOrderId = doc.id;
                    }
                    break;
                  }
                }

                // 2️⃣ If no overlapping order, check latest order overall
                if (displayData == null && docs.isNotEmpty) {
                  final mostRecent = docs.first;
                  final mostData = mostRecent.data() as Map<String, dynamic>;
                  final mostStatus =
                      (mostData['status'] ?? '').toString().toLowerCase();
                  if (mostStatus == 'cancelled') {
                    displayData = mostData;
                    displayOrderId = mostRecent.id;
                  }
                }

                if (displayData == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.h),
                        Text(
                          '✅ No orders found for this timeslot!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
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
                          child: const Text(
                            'Order More Food',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // --- Display selected order ---
                final data = displayData;
                final orderId = displayOrderId;
                final items = List<Map<String, dynamic>>.from(
                  data['items'] ?? [],
                );
                final status = data['status'] ?? 'pending';
                final feedback = data['adminFeedback'] ?? '';
                final customername = data['name'];
                final customeradd = data['address'];

                final Timestamp? ts = data['prebookSlot'] as Timestamp?;
                final DateTime startTime = ts?.toDate() ?? DateTime.now();
                final DateTime endTime = startTime.add(prebookingDuration);

                double total = items.fold(0.0, (sum, item) {
                  double price = 0;
                  Map<String, dynamic>? selectedVariant;
                  if (item['selectedVariant'] != null &&
                      item['selectedVariant'] is Map) {
                    selectedVariant = Map<String, dynamic>.from(
                      item['selectedVariant'],
                    );
                    price = (selectedVariant['price'] ?? 0).toDouble();
                  } else {
                    price = (item['price'] ?? 0).toDouble();
                  }
                  final quantity = (item['quantity'] ?? 1).toInt();
                  return sum + (price * quantity);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 5.w,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---------------- STATUS BADGE -----------------
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      status == "cancelled"
                                          ? Colors.red.shade400
                                          : themeColor.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.circleInfo,
                                      size: 16.sp,
                                      color:
                                          status == "cancelled"
                                              ? Colors.white
                                              : themeColor,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color:
                                            status == "cancelled"
                                                ? Colors.white
                                                : themeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // ---------------- CUSTOMER INFO -----------------
                            Text(
                              "Customer Information",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 18.sp,
                                        color: themeColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          customername,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 18.sp,
                                        color: themeColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          data['phone'] ?? "No phone",
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 18.sp,
                                        color: themeColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          customeradd,
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // ---------------- ORDER INFO -----------------
                            Text(
                              "Order Details",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 18.sp,
                                        color: themeColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          "Time Slot:\n${dateFormat.format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}",
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: 18.sp,
                                        color: themeColor,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          "Ordered At:\n${data['timestamp'] != null ? dateFormat.format((data['timestamp'] as Timestamp).toDate()) : dateFormat.format(DateTime.now())}",
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // ---------------- ITEM LIST -----------------
                            Text(
                              "Items",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            ...items.map((item) {
                              final name =
                                  item['name']?.toString() ?? 'Unnamed Item';
                              final quantity = (item['quantity'] ?? 1).toInt();
                              Map<String, dynamic>? selectedVariant;
                              if (item['selectedVariant'] != null &&
                                  item['selectedVariant'] is Map) {
                                selectedVariant = Map<String, dynamic>.from(
                                  item['selectedVariant'],
                                );
                              }
                              final priceToShow =
                                  selectedVariant != null
                                      ? (selectedVariant['price'] ?? 0)
                                          .toDouble()
                                      : (item['price'] ?? 0).toDouble();
                              final variantName =
                                  selectedVariant != null
                                      ? selectedVariant['size'] ?? ''
                                      : '';
                              final imgUrl = item['imgUrl']?.toString() ?? '';

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 6.h),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Container(
                                        width: 65.w,
                                        height: 65.w,
                                        color: Colors.grey.shade200,
                                        child:
                                            imgUrl.isNotEmpty
                                                ? CachedNetworkImage(
                                                  imageUrl: imgUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (_, __) => Container(
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
                                            name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            variantName.isNotEmpty
                                                ? "$quantity × $variantName • $priceToShow BDT"
                                                : "$quantity × $priceToShow BDT",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            SizedBox(height: 10.h),

                            // ---------------- TOTAL -----------------
                            Text(
                              "Total: $total BDT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: themeColor,
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // ---------------- CANCEL BUTTON -----------------
                            if (status == 'pending')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
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
                                        orderId,
                                        data,
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
                                  icon: const FaIcon(
                                    FontAwesomeIcons.trash,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Cancel Order",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),

                            SizedBox(height: 6.h),

                            // ---------------- FEEDBACK -----------------
                            if (feedback.isNotEmpty)
                              Text(
                                "Admin Feedback: $feedback",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ---------------- ORDER MORE -----------------
                    SizedBox(
                      width: 260.w,
                      height: 50.h,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () => Get.to(() => MobileHomepage()),
                        icon: FaIcon(
                          FontAwesomeIcons.plusCircle,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        label: const Text(
                          "Order More Food",
                          style: TextStyle(color: Colors.white),
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
