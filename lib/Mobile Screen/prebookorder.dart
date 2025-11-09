import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/mobilehomepage.dart';
import 'package:bluebite/globalvar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Prebookorder extends StatelessWidget {
  final String tableNo;
  final String selectedtype;
  const Prebookorder({
    super.key,
    required this.tableNo,
    required this.selectedtype,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    const prebookingDuration = Duration(hours: 2);

    return Scaffold(
      drawer: customDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Prebooked Order - Table $tableNo'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('tableNo', isEqualTo: tableNo)
            .where('orderType', isEqualTo: selectedtype)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data!.docs;

          // Only show pending orders
          final pendingOrders = allOrders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? '') != 'delivered';
          }).toList();

          if (pendingOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '✅ No current prebooking orders for this table!',
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
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Order More Food',
                      style: TextStyle(color: white),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    final data =
                        pendingOrders[index].data() as Map<String, dynamic>;
                    final items = List<Map<String, dynamic>>.from(
                      data['items'] ?? [],
                    );
                    final status = data['status'] ?? 'pending';
                    final feedback = data['adminFeedback'] ?? '';

                    final Timestamp ts = data['timestamp'];
                    final DateTime startTime = ts.toDate();
                    final DateTime endTime = startTime.add(prebookingDuration);

                    double total = items.fold(0.0, (sumv, item) {
                      final price = (item['price'] ?? 0).toDouble();
                      final quantity = (item['quantity'] ?? 0).toInt();
                      return sumv + (price * quantity);
                    });

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: themeColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
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
                            ...items.map((item) {
                              final name = item['name'] ?? 'Item';
                              final quantity = item['quantity'] ?? 1;
                              final price = item['price'] ?? 0;
                              return Text(
                                '$name x $quantity - ${price * quantity} BDT',
                              );
                            }),
                            SizedBox(height: 6.h),
                            Text(
                              'Total: $total BDT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 250.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => Get.to(() => MobileHomepage()),
                  child: Text(
                    'Order More Food',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          );
        },
      ),
    );
  }
}
