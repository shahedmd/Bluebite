// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:bluebite/Web%20Screen/responsiveappbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../bottomnav.dart';
import '../cartcontroller.dart';
import '../firebasequery.dart';
import 'customobject.dart';

class CartPageWeb extends StatelessWidget {
  CartPageWeb({super.key});

  final CartController cartController = Get.put(CartController());
  final GetxCtrl controller = Get.put(GetxCtrl());

  // Reactive state variables
  final RxString selectedTable = '1'.obs;
  final RxString selectedOrderType = 'Inhouse'.obs;
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();
  final RxBool fromHome = false.obs; // Home Delivery toggle
  final RxString deliveryName = ''.obs;
  final RxString deliveryPhone = ''.obs;
  final RxString deliveryAddress = ''.obs;

  final List<String> tables = List.generate(20, (index) => '${index + 1}');
  final List<String> orderTypes = ['Inhouse', 'Prebooking', 'Home Delivery'];

  // Controllers for dialogs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final themeColor = Colors.blue.shade800;
  final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomNavbar(),
            SizedBox(height: 50.h),

            /// ----------------- Table & Order Type Selection -----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: centeredContent(
                child: Obx(
                  () => Row(
                    children: [
                      // Order Type Dropdown
                      DropdownButton<String>(
                        value: selectedOrderType.value,
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

                          if (val == 'Inhouse') {
                            deliveryName.value = '';
                            deliveryPhone.value = '';
                            deliveryAddress.value = '';
                          }
                        },
                      ),
                      SizedBox(width: 20.w),

                      // Home Delivery toggle
                      if (selectedOrderType.value == 'Home Delivery')
                        Row(
                          children: [
                            const Text("From Home"),
                            SizedBox(width: 6.w),
                            Obx(() => Switch(
                                  value: fromHome.value,
                                  onChanged: (val) => fromHome.value = val,
                                  activeColor: themeColor,
                                )),
                          ],
                        ),
                      SizedBox(width: 20.w),

                      // Table Dropdown
                      if ((selectedOrderType.value != 'Home Delivery') ||
                          (selectedOrderType.value == 'Home Delivery' &&
                              !fromHome.value))
                        DropdownButton<String>(
                          value: selectedTable.value,
                          items: tables
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text('Table $t'),
                                  ))
                              .toList(),
                          onChanged: (val) => selectedTable.value = val!,
                        ),

                      // Prebooking selected datetime
                      if (selectedOrderType.value == 'Prebooking' &&
                          selectedDateTime.value != null)
                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.clock,
                                size: 16.sp,
                                color: themeColor,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                dateFormat.format(selectedDateTime.value!),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: themeColor,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              TextButton.icon(
                                onPressed: () async => await _pickDateTime(context),
                                icon: FaIcon(FontAwesomeIcons.pen, size: 14.sp),
                                label: const Text('Change'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            /// ----------------- Cart Items & Total -----------------
            centeredContent(
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Cart Items
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

                          if (cartController.cartItems.isEmpty)
                            Center(
                              child: Text(
                                'Cart is empty',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          ...cartController.cartItems.map((item) {
                            final hasVariant = item.selectedVariant != null;
                            final unitPrice =
                                hasVariant ? item.selectedVariant!.price : (item.price ?? 0);
                            final variantText = hasVariant ? "(${item.selectedVariant!.size})" : "";

                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 12.h),
                              shadowColor: Colors.blue.shade100,
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        color: Colors.grey.shade200,
                                        child: item.imgUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: item.imgUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    Container(color: Colors.grey.shade300),
                                                errorWidget: (_, __, ___) =>
                                                    const Icon(Icons.broken_image),
                                              )
                                            : Icon(
                                                Icons.broken_image,
                                                size: 40.sp,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${item.name} $variantText",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            "${item.quantity} × $unitPrice BDT",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "Subtotal: ${unitPrice * item.quantity} BDT",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.minus,
                                            size: 16.sp,
                                            color: themeColor,
                                          ),
                                          onPressed: () =>
                                              cartController.decreaseQuantity(item),
                                        ),
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.plus,
                                            size: 16.sp,
                                            color: themeColor,
                                          ),
                                          onPressed: () =>
                                              cartController.increaseQuantity(item),
                                        ),
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.trash,
                                            size: 16.sp,
                                            color: Colors.red.shade700,
                                          ),
                                          onPressed: () =>
                                              cartController.removeFromCart(item),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(width: 30.w),

                    /// Total + Confirm Order
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
                            Obx(
                              () => Text(
                                '${cartController.totalPrice} BDT',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  String? tableNoToSend = selectedTable.value;
                                  if (selectedOrderType.value == 'Home Delivery' &&
                                      fromHome.value) {
                                    tableNoToSend = null;
                                  }

                                  Map<String, String>? delivery;
                                  if (selectedOrderType.value == 'Home Delivery' ||
                                      selectedOrderType.value == 'Prebooking') {
                                    delivery = await _showDeliveryDialog(context);
                                    if (delivery == null) return;

                                    deliveryName.value = delivery['name']!;
                                    deliveryPhone.value = delivery['phone']!;
                                    deliveryAddress.value = delivery['address']!;
                                  }

                                  DateTime? finalDateTime = selectedDateTime.value;

                                  await controller.confirmOrder(
                                    tableNoToSend ?? '',
                                    selectedOrderType.value,
                                    context,
                                    finalDateTime,
                                    deliveryName: deliveryName.value.isEmpty
                                        ? null
                                        : deliveryName.value,
                                    deliveryPhone: deliveryPhone.value.isEmpty
                                        ? null
                                        : deliveryPhone.value,
                                    deliveryAddress: deliveryAddress.value.isEmpty
                                        ? null
                                        : deliveryAddress.value,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.cartShopping,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    const Text(
                                      'Confirm Order',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
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

  /// ----------------- PICK DATE & TIME -----------------
  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: themeColor),
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
          colorScheme: ColorScheme.light(primary: themeColor),
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

  /// ----------------- DELIVERY INFO DIALOG -----------------
  Future<Map<String, String>?> _showDeliveryDialog(BuildContext context) async {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    String? error;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delivery Details'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  SizedBox(height: 8.h),
                  TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
                  SizedBox(height: 8.h),
                  TextField(controller: addressController, maxLines: 3, decoration: const InputDecoration(labelText: 'Address')),
                  if (error != null) ...[
                    SizedBox(height: 8.h),
                    Text(error!, style: TextStyle(color: Colors.red.shade700)),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final address = addressController.text.trim();

                  if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                    setState(() => error = 'Please fill all fields');
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
        },
      ),
    );
  }
}
