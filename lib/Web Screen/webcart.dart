// ignore_for_file: use_build_context_synchronously

import 'package:bluebite/Web%20Screen/responsiveappbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../bottomnav.dart';
import '../cartcontroller.dart';
import '../firebasequery.dart';
import 'customobject.dart';
// for CustomNavbar

class CartPageWeb extends StatefulWidget {
  const CartPageWeb({super.key});

  @override
  State<CartPageWeb> createState() => _CartPageWebState();
}

class _CartPageWebState extends State<CartPageWeb> {
  final CartController cartController = Get.put(CartController());
  final GetxCtrl controller = Get.put(GetxCtrl());

  final List<String> tables = List.generate(20, (index) => '${index + 1}');
  final List<String> orderTypes = ['Inhouse', 'Prebooking'];

  String selectedTable = '1';
  String selectedOrderType = 'Inhouse';
  DateTime? selectedDateTime; // for prebooking

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomNavbar(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: centeredContent(
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedTable,
                      items:
                          tables
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text('Table $t'),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedTable = val!;
                        });
                      },
                    ),
                    SizedBox(width: 20.w),
                    DropdownButton<String>(
                      value: selectedOrderType,
                      items:
                          orderTypes
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (val) async {
                        setState(() {
                          selectedOrderType = val!;
                        });

                        if (val == 'Prebooking') {
                          await _pickDateTime(context);
                        } else {
                          setState(() {
                            selectedDateTime = null;
                          });
                        }
                      },
                    ),
                    if (selectedOrderType == 'Prebooking' &&
                        selectedDateTime != null)
                      Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: Text(
                          'Selected: ${selectedDateTime!.toString().substring(0, 16)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: themeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                    TextButton.icon(
                      onPressed: () async => await _pickDateTime(context),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change'),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            centeredContent(
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Items
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cart Items',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ...cartController.cartItems.map(
                            (item) => Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20.r,
                                ), // more rounded
                              ),
                              margin: EdgeInsets.symmetric(vertical: 12.h),
                              shadowColor: Colors.blue.shade100,
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Product Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        color: Colors.grey.shade200,
                                        child:
                                            item.imgUrl.isNotEmpty
                                                ? Image.network(
                                                  item.imgUrl,
                                                  fit: BoxFit.cover,
                                                )
                                                : Icon(
                                                  Icons.broken_image,
                                                  size: 40.sp,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                    SizedBox(width: 20.w),

                                    // Name & Price
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            '${item.quantity} x ${item.price} BDT',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quantity Buttons + Delete
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: themeColor,
                                          ),
                                          onPressed:
                                              () => cartController
                                                  .decreaseQuantity(item),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: themeColor,
                                          ),
                                          onPressed:
                                              () => cartController
                                                  .increaseQuantity(item),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red.shade700,
                                          ),
                                          onPressed:
                                              () => cartController
                                                  .removeFromCart(item),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 30.w),

                    // Total + Confirm Order
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '${cartController.totalPrice} BDT',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 30.h),
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed:
                                    () => controller.confirmOrder(
                                      selectedTable,
                                      selectedOrderType,
                                      context,
                                      selectedDateTime,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                child: Text(
                                  'Confirm Order',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  // helper method to select date and time
  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade800),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade800),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }
}
