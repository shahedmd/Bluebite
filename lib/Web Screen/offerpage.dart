// ignore_for_file: deprecated_member_use

import 'package:bluebite/bottomnav.dart';
import 'package:bluebite/menuitems.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../cartcontroller.dart';
import '../globalvar.dart';
import 'customobject.dart';
import 'responsiveappbar.dart';

class OfferPageWeb extends StatefulWidget {
  const OfferPageWeb({super.key});

  @override
  State<OfferPageWeb> createState() => _OfferPageWebState();
}

class _OfferPageWebState extends State<OfferPageWeb> {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(),

            centeredContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Optional: you can add a web slider here
                    // customSlide(1, 220), // if you have slider for web
                    SizedBox(height: 20.h),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('offers')
                          .where(
                            'validate',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(today),
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No active offers right now 😔'),
                          );
                        }

                        final offers = snapshot.data!.docs;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250.w,
                            crossAxisSpacing: 20.w,
                            mainAxisSpacing: 20.h,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            var data = offers[index].data() as Map<String, dynamic>;
                            String name = data['name'] ?? '';
                            double price = (data['price'] ?? 0).toDouble();
                            String imgUrl = data['imgUrl'] ?? '';
                            Timestamp validate = data['validate'];
                            DateTime validDate = validate.toDate();

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
                            child: imgUrl.isNotEmpty
                                ? Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 40),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "৳$price",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),

                              Text(
                                "Valid till : $validDate",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: InkWell(
                            onTap: () {
                              final menuitem = MenuItem(
                                    name: name,
                                    category: "Offer",
                                    price: price,
                                    imgUrl: imgUrl,
                                  );
                              cartController.addToCart(menuitem);
                              Get.snackbar(
                                "Added to Cart",
                                "$name added successfully!",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.blue.shade600,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(15),
                              );
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
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
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 100.h),
            BlueBiteBottomNavbar(),
          ],
        ),
      ),
    );
  }
}
