// ignore_for_file: use_build_context_synchronously, avoid_types_as_parameter_names

import 'package:bluebite/Mobile%20Screen/homedelivermobile.dart';
import 'package:bluebite/Mobile%20Screen/prebookorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Mobile Screen/liveorder.dart';
import 'Web Screen/homedeliverweb.dart';
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

  Future<void> cancelOrder(String orderId, Map<String, dynamic> data) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final ordersCollection = FirebaseFirestore.instance.collection('orders');
      final cancelledCollection = FirebaseFirestore.instance.collection(
        'cancelledOrders',
      );

      // --- Core Logic ---

      // Delete order
      await ordersCollection.doc(orderId).delete();

      // Move to cancelledOrders
      await cancelledCollection.add({
        ...data,
        'cancelledByUser': true,
        'cancelledAt': Timestamp.now(),
        'status': 'cancelled',
      });

      Get.snackbar(
        'Success',
        'Order ID $orderId has been successfully cancelled.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade800,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
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

  // New reactive loading for search
  RxBool isSearching = false.obs;

  Future<void> searchProducts(String keyword) async {
    try {
      keyword = keyword.trim().toLowerCase();
      searchQuery.value = keyword;
      isSearching.value = true;
      hasError.value = false;

      // If search is cleared → load category again
      if (keyword.isEmpty) {
        await fetchMenuItems(selectedCategory.value);
        return;
      }

      // Load all items for search filtering
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
      isSearching.value = false;
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

  // ---------------------------------------------------------
  // ORDER CONFIRMATION
  // ---------------------------------------------------------
Future<void> confirmOrder(
  String selectedTable,
  String selectedOrderType,
  BuildContext context,
  DateTime? selectedDateTime, {
  String? deliveryName,
  String? deliveryPhone,
  String? deliveryAddress,
  String? paymentMethod,    // <-- added
  String? transactionId,    // <-- added
}) async {
  final firestore = FirebaseFirestore.instance;

  // Cart empty check
  if (cartController.cartItems.isEmpty) {
    Get.snackbar(
      'Cart Empty',
      'Please add items before confirming order.',
      backgroundColor: Colors.blue.shade200,
      colorText: Colors.white,
    );
    return;
  }

  // Prebooking must have date/time
  if (selectedOrderType == 'Prebooking' && selectedDateTime == null) {
    Get.snackbar(
      'Select Date & Time',
      'Please choose date & time for your prebooking order',
      backgroundColor: Colors.blue.shade200,
      colorText: Colors.white,
    );
    return;
  }

  const slotDuration = Duration(hours: 2);

  try {
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // ================== Prebooking slot check ==================
    if (selectedOrderType == 'Prebooking') {
      final newStart = selectedDateTime!;
      final newEnd = newStart.add(slotDuration);

      final existingBookings = await firestore
          .collection('orders')
          .where('tableNo', isEqualTo: selectedTable)
          .where('orderType', isEqualTo: 'Prebooking')
          .where('status', whereIn: ['pending', 'processing'])
          .get();

      for (var doc in existingBookings.docs) {
        final data = doc.data();
        final Timestamp? ts = data['prebookSlot'] as Timestamp?;
        if (ts == null) continue;

        final existingStart = ts.toDate();
        final existingEnd = existingStart.add(slotDuration);

        final overlap =
            newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart);

        if (overlap) {
          Get.back();
          Get.snackbar(
            'Slot Unavailable',
            'This table is already booked from '
            '${existingStart.hour}:${existingStart.minute.toString().padLeft(2, '0')} '
            'to ${existingEnd.hour}:${existingEnd.minute.toString().padLeft(2, '0')}.',
            backgroundColor: Colors.red.shade400,
            colorText: Colors.white,
          );
          return;
        }
      }
    }

    // ================== Inhouse merge logic ==================
    if (selectedOrderType == 'Inhouse') {
      final activeOrders = await firestore
          .collection('orders')
          .where('tableNo', isEqualTo: selectedTable)
          .where('orderType', isEqualTo: 'Inhouse')
          .where('status', whereIn: ['pending', 'processing'])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (activeOrders.docs.isNotEmpty) {
        final doc = activeOrders.docs.first;
        final List<Map<String, dynamic>> existingItems =
            List<Map<String, dynamic>>.from(doc['items']);

        // Merge cart items safely
        for (var cartItem in cartController.cartItems) {
          final index = existingItems.indexWhere((e) {
            return e['name'] == cartItem.name &&
                e['selectedVariant']?['size'] ==
                    cartItem.selectedVariant?.size;
          });

          if (index != -1) {
            // Merge quantity safely
            existingItems[index]['quantity'] =
                (existingItems[index]['quantity'] ?? 0) + cartItem.quantity;

            // Update price correctly considering variant
            existingItems[index]['price'] = cartItem.selectedVariant != null
                ? (cartItem.selectedVariant?.price ?? 0.0)
                : (cartItem.price ?? 0.0);
          } else {
            // Add new cart item safely
            final map = cartItem.toMap();
            map['quantity'] = map['quantity'] ?? 1;
            map['price'] = cartItem.selectedVariant != null
                ? (cartItem.selectedVariant?.price ?? 0.0)
                : (cartItem.price ?? 0.0);
            existingItems.add(map);
          }
        }

        // Update total safely
        final double total = existingItems.fold<double>(0.0, (sum, e) {
          final price = (e['price'] ?? 0).toDouble();
          final qty = (e['quantity'] ?? 0).toInt();
          return sum + (price * qty);
        });

        await firestore.collection('orders').doc(doc.id).update({
          'items': existingItems,
          'total': total,
          'paymentMethod': paymentMethod ?? 'Cash',   // <-- added
          'transactionId': transactionId,             // <-- added
        });

        cartController.clearCart();
        Get.back();

        Get.snackbar(
          'Success',
          'Order Updated (Merged with existing order)',
          backgroundColor: Colors.blue.shade200,
          colorText: Colors.white,
        );

        final isMobile = MediaQuery.of(context).size.width < 650;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isMobile
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

    // ================== Create new order ==================
    final orderData = {
      'tableNo': selectedTable,
      'orderType': selectedOrderType,
      'status': 'pending',
      'items': cartController.cartItems.map((e) {
        final map = e.toMap();
        map['quantity'] = map['quantity'] ?? 1;
        map['price'] = e.selectedVariant != null
            ? (e.selectedVariant?.price ?? 0.0)
            : (e.price ?? 0.0);
        return map;
      }).toList(),
      'total': cartController.cartItems.fold<double>(0.0, (sum, e) {
        final double price = e.selectedVariant != null
            ? (e.selectedVariant?.price ?? 0.0)
            : (e.price ?? 0.0);
        final int qty = e.quantity;
        return sum + (price * qty);
      }),
      'timestamp': FieldValue.serverTimestamp(),
      'prebookSlot': selectedOrderType == 'Prebooking'
          ? Timestamp.fromDate(selectedDateTime!)
          : null,
      'name': deliveryName,
      'phone': deliveryPhone,
      'address': deliveryAddress,
      'paymentMethod': paymentMethod ?? 'Cash',  // <-- added
      'transactionId': transactionId,            // <-- added
      'adminFeedback': '',
    };

    await firestore.collection('orders').add(orderData);
    cartController.clearCart();
    Get.back();

    Get.snackbar(
      'Success',
      'Order Placed Successfully',
      backgroundColor: Colors.blue.shade200,
      colorText: Colors.white,
    );

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
          }

          if (selectedOrderType == 'Home Delivery') {
            return isMobile
                ? Homedelivermobile(
                    customerName: deliveryName,
                    customerPhone: deliveryPhone,
                    selectedtype: 'Home Delivery',
                  )
                : DeliveryOrderWeb(
                    customerName: deliveryName,
                    customerPhone: deliveryPhone,
                    selectedtype: 'Home Delivery',
                  );
          }

          return isMobile
              ? LiveOrderPage(
                  tableNo: selectedTable,
                  selectedtype: 'Inhouse',
                )
              : LiveOrderPageWeb(
                  tableNo: selectedTable,
                  selectedtype: 'Inhouse',
                );
        },
      ),
    );
  } catch (e) {
    Get.back();
    Get.snackbar(
      'Error',
      e.toString(),
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
    );
  }
}




}
