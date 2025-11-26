// ignore_for_file: use_build_context_synchronously

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

class CartPageWeb extends StatefulWidget {
  const CartPageWeb({super.key});

  @override
  State<CartPageWeb> createState() => _CartPageWebState();
}

class _CartPageWebState extends State<CartPageWeb> {
  final CartController cartController = Get.put(CartController());
  final GetxCtrl controller = Get.put(GetxCtrl());

  final List<String> tables = List.generate(20, (index) => '${index + 1}');
  final List<String> orderTypes = ['Inhouse', 'Prebooking', 'Home Delivery'];

  String selectedTable = '1';
  String selectedOrderType = 'Inhouse';
  DateTime? selectedDateTime; // for prebooking

  // Home/Prebooking order info
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade800;
    final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomNavbar(),
            SizedBox(height: 50.h),

            // Table & Order Type selection
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

                    // Show selected datetime if prebooking
                    if (selectedOrderType == 'Prebooking' &&
                        selectedDateTime != null)
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
                              dateFormat.format(selectedDateTime!),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: themeColor,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            TextButton.icon(
                              onPressed:
                                  () async => await _pickDateTime(context),
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
                          ...cartController.cartItems.map((item) {
                            final bool hasVariant =
                                item.selectedVariant != null;
                            final double unitPrice =
                                hasVariant
                                    ? item.selectedVariant!.price
                                    : (item.price ?? 0);
                            final String variantText =
                                hasVariant
                                    ? "(${item.selectedVariant!.size})"
                                    : "";

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
                                    /// IMAGE ------------------------------
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Container(
                                        width: 100.w,
                                        height: 100.w,
                                        color: Colors.grey.shade200,
                                        child:
                                            item.imgUrl.isNotEmpty
                                                ? CachedNetworkImage(
                                                  imageUrl: item.imgUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (context, url) =>
                                                          Container(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                  errorWidget:
                                                      (_, __, ___) =>
                                                          const Icon(
                                                            Icons.broken_image,
                                                          ),
                                                )
                                                : Icon(
                                                  Icons.broken_image,
                                                  size: 40.sp,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),

                                    SizedBox(width: 20.w),

                                    /// ITEM DETAILS ------------------------------
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// Name + Variant
                                          Text(
                                            "${item.name} $variantText",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),

                                          /// Price display
                                          Text(
                                            "${item.quantity} × $unitPrice BDT",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),

                                          /// Total price of this line item
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

                                    /// BUTTONS ------------------------------
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.minus,
                                            size: 16.sp,
                                            color: themeColor,
                                          ),
                                          onPressed:
                                              () => cartController
                                                  .decreaseQuantity(item),
                                        ),
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.plus,
                                            size: 16.sp,
                                            color: themeColor,
                                          ),
                                          onPressed:
                                              () => cartController
                                                  .increaseQuantity(item),
                                        ),
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.trash,
                                            size: 16.sp,
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
                            );
                          }),
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
                                onPressed: () async {
                                  // If order type is Prebooking or Home Delivery, show dialog
                                  Map<String, String>? orderInfo;
                                  if (selectedOrderType != 'Inhouse') {
                                    orderInfo = await _showOrderInfoDialog(
                                      context,
                                    );
                                    if (orderInfo == null) return; // Cancelled
                                  }

                                  // Confirm order
                                  controller.confirmOrder(
                                    selectedTable,
                                    selectedOrderType,
                                    context,
                                    selectedDateTime,
                                    deliveryName: orderInfo?['name'],
                                    deliveryPhone: orderInfo?['phone'],
                                    deliveryAddress: orderInfo?['address'],
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

  // Dialog for Prebooking / Home Delivery order info
  Future<Map<String, String>?> _showOrderInfoDialog(
    BuildContext context,
  ) async {
    nameController.clear();
    phoneController.clear();
    addressController.clear();

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Order Information'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }
                  Navigator.of(context).pop({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'address': addressController.text,
                  });
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }
}
