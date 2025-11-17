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

class LiveOrderPageWeb extends StatelessWidget {
  final String tableNo;
  final String selectedtype;

  const LiveOrderPageWeb({
    super.key,
    required this.tableNo,
    required this.selectedtype,
  });

  // Function to cancel order
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CartPageWeb());
        },
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
                "Inhouse Order Details For Table: $tableNo",
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

                    final allOrders = snapshot.data!.docs;

                    // Filter out delivered orders
                    final relevantOrders =
                        allOrders.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? '';
                          return status != 'delivered';
                        }).toList();

                    if (relevantOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 50.h),
                            Text(
                              'No pending or cancelled orders!',
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
                                'Order Food',
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

                    final latestOrder = relevantOrders.first;
                    final data = latestOrder.data() as Map<String, dynamic>;
                    final orderId = latestOrder.id;
                    final items = List<Map<String, dynamic>>.from(
                      data['items'] ?? [],
                    );
                    final status = data['status'] ?? 'pending';
                    final feedback = data['adminFeedback'] ?? '';
                    final Timestamp? ts = data['timestamp'] as Timestamp?;

                    double total = items.fold(0.0, (sum, i) {
                      final int q = (i['quantity'] ?? 1).toInt();

                      // variant-safe price
                      final double p =
                          i['selectedVariant'] != null
                              ? (i['selectedVariant']['price'] ?? 0).toDouble()
                              : (i['price'] ?? 0).toDouble();

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
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        status == "cancelled"
                                            ? Colors.red.shade400
                                            : themeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'Status: $status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color:
                                          status == "cancelled"
                                              ? Colors.white
                                              : themeColor,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // Cancelled feedback
                                if (status == "cancelled")
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                    ),
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

                                // Items
                                ...items.map((item) {
                                  final String name = item['name'] ?? 'Item';

                                  // quantity (safe integer)
                                  final int quantity =
                                      (item['quantity'] ?? 1).toInt();

                                  // variant (check if available)
                                  final Map<String, dynamic>? variantMap =
                                      item['selectedVariant'] != null
                                          ? Map<String, dynamic>.from(
                                            item['selectedVariant'],
                                          )
                                          : null;

                                  // Unit price = variant price OR normal price
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
                                      vertical: 6.h,
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child: Container(
                                            width: 80.w,
                                            height: 80.w,
                                            color: Colors.grey.shade200,
                                            child:
                                                imgUrl.isNotEmpty
                                                    ? Image.network(
                                                      imgUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
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
                                                      Icons
                                                          .broken_image_outlined,
                                                    ),
                                          ),
                                        ),

                                        SizedBox(width: 16.w),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// Product name + variant
                                              Text(
                                                "$name $variantText",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              SizedBox(height: 6.h),

                                              /// Unit price × quantity
                                              Text(
                                                "$quantity × $unitPrice BDT",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),

                                              /// Item subtotal
                                              Text(
                                                "Subtotal: ${unitPrice * quantity} BDT",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
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

                                // Cancel button (only pending orders)
                                if (status == 'pending')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
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
                                                      ), // returns false
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ), // return true here
                                                  child: const Text('Yes'),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm) {
                                        await cancelOrder(orderId, data);
                                        Get.off(
                                          () => Freshpage(),
                                        ); // Navigate after cancel
                                        Get.snackbar(
                                          'Success',
                                          'Order cancelled successfully!',
                                          backgroundColor:
                                              Colors.green.shade300,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },

                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.w,
                                      ),
                                      child: const Text(
                                        'Cancel Order',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),

                                if (status != "cancelled" &&
                                    feedback.isNotEmpty)
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
                                Text(
                                  'Order Time: ${ts!.toDate()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
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
                              child: const Text(
                                'Order More Food',
                                style: TextStyle(color: Colors.white),
                              ),
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
