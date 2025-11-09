import 'package:get/get.dart';

import 'menuitems.dart';

class CartController extends GetxController {
  var cartItems = <MenuItem>[].obs;

  void addToCart(MenuItem item) {
    final index = cartItems.indexWhere((e) => e.name == item.name);
    if (index != -1) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    } else {
      cartItems.add(item);
    }
  }

  void removeFromCart(MenuItem item) {
    cartItems.removeWhere((e) => e.name == item.name);
  }

  void increaseQuantity(MenuItem item) {
    final index = cartItems.indexWhere((e) => e.name == item.name);
    if (index != -1) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    }
  }

  void decreaseQuantity(MenuItem item) {
    final index = cartItems.indexWhere((e) => e.name == item.name);
    if (index != -1 && cartItems[index].quantity > 1) {
      cartItems[index].quantity -= 1;
      cartItems.refresh();
    }
  }

  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  void clearCart() => cartItems.clear();
}