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

class LiveOrderPageWeb extends StatelessWidget {
  final String tableNo;
  final String selectedtype;

  const LiveOrderPageWeb({
    super.key,
    required this.tableNo,
    required this.selectedtype,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final GetxCtrl getxcontroller = Get.put(GetxCtrl());

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
                "Inhouse Order Details - Table $tableNo",
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

                    final orders = snapshot.data!.docs;

                    // If there are no orders at all for this table/type
                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50.h),
                            Text(
                              'No orders yet for this table.',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton.icon(
                              onPressed: () => Get.to(() => WebHomepage()),
                              icon: FaIcon(
                                FontAwesomeIcons.utensils,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Order Food',
                                style: TextStyle(color: Colors.white),
                              ),
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
                            ),
                          ],
                        ),
                      );
                    }

                    // -------------------------------
                    // Apply MOBILE logic:
                    // Loop through docs (newest -> oldest),
                    // stop when encountering a 'delivered' order (do not show delivered or older).
                    // Show the first pending/processing/cancelled order encountered (latest active).
                    // -------------------------------
                    Map<String, dynamic>? orderToShow;
                    String? orderId;

                    for (var doc in orders) {
                      final data = doc.data() as Map<String, dynamic>;
                      final status = (data['status'] ?? 'pending').toString();

                      if (status == 'delivered') {
                        // STOP: as soon as we find a delivered, we should not show older orders
                        break;
                      }

                      if (status == 'pending' || status == 'processing' || status == 'cancelled') {
                        orderToShow = data;
                        orderId = doc.id;
                        break;
                      }
                    }

                    if (orderToShow == null) {
                      // No pending/processing/cancelled before a delivered order
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50.h),
                            Text(
                              'No pending or cancelled orders!',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton.icon(
                              onPressed: () => Get.to(() => WebHomepage()),
                              icon: FaIcon(
                                FontAwesomeIcons.utensils,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Order Food',
                                style: TextStyle(color: Colors.white),
                              ),
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
                            ),
                          ],
                        ),
                      );
                    }

                    // Build UI for the selected order (same as mobile card)
                    final items = List<Map<String, dynamic>>.from(orderToShow['items'] ?? []);
                    final status = (orderToShow['status'] ?? 'pending').toString();
                    final feedback = orderToShow['adminFeedback']?.toString() ?? '';
                    final Timestamp? ts = orderToShow['timestamp'] as Timestamp?;
                    final String formattedDate = ts != null ? dateFormat.format(ts.toDate()) : "No date";

                    double total = items.fold(0.0, (sum, item) {
                      final q = (item['quantity'] ?? 1);
                      final qty = (q is int) ? q : (q is double ? q.toInt() : int.parse(q.toString()));
                      double p = 0.0;
                      if (item['selectedVariant'] != null) {
                        final sv = Map<String, dynamic>.from(item['selectedVariant']);
                        final priceRaw = sv['price'] ?? 0;
                        p = (priceRaw is num) ? (priceRaw).toDouble() : double.parse(priceRaw.toString());
                      } else {
                        final priceRaw = item['price'] ?? 0;
                        // ignore: unnecessary_cast
                        p = (priceRaw is num) ? (priceRaw as num).toDouble() : double.parse(priceRaw.toString());
                      }
                      return sum + (p * qty);
                    });

                    // Table number (if present)
                    final String tableNumber = (orderToShow['tableNo'] ?? '').toString();

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
                                // Status badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: status == "cancelled" ? Colors.red.shade400 : themeColor.withOpacity(0.12),
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

                                // Cancel reason
                                if (status == "cancelled")
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    child: Text(
                                      feedback.isNotEmpty ? 'Reason: $feedback' : 'No reason provided by admin.',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),

                                // Order meta: table (if any) + order time
                                SizedBox(height: 6.h),
                                if (tableNumber.isNotEmpty)
                                  Text(
                                    'Table: $tableNumber',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: themeColor),
                                  ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.clock, size: 14.sp, color: themeColor),
                                    SizedBox(width: 6.w),
                                    Text('Order Time: $formattedDate', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // Items list
                                Text(
                                  'Items',
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10.h),

                                ...items.map((item) {
                                  final name = item['name'] ?? 'Item';
                                  final q = (item['quantity'] ?? 1);
                                  final qty = (q is int) ? q : (q is double ? q.toInt() : int.parse(q.toString()));
                                  final variantMap = item['selectedVariant'] != null ? Map<String, dynamic>.from(item['selectedVariant']) : null;
                                  final price = variantMap != null
                                      ? ((variantMap['price'] ?? 0) is num ? (variantMap['price'] as num).toDouble() : double.parse((variantMap['price'] ?? 0).toString()))
                                      : ((item['price'] ?? 0) is num ? (item['price'] as num).toDouble() : double.parse((item['price'] ?? 0).toString()));
                                  final variantText = variantMap != null ? "(${variantMap['size'] ?? ''})" : "";
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
                                                ? CachedNetworkImage(
                                                    imageUrl: imgUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Container(color: Colors.grey.shade300),
                                                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                                                  )
                                                : const Icon(Icons.broken_image),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('$name $variantText', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                              SizedBox(height: 4.h),
                                              Text('$qty × $price BDT', style: TextStyle(color: Colors.grey.shade700)),
                                              Text('Subtotal: ${price * qty} BDT', style: TextStyle(fontWeight: FontWeight.bold)),
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

                                // Feedback (non-cancelled)
                                if (status != 'cancelled' && feedback.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.commentDots, size: 14.sp, color: Colors.grey.shade700),
                                        SizedBox(width: 8.w),
                                        Expanded(child: Text('Feedback: $feedback', style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic))),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: 12.h),

                                // Cancel button (pending only)
                                if (status == 'pending')
                                  SizedBox(
                                    width: 300.w,
                                    child: ElevatedButton.icon(
                                      icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white),
                                      label: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
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
                                          await getxcontroller.cancelOrder(orderId!, orderToShow!);
                                          Get.off(() => WebHomepage());
                                          Get.snackbar('Success', 'Order cancelled successfully!', backgroundColor: Colors.green.shade300, colorText: Colors.white);
                                        }
                                      },
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
                            child: ElevatedButton.icon(
                              icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
                              label: const Text('Order More Food', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onPressed: () => Get.to(() => WebHomepage()),
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
