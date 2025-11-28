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
  final List<String> orderTypes = ['Inhouse', 'Prebooking', "Home Delivery"];

  final RxString selectedTable = '1'.obs;
  final RxString selectedOrderType = 'Inhouse'.obs;
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();
  final RxBool fromHome = false.obs; // Toggle for Home Delivery

  // Your payment accounts
  final String bkashNumber = "01XXXXXXXXX";
  final String nagadNumber = "01XXXXXXXXX";
  final String bankDetails = "Bank Name: ABC Bank\nAccount: 1234567890";

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;

    return Scaffold(
      drawer: customDrawer(context),
      floatingActionButton: SizedBox(
        width: 200.w,
        height: 56.h,
        child: FloatingActionButton.extended(
          onPressed: () async {
            // 1️⃣ Show payment bottom sheet first
            final paymentData = await _showPaymentBottomSheet(context);
            if (paymentData == null) return; // User cancelled

            String? tableNoToSend = selectedTable.value;
            if (selectedOrderType.value == 'Home Delivery' && fromHome.value) {
              tableNoToSend = null; // From Home, no table
            }

            // Delivery info
            Map<String, String>? delivery;
            if (selectedOrderType.value == 'Home Delivery' ||
                selectedOrderType.value == 'Prebooking') {
              delivery = await _showDeliveryDialog(context);
              if (delivery == null) return;
            }

            // Prebooking date picker
            DateTime? finalDateTime = selectedDateTime.value;
            if (selectedOrderType.value == 'Prebooking') {
              if (selectedDateTime.value == null) {
                await _pickDateTime(context);
                if (selectedDateTime.value == null) return;
                finalDateTime = selectedDateTime.value;
              }
            }

            // Confirm Order
            await controller.confirmOrder(
              tableNoToSend ?? '', // If null, confirmOrder handles it
              selectedOrderType.value,
              context,
              finalDateTime,
              deliveryName: delivery?['name'],
              deliveryPhone: delivery?['phone'],
              deliveryAddress: delivery?['address'],
              paymentMethod: paymentData['method'],
              transactionId: paymentData['transactionId'],
            );
          },
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
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Order Type Dropdown
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: themeColor),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: DropdownButton<String>(
                              value: selectedOrderType.value,
                              underline: const SizedBox(),
                              isExpanded: true,
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

                                if (val != 'Home Delivery') fromHome.value = false;
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Home Delivery toggle only visible if Home Delivery selected
                        if (selectedOrderType.value == 'Home Delivery')
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Text("From Home"),
                                SizedBox(width: 6.w),
                                Obx(() => Switch(
                                      value: fromHome.value,
                                      onChanged: (val) => fromHome.value = val,
                                      activeColor: themeColor,
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Table Dropdown, visible only if not fromHome or Inhouse/Prebooking
                    if ((selectedOrderType.value != 'Home Delivery') ||
                        (selectedOrderType.value == 'Home Delivery' && !fromHome.value))
                      Row(
                        children: [
                          Text('Select Table:'),
                          SizedBox(width: 8.w),
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
                        ],
                      ),

                    // Prebooking selected date display
                    if (selectedOrderType.value == 'Prebooking' &&
                        selectedDateTime.value != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
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
                      ),
                  ],
                )),

            SizedBox(height: 10.h),

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

  // -------- HELPER: SHOW DELIVERY DIALOG --------
  Future<Map<String, String>?> _showDeliveryDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String? error;

    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delivery Details'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: addressCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  if (error != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  final address = addressCtrl.text.trim();

                  if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                    setState(() {
                      error = 'Please fill all fields';
                    });
                    return;
                  }

                  Navigator.of(context).pop({
                    'name': name,
                    'phone': phone,
                    'address': address,
                  });
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );

    return result;
  }

  // -------- HELPER: SHOW PAYMENT BOTTOM SHEET --------
  Future<Map<String, String>?> _showPaymentBottomSheet(BuildContext context) async {
    final transactionCtrl = TextEditingController();
    final RxString selectedMethod = 'Cash'.obs;

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 12.w,
                  children: ['Cash', 'Bkash', 'Nagad', 'Bank'].map((method) {
                    return ChoiceChip(
                      label: Text(method),
                      selected: selectedMethod.value == method,
                      onSelected: (_) {
                        setState(() {
                          selectedMethod.value = method;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
                if (selectedMethod.value == 'Bkash' || selectedMethod.value == 'Nagad' || selectedMethod.value == 'Bank')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            selectedMethod.value == 'Bkash'
                                ? FontAwesomeIcons.b
                                : selectedMethod.value == 'Nagad'
                                    ? FontAwesomeIcons.moneyBillWave
                                    : FontAwesomeIcons.building,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            selectedMethod.value == 'Bkash'
                                ? "Send money to: $bkashNumber"
                                : selectedMethod.value == 'Nagad'
                                    ? "Send money to: $nagadNumber"
                                    : "Bank Details:\n$bankDetails",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "After sending money, enter your ${selectedMethod.value} transaction ID / number below:",
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: transactionCtrl,
                        decoration: InputDecoration(
                          labelText: '${selectedMethod.value} Transaction ID',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Cancel'),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () {
                        if ((selectedMethod.value == 'Bkash' || selectedMethod.value == 'Nagad' || selectedMethod.value == 'Bank') &&
                            transactionCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Transaction ID Required',
                            'Please enter your transaction number',
                            backgroundColor: Colors.red.shade400,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Navigator.pop(context, {
                          'method': selectedMethod.value,
                          'transactionId': transactionCtrl.text.trim(),
                        });
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );

    return result;
  }
}
