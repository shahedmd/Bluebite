// ignore_for_file: use_build_context_synchronously

import 'package:bluebite/Mobile%20Screen/prebookorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Mobile Screen/liveorder.dart';
import 'cartcontroller.dart';
import 'menuitems.dart';

class GetxCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getimageurls();
    fetchMenuItems("Fastfood");
  }

  var imageurls = [].obs;
  RxBool haserror = false.obs;
  var errormessage = "".obs;

  var currentIndex = 0.obs;

  var tabindex = 0.obs;

  var menuItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var selectedCategory = 'Fastfood'.obs;

  final tabs = ["Fastfood", "Thai", "Chinese", "Indian", "Drink"];

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

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

    final CartController cartController = Get.put(CartController());


  Future<void> confirmOrder(
  String selectedTable,
  String selectedOrderType,
  BuildContext context,
  DateTime? selectedDateTime,
) async {
  final firestore = FirebaseFirestore.instance;

  if (cartController.cartItems.isEmpty) {
    Get.snackbar(
      'Cart Empty',
      'Please add items before confirming order',
      backgroundColor: Colors.blue.shade200,
      colorText: Colors.white,
    );
    return;
  }

  if (selectedOrderType == 'Prebooking' && selectedDateTime == null) {
    Get.snackbar(
      'Select Date & Time',
      'Please choose date and time for your prebooking order',
      backgroundColor: Colors.blue.shade200,
      colorText: Colors.white,
    );
    return;
  }

  const prebookingDuration = Duration(hours: 2);

  if (selectedOrderType == 'Prebooking') {
    final newStart = selectedDateTime!;
    final newEnd = newStart.add(prebookingDuration);

    final existingPrebookings = await firestore
        .collection('orders')
        .where('tableNo', isEqualTo: selectedTable)
        .where('orderType', isEqualTo: 'Prebooking')
        .where('status', isNotEqualTo: 'delivered')
        .get();

    for (var doc in existingPrebookings.docs) {
      final Timestamp ts = doc['timestamp'];
      final DateTime existingStart = ts.toDate();
      final DateTime existingEnd = existingStart.add(prebookingDuration);

      final bool isOverlap = newStart.isBefore(existingEnd) &&
          newEnd.isAfter(existingStart);

      if (isOverlap) {
        Get.snackbar(
          'Table Already Booked',
          'Table $selectedTable is already booked from '
          '${existingStart.hour}:${existingStart.minute.toString().padLeft(2, '0')} '
          'to ${existingEnd.hour}:${existingEnd.minute.toString().padLeft(2, '0')} '
          'on ${existingStart.day}/${existingStart.month}/${existingStart.year}',
          backgroundColor: Colors.red.shade300,
          colorText: Colors.white,
        );
        return;
      }
    }
  }

  // ----------------------------
  // Only merge items for Inhouse orders
  // Prebooking orders are never merged
  // ----------------------------
  if (selectedOrderType == 'Inhouse') {
    final pendingOrderSnapshot = await firestore
        .collection('orders')
        .where('tableNo', isEqualTo: selectedTable)
        .where('orderType', isEqualTo: 'Inhouse')
        .where('status', isNotEqualTo: 'delivered')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (pendingOrderSnapshot.docs.isNotEmpty) {
      final doc = pendingOrderSnapshot.docs.first;
      final existingItems = List<Map<String, dynamic>>.from(doc['items']);

      for (var newItem in cartController.cartItems) {
        final index = existingItems.indexWhere((e) => e['name'] == newItem.name);
        if (index != -1) {
          existingItems[index]['quantity'] += newItem.quantity;
        } else {
          existingItems.add(newItem.toMap());
        }
      }

      await firestore.collection('orders').doc(doc.id).update({
        'items': existingItems,
        'total': existingItems.fold<double>(0.0, (sumval, e) {
          final price = (e['price'] ?? 0).toDouble();
          final quantity = (e['quantity'] ?? 0).toInt();
          return sumval + (price * quantity);
        }),
      });

      cartController.clearCart();
      Get.snackbar(
        'Success',
        'Order Updated Successfully',
        backgroundColor: Colors.blue.shade200,
        colorText: Colors.white,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveOrderPage(
            tableNo: selectedTable,
            selectedtype: selectedOrderType,
          ),
        ),
      );
      return;
    }
  }

  // ----------------------------
  // If no merge, create new order
  // ----------------------------
  final orderData = {
    'tableNo': selectedTable,
    'orderType': selectedOrderType,
    'status': 'pending',
    'items': cartController.cartItems.map((e) => e.toMap()).toList(),
    'total': cartController.totalPrice,
    'timestamp': selectedOrderType == 'Inhouse'
        ? FieldValue.serverTimestamp()
        : selectedDateTime,
    'adminFeedback': '',
  };

  await firestore.collection('orders').add(orderData);
  cartController.clearCart();

  Get.snackbar(
    'Success',
    'Order Placed Successfully',
    backgroundColor: Colors.blue.shade200,
    colorText: Colors.white,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) {
        if (selectedOrderType == 'Prebooking') {
          return Prebookorder(
            tableNo: selectedTable,
            selectedtype: selectedOrderType,
          );
        } else {
          return LiveOrderPage(
            tableNo: selectedTable,
            selectedtype: selectedOrderType,
          );
        }
      },
    ),
  );
}



  }