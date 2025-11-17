// ignore_for_file: deprecated_member_use, avoid_types_as_parameter_names

import 'package:bluebite/Web%20Screen/fresh.dart';
import 'package:bluebite/Web%20Screen/webcart.dart';
import 'package:bluebite/Web%20Screen/webhomepage.dart';
import 'package:bluebite/bottomnav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'customobject.dart';
import 'responsiveappbar.dart';

class PrebookOrderWeb extends StatelessWidget {
  final String tableNo;
  final String selectedtype;
  final DateTime timeslot; // Selected timeslot

  const PrebookOrderWeb({
    super.key,
    required this.tableNo,
    required this.selectedtype,
    required this.timeslot,
  });

  // Cancel order function
  Future<void> cancelOrder(String orderId, Map<String, dynamic> data) async {
    final ordersCollection = FirebaseFirestore.instance.collection('orders');
    final cancelledCollection = FirebaseFirestore.instance.collection(
      'cancelledOrders',
    );

    // Remove from orders
    await ordersCollection.doc(orderId).delete();

    // Add to cancelledOrders collection
    await cancelledCollection.add({
      ...data,
      'cancelledByUser': true,
      'cancelledAt': Timestamp.now(),
      'status': 'cancelled',
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    const prebookingDuration = Duration(hours: 2);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CartPageWeb()),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.shop, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),
            SizedBox(height: 20.h),
            centeredContent(
              child: Text(
                "Prebook Orders For Table: $tableNo",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            centeredContent(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('tableNo', isEqualTo: tableNo)
                      .where('orderType', isEqualTo: selectedtype)
                      .where('status', whereIn: ['pending', 'processing', 'cancelled'])
                      .orderBy('prebookSlot', descending: true)
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

                    // Find the order matching the selected timeslot
                    Map<String, dynamic>? displayData;
                    String displayOrderId = '';

                    for (var doc in allOrders) {
                      final data = doc.data() as Map<String, dynamic>;
                      final Timestamp? prebookTs = data['prebookSlot'] as Timestamp?;
                      if (prebookTs == null) continue;

                      final orderTime = prebookTs.toDate();

                      final slotStart = timeslot;
                      final slotEnd = slotStart.add(prebookingDuration);

                      final orderEnd = orderTime.add(prebookingDuration);

                      final overlap = slotStart.isBefore(orderEnd) &&
                          slotEnd.isAfter(orderTime);

                      if (overlap) {
                        displayData = data;
                        displayOrderId = doc.id;
                        break;
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Get.to(() => WebHomepage()),
                              child: Text(
                                'Order More Food',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = displayData;
                    final orderId = displayOrderId;
                    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
                    final status = data['status'] ?? 'pending';
                    final feedback = data['adminFeedback'] ?? '';
                    final Timestamp? ts = data['prebookSlot'] as Timestamp?;
                    final DateTime startTime = ts?.toDate() ?? DateTime.now();
                    final DateTime endTime = startTime.add(prebookingDuration);

                    double total = items.fold(0.0, (sum, item) {
                      double price = 0;
                      if (item['selectedVariant'] != null && item['selectedVariant'] is Map) {
                        price = (item['selectedVariant']['price'] ?? 0).toDouble();
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
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                          shadowColor: Colors.blue.shade100,
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: status == "cancelled"
                                        ? Colors.red.shade400
                                        : themeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'Status: $status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: status == "cancelled" ? Colors.white : themeColor,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // Timeslot
                                Text(
                                  'Time Slot: '
                                  '${startTime.day}/${startTime.month}/${startTime.year} '
                                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} '
                                  '- ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 6.h),

                                // Ordered time
                                Text(
                                  'Ordered At: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // Items details with selected variant
                                ...items.map((item) {
                                  final name = item['name']?.toString() ?? 'Unnamed Item';
                                  final quantity = (item['quantity'] ?? 1).toInt();

                                  Map<String, dynamic>? selectedVariant;
                                  if (item['selectedVariant'] != null && item['selectedVariant'] is Map) {
                                    selectedVariant = Map<String, dynamic>.from(item['selectedVariant']);
                                  }

                                  double priceToShow = 0;
                                  String variantName = '';
                                  if (selectedVariant != null) {
                                    priceToShow = (selectedVariant['price'] ?? 0).toDouble();
                                    variantName = selectedVariant['size'] ?? '';
                                  } else {
                                    priceToShow = (item['price'] ?? 0).toDouble();
                                  }

                                  final imgUrl = item['imgUrl']?.toString() ?? '';

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
                                            child: imgUrl.isNotEmpty
                                                ? Image.network(
                                                    imgUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                                                  )
                                                : const Icon(Icons.broken_image_outlined),
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                              SizedBox(height: 6.h),
                                              Text(
                                                variantName.isNotEmpty
                                                    ? '$quantity x $variantName: $priceToShow BDT'
                                                    : '$quantity x $priceToShow BDT',
                                                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
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

                                // Cancel button
                                if (status == 'pending')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    onPressed: () async {
                                      bool confirm = await showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Cancel Order?'),
                                          content: const Text('Do you want to cancel this order?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm) {
                                        await cancelOrder(orderId, data);
                                        Get.off(() => Freshpage());
                                        Get.snackbar(
                                          'Success',
                                          'Order cancelled successfully!',
                                          backgroundColor: Colors.green.shade300,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
                                  ),

                                // Feedback
                                if (feedback.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 6.h),
                                    child: Text(
                                      'Feedback: $feedback',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 6.h),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15.h),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 65.h,
                            width: 250.w,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () => Get.to(() => WebHomepage()),
                              child: const Text('Order More Food', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    );
                  },
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
