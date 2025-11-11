// ignore_for_file: avoid_unnecessary_containers

import 'package:bluebite/Web%20Screen/customobject.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'liveorder.dart';
import 'offerpage.dart';
import 'preebooked.dart';
import 'review.dart';
import 'webcart.dart';
import 'webhomepage.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      // Use your existing drawer on mobile
      return const SizedBox.shrink();
    }

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
        child: Row(
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
                  () => Get.to(() => const CartPageWeb()),
                ),
                _navDialogItem(
                  context,
                  "Live Order",
                  Icons.shopping_cart_outlined,
                  "Inhouse",
                ),
                _navDialogItem(
                  context,
                  "Prebooked Order",
                  Icons.table_bar,
                  "Prebooking",
                ),
                _navItem(
                  "Offers",
                  Icons.local_offer_outlined,
                  () => Get.to(() => const OfferPageWeb()),
                ),
                _navItem(
                  "Reviews",
                  Icons.reviews,
                  () => Get.to(() => const CustomerReviewWeb()),
                ),
              ],
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

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                "Select Table Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                  fontSize: 18.sp,
                ),
              ),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
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
                    if (selectedTable != null) {
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
                          ),
                          preventDuplicates: false,
                        );
                      }
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
