// ignore_for_file: deprecated_member_use

import 'package:bluebite/Mobile%20Screen/liveorder.dart';
import 'package:bluebite/Mobile%20Screen/mobilehomepage.dart';
import 'package:bluebite/Mobile%20Screen/mobileoffer.dart';
import 'package:bluebite/Mobile%20Screen/prebookorder.dart';
import 'package:bluebite/Mobile%20Screen/review.dart';
import 'package:bluebite/cartcontroller.dart';
import 'package:bluebite/firebasequery.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../Mobile Screen/mobilecart.dart';

GetxCtrl controller = Get.put(GetxCtrl());

CartController cartController = Get.put(CartController());

Widget customDrawer(BuildContext context) {
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
                      color: Colors.white24, // placeholder for logo
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
              SizedBox(height: 40.h),

              _drawerItem(
                context,
                icon: Icons.home,
                title: "Home",
                onTap: () {
                  Get.to(()=> MobileHomepage());
                },
              ),

               _drawerItem(
                context,
                icon: Icons.shop,
                title: "Cart",
                onTap: () {
                  Get.to(()=> CartPageMobile());
                },
              ),


              _drawerItem(
  context,
  icon: Icons.shopping_cart_outlined,
  title: "Live Order",
  onTap: () async {
    String? selectedTable;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Text(
            "Select Table Number",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
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
                  Get.off(() => LiveOrderPage(
                        tableNo: selectedTable!,
                        selectedtype: "Inhouse",
                      ));
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  },
),

              _drawerItem(
  context,
  icon: Icons.shopping_cart_outlined,
  title: "Prebooked Order",
  onTap: () async {
    String? selectedTable;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Text(
            "Select Table Number",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
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
                  Get.off(() => Prebookorder(
                        tableNo: selectedTable!,
                        selectedtype: "Prebooking",
                      ));
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  },
),

    
              _drawerItem(
                context,
                icon: Icons.local_offer_outlined,
                title: "Offers",
                onTap: () {
                  Get.to(()=> MobileOfferpage());
                },
              ),
              _drawerItem(
                context,
                icon: Icons.reviews,
                title: "Reviews",
                onTap: () {
                  Get.to(()=> CustomerReview());
                },
              ),

              const Spacer(),

              // Footer
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
Widget _drawerItem(
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
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              prefixIcon: Icon(Icons.search, color: Color(0xFF1976D2)),
              hintText: "Search...",
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 16.sp),
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
        height: 180.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return CarouselSlider.builder(
      itemCount: controller.imageurls.length,
      itemBuilder: (context, index, realIndex) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: 400.w,

            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            child: Image.network(controller.imageurls[index], fit: BoxFit.fill),
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

Widget tabitems() {
  return Obx(() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: List.generate(controller.tabs.length, (index) {
        bool isSelected = controller.tabindex.value == index;
        String categoryName = controller.tabs[index];
        return GestureDetector(
          onTap: () {
            controller.selectedCategory.value = categoryName;
            controller.fetchMenuItems(categoryName);
            controller.tabindex.value = index;
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Text(
              controller.tabs[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue.shade900,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  });
}

Widget tabScreen() {
  return Obx(() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError.value) {
      return Center(
        child: Text(
          "Error: ${controller.errorMessage.value}",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (controller.menuItems.isEmpty) {
      return const Center(child: Text("No items available"));
    }

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.menuItems.length,
        itemBuilder: (context, index) {
          final item = controller.menuItems[index];
          final imageUrl = item.imgUrl;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),

            elevation: 5,
            shadowColor: Colors.blue.withOpacity(0.3),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(Icons.broken_image, size: 40.sp),
                              ),
                            ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "৳${item.price}",
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add to Cart Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  child: InkWell(
                    onTap: ()  {
                       cartController.addToCart(item);
                      Get.snackbar(
                        "Added to Cart",
                        "${item.name} added successfully!",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.shade600,
                        colorText: Colors.white,
                        margin: EdgeInsets.all(10.r),
                      );
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
          );
        },
      ),
    );
  });
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
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            height: 1.4,
          ),
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
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.sp,
                ),
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
      style: TextStyle(
        color: Colors.white70,
        fontSize: 13.sp,
      ),
    );
  }

