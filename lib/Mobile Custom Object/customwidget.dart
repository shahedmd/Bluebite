// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bluebite/Mobile%20Screen/homedelivermobile.dart';
import 'package:bluebite/Mobile%20Screen/liveorder.dart';
import 'package:bluebite/Mobile%20Screen/mobilehomepage.dart';
import 'package:bluebite/Mobile%20Screen/mobileoffer.dart';
import 'package:bluebite/Mobile%20Screen/prebookorder.dart';
import 'package:bluebite/cartcontroller.dart';
import 'package:bluebite/firebasequery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../Mobile Screen/mobilecart.dart';
import '../menuitems.dart';

class DrawerControllerX extends GetxController {
  var selectedTable = RxnString();
  var selectedSlot = Rxn<DateTime>();
}

GetxCtrl controller = Get.put(GetxCtrl());

CartController cartController = Get.put(CartController());

Widget customDrawer(BuildContext context) {
  final drawerCtrl = Get.put(DrawerControllerX());

  final primaryBlue = Color(0xFF1976D2);

  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: Colors.white, size: 20.sp),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
      onTap: onTap,
    );
  }

  Future<void> showInhouseDialog() async {
    drawerCtrl.selectedTable.value = null;
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Select Table Number",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        content: Obx(() {
          return DropdownButtonFormField<String>(
            value: drawerCtrl.selectedTable.value,
            hint: const Text("Choose table"),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
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
              drawerCtrl.selectedTable.value = value;
            },
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              if (drawerCtrl.selectedTable.value != null) {
                Get.back();
                Get.to(
                  () => LiveOrderPage(
                    tableNo: drawerCtrl.selectedTable.value!,
                    selectedtype: "Inhouse",
                  ),
                  preventDuplicates: false,
                );
              } else {
                Get.snackbar(
                  'Missing Info',
                  'Please select a table',
                  backgroundColor: Colors.red.shade300,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> showCustomerInfoDialog() async {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController phoneNumber = TextEditingController();

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Customer Information",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Customer Name",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: phoneNumber,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Customer Phone",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneNumber.text.isNotEmpty) {
                Get.back();

                // Navigate or process data
                Get.to(
                  () => Homedelivermobile(
                    customerName: nameCtrl.text.trim(),
                    customerPhone: phoneNumber.text.trim(),
                    selectedtype: "Home Delivery",
                  ),
                  preventDuplicates: false,
                );
              } else {
                Get.snackbar(
                  'Missing Info',
                  'Please enter all details',
                  backgroundColor: Colors.red.shade300,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> showPrebookDialog() async {
    drawerCtrl.selectedTable.value = null;
    drawerCtrl.selectedSlot.value = null;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Select Table & Timeslot",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        content: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: drawerCtrl.selectedTable.value,
                hint: const Text("Choose table"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
                  drawerCtrl.selectedTable.value = value;
                },
              ),
              SizedBox(height: 12.h),
              // Timeslot picker
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
                ),
                onPressed: () async {
                  DateTime now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: now.hour,
                        minute: now.minute,
                      ),
                    );
                    if (time != null) {
                      drawerCtrl.selectedSlot.value = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
                child: Text(
                  drawerCtrl.selectedSlot.value != null
                      ? "Selected: ${drawerCtrl.selectedSlot.value!.day}/${drawerCtrl.selectedSlot.value!.month}/${drawerCtrl.selectedSlot.value!.year} ${drawerCtrl.selectedSlot.value!.hour.toString().padLeft(2, '0')}:${drawerCtrl.selectedSlot.value!.minute.toString().padLeft(2, '0')}"
                      : "Select Timeslot",
                  style: TextStyle(color: Colors.black87, fontSize: 11.sp),
                ),
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              if (drawerCtrl.selectedTable.value != null &&
                  drawerCtrl.selectedSlot.value != null) {
                Get.back();
                Get.to(
                  () => Prebookorder(
                    tableNo: drawerCtrl.selectedTable.value!,
                    selectedtype: "Prebooking",
                    timeslot: drawerCtrl.selectedSlot.value!,
                  ),
                  preventDuplicates: false,
                );
              } else {
                Get.snackbar(
                  'Missing Info',
                  'Please select both table and timeslot',
                  backgroundColor: Colors.red.shade300,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  return Drawer(
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.utensils,
                        color: Colors.white,
                      ),
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
              SizedBox(height: 40.h),

              drawerItem(
                icon: FontAwesomeIcons.house,
                title: "Home",
                onTap: () => Get.to(() => MobileHomepage()),
              ),
              drawerItem(
                icon: FontAwesomeIcons.cartShopping,
                title: "Cart",
                onTap: () => Get.to(() => CartPageMobile()),
              ),
              drawerItem(
                icon: FontAwesomeIcons.bowlFood,
                title: "Inhouse Order Status",
                onTap: showInhouseDialog,
              ),
              drawerItem(
                icon: FontAwesomeIcons.calendarCheck,
                title: "Prebooked Order Status",
                onTap: showPrebookDialog,
              ),
              drawerItem(
                icon: FontAwesomeIcons.truck,
                title: "Home Deliver Order Status",
                onTap: showCustomerInfoDialog,
              ),
              drawerItem(
                icon: FontAwesomeIcons.tag,
                title: "Offers",
                onTap: () => Get.to(() => MobileOfferpage()),
              ),

              const Spacer(),

              Divider(color: Colors.white54, thickness: 1),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  "© 2025 Blue Bite Restaurant",
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Drawer Item Widget
Widget drawerItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required Function onTap,
}) {
  return InkWell(
    onTap: () => onTap(),
    borderRadius: BorderRadius.circular(10.r),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(width: 18.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

PreferredSizeWidget customAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Color(0xFF1976D2),
    elevation: 4,
    centerTitle: true,
    title: Text(
      "Blue Bite Restaurant",
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Container(
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
          child: Obx(
            () => TextField(
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.searchProducts(value);
              },

              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(fontSize: 16.sp),
                border: InputBorder.none,
                prefix: Padding(
                  padding: EdgeInsets.only(left: 10.w, right: 8.w),
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
                suffixIcon:
                    controller.isSearching.value
                        ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget customSlide(double fraction, double slideheight) {
  return Obx(() {
    if (controller.haserror.value) {
      return Center(
        child: Text(
          "Error: ${controller.errormessage.value}",
          style: TextStyle(fontSize: 16.sp, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (controller.imageurls.isEmpty) {
      return SizedBox(
        height: slideheight.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return CarouselSlider.builder(
      itemCount: controller.imageurls.length,
      itemBuilder: (context, index, realIndex) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: controller.imageurls[index],
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              errorWidget:
                  (context, url, error) =>
                      Center(child: Icon(Icons.error, color: Colors.red)),
              fadeInDuration: Duration(milliseconds: 300),

              // ADD THESE LINES TO REDUCE MEMORY USAGE
              memCacheWidth: 300, // resize image in memory
              memCacheHeight: 200, // resize image in memory
              maxWidthDiskCache: 600, // limit cache size
              maxHeightDiskCache: 400,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: slideheight.h,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: fraction,
        enableInfiniteScroll: true,
        onPageChanged: (index, reason) {
          controller.currentIndex.value = index;
        },
      ),
    );
  });
}

Widget customDot() {
  return Obx(
    () => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.imageurls.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: controller.currentIndex.value == index ? 12.w : 8.w,
          height: controller.currentIndex.value == index ? 12.w : 8.w,
          decoration: BoxDecoration(
            color:
                controller.currentIndex.value == index
                    ? Colors.blueAccent
                    : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    ),
  );
}

Widget tabItems() {
  return Obx(() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
      child: Wrap(
        alignment: WrapAlignment.center, // <-- Centers horizontally
        runAlignment: WrapAlignment.center, // <-- Centers each wrap line
        spacing: 10.w,
        runSpacing: 10.h,
        children: List.generate(controller.tabs.length, (index) {
          final categoryName = controller.tabs[index];
          final bool isSelected =
              controller.searchQuery.value.isEmpty &&
              controller.tabindex.value == index;

          return GestureDetector(
            onTap: () {
              controller.searchCtrl.clear();
              controller.searchQuery.value = "";
              controller.selectedCategory.value = categoryName;
              controller.fetchMenuItems(categoryName);
              controller.tabindex.value = index;
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF1976D2) : Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.r,
                              offset: Offset(0, 3.h),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF0D47A1),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  });
}

Widget tabScreen() {
  return Obx(() {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.hasError.value) {
      return Center(
        child: Text(
          "Error: ${controller.errorMessage.value}",
          style: TextStyle(color: Colors.red, fontSize: 14.sp),
        ),
      );
    }

    if (controller.menuItems.isEmpty) {
      return Center(
        child: Text(
          "No items available",
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(10.r),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            alignment: WrapAlignment.start,
            children: List.generate(controller.menuItems.length, (index) {
              final item = controller.menuItems[index];
              final imageUrl = item.imgUrl;

              return ConstrainedBox(
                constraints: BoxConstraints(minWidth: 130.w, maxWidth: 180.w),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        child:
                            imageUrl.isNotEmpty
                                ? SizedBox(
                                  height: 150.h,
                                  child: GestureDetector(
                                    onTap:
                                        () => showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder:
                                              (_) => FullScreenImageView(
                                                imageUrl: imageUrl,
                                              ),
                                        ),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Center(
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
                                      fadeInDuration: Duration(
                                        milliseconds: 300,
                                      ),

                                      // ADD THESE LINES TO REDUCE MEMORY USAGE
                                      memCacheWidth:
                                          300, // resize image in memory
                                      memCacheHeight:
                                          200, // resize image in memory
                                      maxWidthDiskCache:
                                          600, // limit cache size
                                      maxHeightDiskCache: 400,
                                    ),
                                  ),
                                )
                                : Container(
                                  height: 150.h,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40.sp,
                                    ),
                                  ),
                                ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.variants != null && item.variants!.isNotEmpty
                                  ? "From ৳${item.variants!.first.price}"
                                  : "৳${item.price ?? 0}",
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        child: InkWell(
                          onTap: () {
                            if (item.variants != null &&
                                item.variants!.isNotEmpty) {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.r),
                                  ),
                                ),
                                builder:
                                    (_) => VariantSelectorSheet(
                                      item: item,
                                      onVariantSelected: (variant) {
                                        cartController.addVariantToCart(
                                          item,
                                          variant,
                                        );
                                        Get.back();
                                        Get.snackbar(
                                          "Added to Cart",
                                          "${item.name} (${variant.size}) added!",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Color(0xFF1976D2),
                                          colorText: Colors.white,
                                        );
                                      },
                                    ),
                              );
                            } else {
                              cartController.addToCart(item);
                              Get.snackbar(
                                "Added to Cart",
                                "${item.name} added successfully!",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Color(0xFF1976D2),
                                colorText: Colors.white,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(30.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.r),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  });
}

class VariantSelectorSheet extends StatelessWidget {
  final MenuItem item;
  final Function(MenuVariant) onVariantSelected;

  const VariantSelectorSheet({
    super.key,
    required this.item,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Variant",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),

          ...item.variants!.map((v) {
            return ListTile(
              title: Text("${v.size} - ৳${v.price}"),
              onTap: () => onVariantSelected(v),
            );
          }),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

Widget buildLogoAndAbout(Color themeColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Blue Bite Restaurant",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8.h),
      Text(
        "Delicious meals made with love. Experience the best dining in town.",
        style: TextStyle(color: Colors.white70, fontSize: 14.sp, height: 1.4),
      ),
    ],
  );
}

Widget buildLinks() {
  final links = ["Home", "Menu", "About", "Contact"];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Quick Links",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10.h),
      ...links.map(
        (link) => Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: InkWell(
            onTap: () {},
            child: Text(
              link,
              style: TextStyle(color: Colors.white70, fontSize: 15.sp),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget buildSocialIcons(Color themeColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Follow Us",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10.h),
      Row(
        children: [
          socialButton(FontAwesomeIcons.facebookF, themeColor),
          SizedBox(width: 15.w),
          socialButton(FontAwesomeIcons.instagram, themeColor),
          SizedBox(width: 15.w),
          socialButton(FontAwesomeIcons.twitter, themeColor),
        ],
      ),
      SizedBox(height: 30.h),
      buildCopyright(),
    ],
  );
}

Widget socialButton(IconData icon, Color themeColor) {
  return Container(
    width: 40.w,
    height: 40.h,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5.r,
          offset: Offset(0, 3.h),
        ),
      ],
    ),
    child: Icon(icon, color: themeColor, size: 20.sp),
  );
}

Widget buildCopyright() {
  return Text(
    "© 2025 Blue Bite Restaurant. All Rights Reserved.",
    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
  );
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder:
                  (context, url) =>
                      CircularProgressIndicator(color: Colors.white),
              errorWidget:
                  (context, url, error) =>
                      Icon(Icons.broken_image, color: Colors.white, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
