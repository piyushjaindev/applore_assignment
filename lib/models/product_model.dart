class ProductModel {
  final String name;
  final String description;
  final String price;
  final String image;

  ProductModel({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
        name: data['name'],
        description: data['description'],
        image: data['image'],
        price: data['price']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'price': price,
    };
  }
}
