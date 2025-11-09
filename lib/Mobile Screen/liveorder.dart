import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:bluebite/Mobile%20Screen/mobilehomepage.dart';
import 'package:bluebite/globalvar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LiveOrderPage extends StatelessWidget {
  final String tableNo;
  final String selectedtype;
  const LiveOrderPage({
    super.key,
    required this.tableNo,
    required this.selectedtype,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;

    return Scaffold(
      drawer: customDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Live Orders - Table $tableNo'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
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

          final pendingOrders =
              allOrders.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['status'] ?? '') != 'delivered';
              }).toList();

          if (pendingOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '✅ You do not order Yet/All Previous orders delivered!',
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
                             SizedBox(height: 6.h),
                            Text(
                              'Order Time: ${ts.toDate()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            SizedBox(height: 6.h,),
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
