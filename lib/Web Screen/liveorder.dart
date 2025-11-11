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

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;

    return Scaffold(
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(()=> CartPageWeb());
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.shop, color: Colors.white,),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),
        
            // Body
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
                                                        SizedBox(height: 50.h,),

                            Text(
                              '✅ You do not order Yet / All Previous orders delivered!',
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
            
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingOrders.length,
                          itemBuilder: (context, index) {
                            final data =
                                pendingOrders[index].data()
                                    as Map<String, dynamic>;
                            final items = List<Map<String, dynamic>>.from(
                              data['items'] ?? [],
                            );
                            final status = data['status'] ?? 'pending';
                            final feedback = data['adminFeedback'] ?? '';
                            final Timestamp ts = data['timestamp'];
                        
                            double total = items.fold(0.0, (sumv, item) {
                              final price = (item['price'] ?? 0).toDouble();
                              final quantity =
                                  (item['quantity'] ?? 0).toInt();
                              return sumv + (price * quantity);
                            });
                        
                            return Card(
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status: $status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: themeColor,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    ...items.map((item) {
                                      final name = item['name'] ?? 'Item';
                                      final quantity = item['quantity'] ?? 1;
                                      final price = item['price'] ?? 0;
                                      final imgUrl =
                                          item['imgUrl']?.toString() ?? '';
                        
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.h,
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
                                                        ? Image.network(
                                                          imgUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Icon(
                                                              Icons
                                                                  .broken_image_outlined,
                                                            );
                                                          },
                                                        )
                                                        : Icon(
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
                                                  Text(
                                                    name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    '$quantity x $price BDT',
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color:
                                                          Colors
                                                              .grey
                                                              .shade700,
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
                                    Text(
                                      'Order Time: ${ts.toDate()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: themeColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 15.h,),
            
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
                              child: Text(
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
