import 'product.dart';

class CartItem {
  CartItem({required this.id, required this.quantity, required this.lineTotal, required this.product});

  final int id;
  final int quantity;
  final double lineTotal;
  final Product product;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as int,
        quantity: json['quantity'] as int,
        lineTotal: (json['line_total'] as num).toDouble(),
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
      );
}

class CartSummary {
  const CartSummary({
    this.subtotal = 0,
    this.shipping = 0,
    this.total = 0,
    this.count = 0,
    this.freeShippingFrom = 0,
  });

  final double subtotal;
  final double shipping;
  final double total;
  final int count;
  final double freeShippingFrom;

  double get remainingForFreeShipping =>
      (freeShippingFrom - subtotal).clamp(0, double.infinity).toDouble();

  factory CartSummary.fromJson(Map<String, dynamic> json) => CartSummary(
        subtotal: (json['subtotal'] as num).toDouble(),
        shipping: (json['shipping'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        count: json['count'] as int,
        freeShippingFrom: (json['free_shipping_from'] as num).toDouble(),
      );
}
