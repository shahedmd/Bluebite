// ignore_for_file: use_build_context_synchronously, avoid_types_as_parameter_names

import 'package:bluebite/Mobile%20Screen/prebookorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Mobile Screen/liveorder.dart';
import 'Web Screen/liveorder.dart';
import 'Web Screen/preebooked.dart';
import 'cartcontroller.dart';
import 'menuitems.dart';

class GetxCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getimageurls();
    fetchMenuItems("Fastfood");
    fetchCategories();
  }

  // ---------------------------------------------------------
  // SLIDER IMAGES
  // ---------------------------------------------------------
  var imageurls = [].obs;
  RxBool haserror = false.obs;
  var errormessage = "".obs;

  void getimageurls() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Slide-Images')
              .doc('Cr1A6feBfmafOp6QHsYL')
              .get();

      final List<dynamic> urls = doc.data()?['images'] ?? [];
      imageurls.value = urls.map((e) => e.toString()).toList();
    } catch (e) {
      haserror.value = true;
      errormessage.value = e.toString();
    }
  }

  // ---------------------------------------------------------
  // MAIN VARIABLES
  // ---------------------------------------------------------
  var currentIndex = 0.obs;
  var tabindex = 0.obs;

  var menuItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var selectedCategory = 'Fastfood'.obs;

  RxList<String> tabs = <String>[].obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CartController cartController = Get.put(CartController());

  // ---------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------
  TextEditingController searchCtrl = TextEditingController();
  RxString searchQuery = "".obs;

  Future<void> fetchCategories() async {
    try {
      final doc =
          await firestore
              .collection('category')
              .doc('VPSKqsQRbOLyz1aOloSG')
              .get();

      if (doc.exists) {
        List<dynamic> list = doc['categorylist'] ?? [];
        tabs.value = list.map((e) => e.toString()).toList();
      }
      if (tabs.isNotEmpty) {
        selectedCategory.value = tabs[0];
        fetchMenuItems(tabs[0]);
        tabindex.value = 0;
      }
    } catch (e) {
      Text("Error fetching categories: $e");
    }
  }

  Future<void> searchProducts(String keyword) async {
    try {
      keyword = keyword.trim().toLowerCase();
      searchQuery.value = keyword;

      isLoading.value = true;
      hasError.value = false;

      // If search is cleared → load category again
      if (keyword.isEmpty) {
        fetchMenuItems(selectedCategory.value);
        return;
      }

      // Load all items (for search filtering)
      final querySnapshot = await firestore.collection('menu').get();

      final List<MenuItem> allItems =
          querySnapshot.docs
              .map((doc) => MenuItem.fromMap(doc.data()))
              .toList();

      // Filter by name or category
      final results =
          allItems.where((item) {
            final name = item.name.toLowerCase();
            final category = item.category.toLowerCase();
            return name.contains(keyword) || category.contains(keyword);
          }).toList();

      menuItems.value = results;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------
  // FETCH NORMAL CATEGORY ITEMS
  // ---------------------------------------------------------
  Future<void> fetchMenuItems(String category) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final querySnapshot =
          await firestore
              .collection('menu')
              .where('category', isEqualTo: category)
              .get();

      menuItems.value =
          querySnapshot.docs
              .map((doc) => MenuItem.fromMap(doc.data()))
              .toList();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------

  Future<void> confirmOrder(
    String selectedTable,
    String selectedOrderType,
    BuildContext context,
    DateTime? selectedDateTime,
  ) async {
    final firestore = FirebaseFirestore.instance;

    // Check if cart is empty
    if (cartController.cartItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items before confirming order',
        backgroundColor: Colors.blue.shade200,
        colorText: Colors.white,
      );
      return;
    }

    // Prebooking MUST have a date/time
    if (selectedOrderType == 'Prebooking' && selectedDateTime == null) {
      Get.snackbar(
        'Select Date & Time',
        'Please choose date and time for your prebooking order',
        backgroundColor: Colors.blue.shade200,
        colorText: Colors.white,
      );
      return;
    }

    const slotDuration = Duration(hours: 2);

    try {
      // Show loading indicator
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // =============== PREBOOKING SLOT CHECK ===============
      if (selectedOrderType == 'Prebooking') {
        final newStart = selectedDateTime!;
        final newEnd = newStart.add(slotDuration);

        final existing =
            await firestore
                .collection('orders')
                .where('tableNo', isEqualTo: selectedTable)
                .where('orderType', isEqualTo: 'Prebooking')
                .where('status', whereIn: ['pending', 'processing'])
                .get();

        for (var doc in existing.docs) {
          final data = doc.data();
          final Timestamp? ts = data['prebookSlot'] as Timestamp?;
          if (ts == null) continue;

          final existingStart = ts.toDate();
          final existingEnd = existingStart.add(slotDuration);

          final overlap =
              newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart);

          if (overlap) {
            Get.back(); // close loading
            Get.snackbar(
              'Slot Unavailable',
              'Table already booked from '
                  '${existingStart.hour}:${existingStart.minute.toString().padLeft(2, '0')} to '
                  '${existingEnd.hour}:${existingEnd.minute.toString().padLeft(2, '0')}',
              backgroundColor: Colors.red.shade300,
              colorText: Colors.white,
            );
            return;
          }
        }
      }

      // =============== INHOUSE MERGE OR NEW ORDER ===============
      if (selectedOrderType == 'Inhouse') {
        final activeOrders =
            await firestore
                .collection('orders')
                .where('tableNo', isEqualTo: selectedTable)
                .where('orderType', isEqualTo: 'Inhouse')
                .where('status', whereIn: ['pending', 'processing'])
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get();

        if (activeOrders.docs.isNotEmpty) {
          final doc = activeOrders.docs.first;

          final items = List<Map<String, dynamic>>.from(doc['items']);
          for (var cartItem in cartController.cartItems) {
            final index = items.indexWhere((e) => e['name'] == cartItem.name);
            if (index != -1) {
              items[index]['quantity'] += cartItem.quantity;
            } else {
              items.add(cartItem.toMap());
            }
          }

          await firestore.collection('orders').doc(doc.id).update({
            'items': items,
            'total': items.fold<double>(0.0, (sum, e) {
              return sum + (e['price'] * e['quantity']);
            }),
          });

          cartController.clearCart();
          Get.back(); // close loading

          Get.snackbar(
            'Success',
            'Order Updated',
            backgroundColor: Colors.blue.shade200,
            colorText: Colors.white,
          );

          final isMobile = MediaQuery.of(context).size.width < 650;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      isMobile
                          ? LiveOrderPage(
                            tableNo: selectedTable,
                            selectedtype: 'Inhouse',
                          )
                          : LiveOrderPageWeb(
                            tableNo: selectedTable,
                            selectedtype: 'Inhouse',
                          ),
            ),
          );
          return;
        }
      }

      // =============== CREATE NEW ORDER ===============
      final orderData = {
        'tableNo': selectedTable,
        'orderType': selectedOrderType,
        'status': 'pending',
        'items': cartController.cartItems.map((e) => e.toMap()).toList(),
        'total': cartController.totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'prebookSlot':
            selectedOrderType == 'Prebooking'
                ? Timestamp.fromDate(selectedDateTime!)
                : null,
        'adminFeedback': '',
      };

      await firestore.collection('orders').add(orderData);
      cartController.clearCart();
      Get.back(); // close loading

      Get.snackbar(
        'Success',
        'Order Placed Successfully',
        backgroundColor: Colors.blue.shade200,
        colorText: Colors.white,
      );

      // Redirect to appropriate live/prebooking page
      final isMobile = MediaQuery.of(context).size.width < 650;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            if (selectedOrderType == 'Prebooking') {
              return isMobile
                  ? Prebookorder(
                    tableNo: selectedTable,
                    selectedtype: 'Prebooking',
                    timeslot: selectedDateTime!,
                  )
                  : PrebookOrderWeb(
                    tableNo: selectedTable,
                    selectedtype: 'Prebooking',
                    timeslot: selectedDateTime!,
                  );
            } else {
              return isMobile
                  ? LiveOrderPage(
                    tableNo: selectedTable,
                    selectedtype: 'Inhouse',
                  )
                  : LiveOrderPageWeb(
                    tableNo: selectedTable,
                    selectedtype: 'Inhouse',
                  );
            }
          },
        ),
      );
    } catch (e) {
      Get.back(); // close loading in case of error
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
      );
    }
  }
}
