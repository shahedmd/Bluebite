// ignore_for_file: deprecated_member_use, avoid_types_as_parameter_names

import 'package:bluebite/Web%20Screen/fresh.dart';
import 'package:bluebite/Web%20Screen/webcart.dart';
import 'package:bluebite/Web%20Screen/webhomepage.dart';
import 'package:bluebite/bottomnav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../firebasequery.dart';
import 'customobject.dart';
import 'responsiveappbar.dart';

class PrebookOrderWeb extends StatelessWidget {
  final String tableNo;
  final String selectedtype;
  final DateTime timeslot;

  PrebookOrderWeb({
    super.key,
    required this.tableNo,
    required this.selectedtype,
    required this.timeslot,
  });

  final GetxCtrl getxcontroller = Get.put(GetxCtrl());
  static const Duration prebookingDuration = Duration(hours: 2);

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Helper: determine overlap between two slots (both with same duration)
    bool overlaps(DateTime orderPrebook, DateTime slotStart, Duration slotDuration) {
      final slotEnd = slotStart.add(slotDuration);
      final orderEnd = orderPrebook.add(slotDuration);
      return slotStart.isBefore(orderEnd) && slotEnd.isAfter(orderPrebook);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CartPageWeb()),
        backgroundColor: Colors.blue.shade900,
        child: const FaIcon(FontAwesomeIcons.shoppingCart, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),
            SizedBox(height: 24.h),
            centeredContent(
              child: Text(
                "Prebook Orders — Table $tableNo",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 18.h),
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

                    final docs = snapshot.data!.docs;

                    
                    Map<String, dynamic>? displayData;
                    String displayOrderId = '';

                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final Timestamp? prebookTs = data['prebookSlot'] as Timestamp?;
                      if (prebookTs == null) continue;
                      final orderPrebook = prebookTs.toDate();

                      if (overlaps(orderPrebook, timeslot, prebookingDuration)) {
                        final status = (data['status'] ?? '').toString().toLowerCase();
                        if (status == 'delivered') {
                          // delivered overlapping slot -> treat as none
                          displayData = null;
                          displayOrderId = '';
                        } else {
                          displayData = data;
                          displayOrderId = doc.id;
                        }
                        break;
                      }
                    }

                    // If not found by overlap, check latest doc for cancelled
                    if (displayData == null && docs.isNotEmpty) {
                      final mostRecent = docs.first;
                      final mostData = mostRecent.data() as Map<String, dynamic>;
                      final mostStatus = (mostData['status'] ?? '').toString().toLowerCase();
                      if (mostStatus == 'cancelled') {
                        displayData = mostData;
                        displayOrderId = mostRecent.id;
                      }
                    }

                    if (displayData == null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 40.h),
                            Text(
                              '✅ No orders found for this timeslot!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'This timeslot is available — customers can place a prebooking here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton.icon(
                              icon: const FaIcon(FontAwesomeIcons.plus),
                              label: const Text('Order More Food'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                              onPressed: () => Get.to(() => WebHomepage()),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      );
                    }

                    // Build display for the selected order
                    final data = displayData;
                    final orderId = displayOrderId;
                    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
                    final status = (data['status'] ?? 'pending').toString();
                    final feedback = (data['adminFeedback'] ?? '').toString();
                    final customername = (data['name'] ?? '').toString();
                    final customerphone = (data['phone'] ?? '').toString();
                    final customeradd = (data['address'] ?? '').toString();
                    final Timestamp? preTs = data['prebookSlot'] as Timestamp?;
                    final DateTime startTime = preTs?.toDate() ?? DateTime.now();
                    final DateTime endTime = startTime.add(prebookingDuration);
                    final Timestamp? ts = data['timestamp'] as Timestamp?;
                    final String orderedAt = ts != null ? dateFormat.format(ts.toDate()) : dateFormat.format(DateTime.now());

                    // Compute total robustly
                    double total = 0.0;
                    for (var item in items) {
                      final qRaw = item['quantity'] ?? 1;
                      final qty = (qRaw is int) ? qRaw : (qRaw is double ? qRaw.toInt() : int.tryParse(qRaw.toString()) ?? 1);
                      if (item['selectedVariant'] != null && item['selectedVariant'] is Map) {
                        final sv = Map<String, dynamic>.from(item['selectedVariant']);
                        final priceRaw = sv['price'] ?? 0;
                        final price = (priceRaw is num) ? (priceRaw).toDouble() : double.tryParse(priceRaw.toString()) ?? 0.0;
                        total += price * qty;
                      } else {
                        final priceRaw = item['price'] ?? 0;
                        final price = (priceRaw is num) ? (priceRaw).toDouble() : double.tryParse(priceRaw.toString()) ?? 0.0;
                        total += price * qty;
                      }
                    }

                    // ---------- Web-optimized two-column card ----------
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
                          child: Padding(
                            padding: EdgeInsets.all(18.r),
                            child: Column(
                              children: [
                                // STATUS row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: status == 'cancelled' ? Colors.red.shade400 : themeColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            status == 'cancelled' ? FontAwesomeIcons.exclamationTriangle : FontAwesomeIcons.clock,
                                            size: 14.sp,
                                            color: status == 'cancelled' ? Colors.white : themeColor,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: status == 'cancelled' ? Colors.white : themeColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    if (feedback.isNotEmpty)
                                      Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.commentDots, size: 14.sp, color: Colors.grey.shade700),
                                          SizedBox(width: 6.w),
                                          Text(feedback, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                                        ],
                                      ),
                                  ],
                                ),

                                SizedBox(height: 18.h),

                                // Two-column: Customer Info (left) | Order Info (right)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Customer Info
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        padding: EdgeInsets.all(14.r),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Customer Info', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 8.h),
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.user, size: 14.sp, color: themeColor),
                                                SizedBox(width: 8.w),
                                                Expanded(child: Text(customername, style: TextStyle(fontWeight: FontWeight.w600))),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.phone, size: 14.sp, color: themeColor),
                                                SizedBox(width: 8.w),
                                                Expanded(child: Text(customerphone.isNotEmpty ? customerphone : 'No phone')),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                FaIcon(FontAwesomeIcons.locationDot, size: 14.sp, color: themeColor),
                                                SizedBox(width: 8.w),
                                                Expanded(child: Text(customeradd.isNotEmpty ? customeradd : 'No address')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16.w),

                                    // Right: Order Info
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(14.r),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Order Info', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 8.h),
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.clock, size: 14.sp, color: themeColor),
                                                SizedBox(width: 8.w),
                                                Expanded(child: Text('Time Slot: ${dateFormat.format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}')),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.receipt, size: 14.sp, color: themeColor),
                                                SizedBox(width: 8.w),
                                                Expanded(child: Text('Ordered At: $orderedAt')),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.table, size: 14.sp, color: themeColor),
                                                SizedBox(width: 8.w),
                                                Expanded(child: Text('Table: $tableNo')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),

                                // Items full width
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Items', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 10.h),

                                // Items list — each item row
                                Column(
                                  children: items.map((item) {
                                    final name = (item['name'] ?? 'Item').toString();
                                    final qRaw = item['quantity'] ?? 1;
                                    final qty = (qRaw is int) ? qRaw : (qRaw is double ? qRaw.toInt() : int.tryParse(qRaw.toString()) ?? 1);
                                    Map<String, dynamic>? variant;
                                    if (item['selectedVariant'] != null && item['selectedVariant'] is Map) {
                                      variant = Map<String, dynamic>.from(item['selectedVariant']);
                                    }
                                    final double price = variant != null
                                        ? ((variant['price'] ?? 0) is num ? (variant['price'] as num).toDouble() : double.tryParse((variant['price'] ?? '0').toString()) ?? 0)
                                        : ((item['price'] ?? 0) is num ? (item['price'] as num).toDouble() : double.tryParse((item['price'] ?? '0').toString()) ?? 0);
                                    final variantText = variant != null ? (variant['size'] ?? '') : '';
                                    final imgUrl = (item['imgUrl'] ?? '').toString();

                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10.r),
                                            child: Container(
                                              width: 80.w,
                                              height: 80.w,
                                              color: Colors.grey.shade200,
                                              child: imgUrl.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: imgUrl,
                                                      fit: BoxFit.cover,
                                                      placeholder: (_, __) => Container(color: Colors.grey.shade300),
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
                                                Text('$name ${variantText.isNotEmpty ? "($variantText)" : ""}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                                                SizedBox(height: 6.h),
                                                Text('$qty × $price BDT', style: TextStyle(color: Colors.grey.shade700)),
                                                SizedBox(height: 4.h),
                                                Text('Subtotal: ${qty * price} BDT', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                                SizedBox(height: 12.h),
                                Divider(),

                                // Total + actions row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('Total: $total BDT', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: themeColor)),
                                    ),

                                    // Cancel button (only pending)
                                    if (status == 'pending')
                                      ElevatedButton.icon(
                                        icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.white),
                                        label: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade600,
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
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
                                          if (confirm == true) {
                                            await getxcontroller.cancelOrder(orderId, data);
                                            Get.off(() => Freshpage());
                                            Get.snackbar('Success', 'Order cancelled successfully!', backgroundColor: Colors.green.shade300, colorText: Colors.white);
                                          }
                                        },
                                      ),
                                  ],
                                ),

                                // Feedback (if provided and not cancelled)
                                if (status != 'cancelled' && feedback.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.h),
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.commentDots, size: 14.sp, color: Colors.grey.shade700),
                                        SizedBox(width: 8.w),
                                        Expanded(child: Text('Feedback: $feedback', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700))),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),

                        // Order more button centered
                        Center(
                          child: SizedBox(
                            height: 54.h,
                            width: 220.w,
                            child: ElevatedButton.icon(
                              icon: const FaIcon(FontAwesomeIcons.plusCircle, color: Colors.white,),
                              label: const Text('Order More Food', style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              ),
                              onPressed: () => Get.to(() => WebHomepage()),
                            ),
                          ),
                        ),

                        SizedBox(height: 30.h),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 200.h),
            BlueBiteBottomNavbar(),
          ],
        ),
      ),
    );
  }
}
