class MenuItem {
  final String name;
  final String category;
  final double price;
  final String imgUrl;
  int quantity;

  MenuItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imgUrl,
    this.quantity = 1,
  });

  factory MenuItem.fromMap(Map<String, dynamic> data) {
    return MenuItem(
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imgUrl: data['imgUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'price': price,
    'imageUrl': imgUrl,
    'quantity': quantity,
  };
}
