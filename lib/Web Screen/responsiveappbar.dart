// ignore_for_file: avoid_unnecessary_containers, deprecated_member_use, use_build_context_synchronously

import 'package:bluebite/Web%20Screen/customobject.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'homedeliverweb.dart';
import 'liveorder.dart';
import 'offerpage.dart';
import 'preebooked.dart';
import 'webcart.dart';
import 'webhomepage.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor1 = const Color(0xFF0D47A1);
    final themeColor2 = const Color(0xFF1976D2);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor1, themeColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: centeredContent(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Get.to(() => WebHomepage()),
                  child: Row(
                    children: [
                      Container(
                        width: 45.w,
                        height: 45.w,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Center(
                          child: Icon(Icons.restaurant, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Blue Bite",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu items
                Row(
                  children: [
                    _navItem(
                      "Home",
                      Icons.home,
                      () => Get.to(() => const WebHomepage()),
                    ),
                    _navItem(
                      "Cart",
                      Icons.shop,
                      () => Get.to(() =>  CartPageWeb()),
                    ),
                    _navDialogItem(
                      context,
                      "Inhouse Order Status",
                      Icons.shopping_cart_outlined,
                      "Inhouse",
                    ),
                    _navDialogItem(
                      context,
                      "Prebooked Order Status",
                      Icons.table_bar,
                      "Prebooking",
                    ),
                    _navDialogItem(
                      context,
                      "Home Delivery Status",
                      Icons.table_bar,
                      "Home Delivery",
                    ),
                    _navItem(
                      "Offers",
                      Icons.local_offer_outlined,
                      () => Get.to(() => const OfferPageWeb()),
                    ),
                    
                  ],
                ),
              ],
            ),

            SizedBox(height: 15.h),
            SizedBox(
              width: 500.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Center(
                  child: TextField(
                    onChanged: (value) {
                      controller.searchQuery.value = value; // update text
                      controller.searchProducts(value); // start searching
                    },
                    decoration: InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _navDialogItem(
  BuildContext context,
  String title,
  IconData icon,
  String selectedType,
) {
  return InkWell(
    onTap: () async {
      String? selectedTable;
      DateTime? selectedTimeSlot;
      String customerName = '';
      String customerPhone = '';

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              selectedType == 'Home Delivery'
                  ? "Enter Customer Details"
                  : "Select Table Number${selectedType == 'Prebooking' ? ' & Time Slot' : ''}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1976D2),
                fontSize: 18.sp,
              ),
            ),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedType == "Home Delivery") ...[
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Customer Name",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            customerName = value;
                          });
                        },
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Customer Phone",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            customerPhone = value;
                          });
                        },
                      ),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        value: selectedTable,
                        hint: const Text("Choose table"),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: List.generate(
                          20,
                          (index) => DropdownMenuItem(
                            value: (index + 1).toString(),
                            child: Text("Table ${(index + 1)}"),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedTable = value;
                          });
                        },
                      ),
                      if (selectedType == "Prebooking") ...[
                        SizedBox(height: 12.h),
                        InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );

                            if (picked != null) {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (time != null) {
                                setState(() {
                                  selectedTimeSlot = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 14.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedTimeSlot != null
                                      ? "${selectedTimeSlot!.day}/${selectedTimeSlot!.month}/${selectedTimeSlot!.year} "
                                        "${selectedTimeSlot!.hour.toString().padLeft(2, '0')}:${selectedTimeSlot!.minute.toString().padLeft(2, '0')}"
                                      : "Select Time Slot",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Icon(Icons.access_time)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ]
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  if (selectedType == "Home Delivery") {
                    if (customerName.isNotEmpty && customerPhone.isNotEmpty) {
                      Navigator.pop(context);
                      Get.to(
                        () => DeliveryOrderWeb(
                          selectedtype: "Home Delivery",
                          customerName: customerName,
                          customerPhone: customerPhone,
                        ),
                        preventDuplicates: false,
                      );
                    } else {
                      Get.snackbar(
                        'Missing Fields',
                        'Please enter both name and phone',
                        backgroundColor: Colors.red.shade300,
                        colorText: Colors.white,
                      );
                    }
                  } else if (selectedTable != null &&
                      (selectedType != "Prebooking" || selectedTimeSlot != null)) {
                    Navigator.pop(context);
                    if (selectedType == "Inhouse") {
                      Get.to(
                        () => LiveOrderPageWeb(
                          tableNo: selectedTable!,
                          selectedtype: "Inhouse",
                        ),
                        preventDuplicates: false,
                      );
                    } else {
                      Get.to(
                        () => PrebookOrderWeb(
                          tableNo: selectedTable!,
                          selectedtype: "Prebooking",
                          timeslot: selectedTimeSlot!,
                        ),
                        preventDuplicates: false,
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Select all fields',
                      'Please choose table and timeslot',
                      backgroundColor: Colors.red.shade300,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

}