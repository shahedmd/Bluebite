// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Mobile Custom Object/customwidget.dart';
import '../cartcontroller.dart';
import '../firebasequery.dart';
import '../menuitems.dart';

GetxCtrl controller = Get.put(GetxCtrl());
CartController cartController = Get.put(CartController());

Widget centeredContent({required Widget child}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1310.w), // 👈 limits width
      child: child,
    ),
  );
}

Widget webCustomSlide() {
  return Obx(() {
    if (controller.haserror.value) {
      return Center(
        child: Text(
          "Error: ${controller.errormessage.value}",
          style: TextStyle(fontSize: 18.sp, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (controller.imageurls.isEmpty) {
      return centeredContent(
        child: SizedBox(
          height: 400.h,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Center(
      child: centeredContent(
        child: CarouselSlider.builder(
          itemCount: controller.imageurls.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
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
                      (context, url) =>
                          Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) =>
                          Center(child: Icon(Icons.error, color: Colors.red)),
                  fadeInDuration: Duration(milliseconds: 300),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 550.h,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              controller.currentIndex.value = index;
            },
          ),
        ),
      ),
    );
  });
}

Widget webCustomDot() {
  return Obx(
    () => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.imageurls.length, (index) {
        bool isActive = controller.currentIndex.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: isActive ? 14.w : 10.w,
          height: isActive ? 14.w : 10.w,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1976D2) : Colors.grey,
            shape: BoxShape.circle,
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ]
                    : [],
          ),
        );
      }),
    ),
  );
}

Widget webTabItems() {
  return Obx(() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20.w,
      runSpacing: 15.h,
      children: List.generate(controller.tabs.length, (index) {
        bool isSelected =
            controller.searchQuery.value.isEmpty &&
            controller.tabindex.value == index;
        String categoryName = controller.tabs[index];

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              controller.searchCtrl.clear();
              controller.searchQuery.value = "";

              controller.selectedCategory.value = categoryName;
              controller.fetchMenuItems(categoryName);
              controller.tabindex.value = index;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                        ),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : [],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.blue.shade300,
                  width: 1.2,
                ),
              ),
              child: Text(
                categoryName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue.shade900,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );
      }),
    );
  });
}

Widget tabScreenWeb() {
  return Obx(() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError.value) {
      return Center(
        child: Text(
          "Error: ${controller.errorMessage.value}",
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    if (controller.menuItems.isEmpty) {
      return Center(
        child: Text(
          controller.searchQuery.value.isNotEmpty
              ? "No items found for '${controller.searchQuery.value}'"
              : "No items available",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: centeredContent(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount =
                constraints.maxWidth > 1400
                    ? 5
                    : constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 800
                    ? 3
                    : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.78,
              ),
              itemCount: controller.menuItems.length,
              itemBuilder: (context, index) {
                final item = controller.menuItems[index];
                final imageUrl = item.imgUrl;

                bool hasVariants =
                    item.variants != null && item.variants!.isNotEmpty;

                // Default selected variant
                MenuVariant? selectedVariant =
                    hasVariants ? item.variants!.first : null;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child:
                                    imageUrl.isNotEmpty
                                        ? GestureDetector(
                                          onTap:
                                              () => showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder:
                                                    (_) => FullScreenImageView(
                                                      imageUrl: imageUrl,
                                                    ),
                                              ),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                        : Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                              ),
                            ),

                            // NAME
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),

                                  // 🔥 PRICE / VARIANTS UI HERE
                                  if (!hasVariants)
                                    Text(
                                      "৳${item.price}",
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Select Size",
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        // 🔥 VARIANT DROPDOWN
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade300,
                                            ),
                                          ),
                                          child: DropdownButton<MenuVariant>(
                                            value: selectedVariant,
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            items:
                                                item.variants!.map((v) {
                                                  return DropdownMenuItem(
                                                    value: v,
                                                    child: Text(
                                                      "${v.size} - ৳${v.price}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                selectedVariant = val!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // ADD TO CART BUTTON
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (hasVariants) {
                                    // Send variant item to cart
                                    cartController.addVariantToCart(
                                      item,
                                      selectedVariant!,
                                    );
                                  } else {
                                    cartController.addToCart(item);
                                  }

                                  Get.snackbar(
                                    "Added to Cart",
                                    "${item.name} added successfully!",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.blue.shade600,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(15),
                                  );
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Add to Cart",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
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
                  },
                );
              },
            );
          },
        ),
      ),
    );
  });
}
