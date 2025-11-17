import 'package:get/get.dart';
import 'menuitems.dart';

class CartController extends GetxController {
  var cartItems = <MenuItem>[].obs;

  // 👉 ADD NORMAL ITEM (NO VARIANTS)
  void addToCart(MenuItem item) {
    final index = cartItems.indexWhere((e) =>
        e.name == item.name && e.selectedVariant == null);

    if (index != -1) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    } else {
      final newItem = MenuItem(
        name: item.name,
        category: item.category,
        price: item.price,
        imgUrl: item.imgUrl,
        variants: null, // no variants
        selectedVariant: null,
        quantity: 1,
      );

      cartItems.add(newItem);
    }
  }

  // 👉 ADD VARIANT ITEM
  void addVariantToCart(MenuItem item, MenuVariant variant) {
    // Check if same item + same variant already exists
    final index = cartItems.indexWhere((e) =>
        e.name == item.name &&
        e.selectedVariant != null &&
        e.selectedVariant!.size == variant.size);

    if (index != -1) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    } else {
      final newItem = MenuItem(
        name: item.name,
        category: item.category,
        imgUrl: item.imgUrl,
        price: null,               // price comes from variant
        variants: item.variants,   // original variants list
        selectedVariant: variant,  // selected variant
        quantity: 1,
      );

      cartItems.add(newItem);
    }
  }

  void removeFromCart(MenuItem item) {
    cartItems.removeWhere((e) =>
        e.name == item.name &&
        ((e.selectedVariant == null && item.selectedVariant == null) ||
            (e.selectedVariant?.size == item.selectedVariant?.size)));
  }

  void increaseQuantity(MenuItem item) {
    final index = cartItems.indexWhere((e) =>
        e.name == item.name &&
        ((e.selectedVariant == null && item.selectedVariant == null) ||
            (e.selectedVariant?.size == item.selectedVariant?.size)));
    if (index != -1) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    }
  }

  void decreaseQuantity(MenuItem item) {
    final index = cartItems.indexWhere((e) =>
        e.name == item.name &&
        ((e.selectedVariant == null && item.selectedVariant == null) ||
            (e.selectedVariant?.size == item.selectedVariant?.size)));

    if (index != -1 && cartItems[index].quantity > 1) {
      cartItems[index].quantity -= 1;
      cartItems.refresh();
    }
  }

  // 👉 Correct total price
  double get totalPrice => cartItems.fold(0, (sum, item) {
        final price = item.selectedVariant != null
            ? item.selectedVariant!.price
            : item.price ?? 0;

        return sum + (price * item.quantity);
      });

  void clearCart() => cartItems.clear();
}
