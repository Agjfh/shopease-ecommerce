class OrderLine {
  OrderLine({required this.name, required this.unitPrice, required this.quantity, required this.lineTotal});

  final String name;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        name: json['name'] as String,
        unitPrice: (json['unit_price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        lineTotal: (json['line_total'] as num).toDouble(),
      );
}

class Order {
  Order({
    required this.id,
    required this.number,
    required this.status,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.address,
    required this.canCancel,
    required this.items,
    required this.createdAt,
  });

  final int id;
  final String number;
  final String status;
  final double subtotal;
  final double shipping;
  final double total;
  final Map<String, dynamic> address;
  final bool canCancel;
  final List<OrderLine> items;
  final DateTime createdAt;

  static const steps = ['pending', 'processing', 'shipped', 'delivered'];

  int get stepIndex => steps.indexOf(status);

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        number: json['number'] as String,
        status: json['status'] as String,
        subtotal: (json['subtotal'] as num).toDouble(),
        shipping: (json['shipping'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        address: json['shipping_address'] as Map<String, dynamic>,
        canCancel: json['can_cancel'] as bool,
        items: (json['items'] as List? ?? [])
            .map((i) => OrderLine.fromJson(i as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}
