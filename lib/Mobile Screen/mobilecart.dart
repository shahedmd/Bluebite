// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:bluebite/Mobile%20Custom%20Object/customwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../cartcontroller.dart';
import '../firebasequery.dart';

class CartPageMobile extends StatelessWidget {
  CartPageMobile({super.key});

  final CartController cartController = Get.put(CartController());
  final GetxCtrl controller = Get.put(GetxCtrl());

  final List<String> tables = List.generate(20, (index) => '${index + 1}');
  final List<String> orderTypes = ['Inhouse', 'Prebooking'];

  final RxString selectedTable = '1'.obs;
  final RxString selectedOrderType = 'Inhouse'.obs;
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();

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
                selectedTable.value,
                selectedOrderType.value,
                context,
                selectedDateTime.value,
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
        title: Text(
          'Blue Bite Restaurant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
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
            // -------- TABLE & ORDER TYPE SELECTOR --------
            Obx(() => Row(
                  children: [
                    // Table Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeColor),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButton<String>(
                        value: selectedTable.value,
                        underline: const SizedBox(),
                        items: tables
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text('Table $t'),
                                ))
                            .toList(),
                        onChanged: (val) => selectedTable.value = val!,
                      ),
                    ),
                    SizedBox(width: 20.w),

                    // Order Type Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeColor),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButton<String>(
                        value: selectedOrderType.value,
                        underline: const SizedBox(),
                        items: orderTypes
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ))
                            .toList(),
                        onChanged: (val) async {
                          selectedOrderType.value = val!;
                          if (val == 'Prebooking') {
                            await _pickDateTime(context);
                          } else {
                            selectedDateTime.value = null;
                          }
                        },
                      ),
                    ),
                  ],
                )),

            // Selected DateTime for Prebooking
            Obx(() => selectedOrderType.value == 'Prebooking' &&
                    selectedDateTime.value != null
                ? Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.calendarAlt, color: Colors.blue),
                        SizedBox(width: 8.w),
                        Text(
                          'Selected: ${selectedDateTime.value!.toString().substring(0, 16)}',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () async => await _pickDateTime(context),
                          icon: const FaIcon(FontAwesomeIcons.edit, size: 18),
                          label: const Text('Change'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()),

            SizedBox(height: 10.h),

            // -------- CART ITEMS LIST --------
            Expanded(
              child: Obx(() {
                if (cartController.cartItems.isEmpty) {
                  return Center(
                    child: Text(
                      'Cart is empty',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView(
                  children: [
                    Text(
                      'Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: themeColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...cartController.cartItems.map(
                      (item) => Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: ListTile(
                          leading: FaIcon(FontAwesomeIcons.utensils, color: themeColor),
                          title: Text(
                            item.name +
                                (item.selectedVariant != null
                                    ? " (${item.selectedVariant!.size})"
                                    : ""),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.selectedVariant != null)
                                Text(
                                  "Variant Price: ${item.selectedVariant!.price} BDT",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              Text(
                                "Qty: ${item.quantity} — ${(item.selectedVariant != null ? item.selectedVariant!.price : item.price ?? 0) * item.quantity} BDT",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.minus, color: themeColor, size: 18.sp),
                                onPressed: () => cartController.decreaseQuantity(item),
                              ),
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.plus, color: themeColor, size: 18.sp),
                                onPressed: () => cartController.increaseQuantity(item),
                              ),
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.trashAlt, color: Colors.red.shade700, size: 18.sp),
                                onPressed: () => cartController.removeFromCart(item),
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // -------- HELPER: PICK DATE & TIME --------
  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade800),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade800),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    selectedDateTime.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}
