class Category {
  Category({required this.id, required this.name, required this.slug, this.icon, this.productsCount});

  final int id;
  final String name;
  final String slug;
  final String? icon;
  final int? productsCount;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        icon: json['icon'] as String?,
        productsCount: json['products_count'] as int?,
      );
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.rating,
    this.compareAtPrice,
    this.discountPercent,
    this.imageUrl,
    this.category,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final int? discountPercent;
  final int stock;
  final String? imageUrl;
  final double rating;
  final Category? category;

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
        discountPercent: json['discount_percent'] as int?,
        stock: json['stock'] as int,
        imageUrl: json['image_url'] as String?,
        rating: (json['rating'] as num).toDouble(),
        category: json['category'] == null
            ? null
            : Category.fromJson(json['category'] as Map<String, dynamic>),
      );
}
