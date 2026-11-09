import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/models/cart.dart';

void main() {
  test('CartSummary computes amount left for free shipping', () {
    final summary = CartSummary.fromJson({
      'subtotal': 800,
      'shipping': 60,
      'total': 860,
      'count': 2,
      'free_shipping_from': 1000,
    });

    expect(summary.remainingForFreeShipping, 200);
    expect(summary.total, 860.0);
  });
}
