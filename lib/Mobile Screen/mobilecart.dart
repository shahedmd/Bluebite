import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../cartcontroller.dart';
import '../firebasequery.dart';

class CartPageMobile extends StatefulWidget {
  const CartPageMobile({super.key});

  @override
  State<CartPageMobile> createState() => _CartPageMobileState();
}

class _CartPageMobileState extends State<CartPageMobile> {
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
      drawer: customDrawer(context),
      floatingActionButton: SizedBox(
        width: 200.w,
        height: 56.h,
        child: FloatingActionButton.extended(
          onPressed: () => controller.confirmOrder(
            selectedTable,
            selectedOrderType,
            context,
            selectedDateTime,
          ),
          backgroundColor: themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Text(
            'Confirm Order',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Blue Bite Restaurant'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedTable,
                  items: tables
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text('Table $t'),
                          ))
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
                  items: orderTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) async {
                    setState(() {
                      selectedOrderType = val!;
                    });

                    if (val == 'Prebooking') {
                      // Ask date and time for prebooking
                      await _pickDateTime(context);
                    } else {
                      setState(() {
                        selectedDateTime = null;
                      });
                    }
                  },
                ),
              ],
            ),

            // Show selected DateTime if prebooking
            if (selectedOrderType == 'Prebooking' && selectedDateTime != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    SizedBox(width: 8.w),
                    Text(
                      'Selected: ${selectedDateTime!.toString().substring(0, 16)}',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
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

            SizedBox(height: 10.h),
            Expanded(
              child: Obx(
                () => ListView(
                  children: [
                    Text(
                      'Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: themeColor,
                      ),
                    ),
                    ...cartController.cartItems.map(
                      (item) => Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: ListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Qty: ${item.quantity} - ${item.price * item.quantity} BDT',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: themeColor),
                                onPressed: () =>
                                    cartController.decreaseQuantity(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: themeColor),
                                onPressed: () =>
                                    cartController.increaseQuantity(item),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade700,
                                ),
                                onPressed: () =>
                                    cartController.removeFromCart(item),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Total: ${cartController.totalPrice} BDT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
