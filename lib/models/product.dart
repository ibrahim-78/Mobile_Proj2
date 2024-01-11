class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;

  Product({required this.id, required this.name, required this.imageUrl, required this.price, required this.description});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: int.parse(json['id']),
        name: json['name'] as String,
        imageUrl: json['imageUrl'] as String,
        price: double.parse(json['price']),
        description: json['description'] as String
    );
  }
}