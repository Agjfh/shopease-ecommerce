import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ui.dart';
import '../models/cart.dart';
import '../providers/shop_provider.dart';
import '../widgets/product_tile.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final s = shop.summary;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: RefreshIndicator(
        onRefresh: () => _run(context, shop.loadCart),
        child: shop.cart.isEmpty
            ? ListView(children: const [
                SizedBox(height: 140),
                Icon(Icons.shopping_cart_outlined, size: 64),
                SizedBox(height: 12),
                Center(child: Text('Your cart is empty.')),
              ])
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (s.remainingForFreeShipping > 0)
                    Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping_outlined),
                        title: Text('Add ${money(s.remainingForFreeShipping)} more for free shipping'),
                      ),
                    ),
                  for (final item in shop.cart) _CartRow(item: item, run: _run),
                  const SizedBox(height: 12),
                  _line(context, 'Subtotal', money(s.subtotal)),
                  _line(context, 'Shipping', s.shipping == 0 ? 'Free' : money(s.shipping)),
                  const Divider(),
                  _line(context, 'Total', money(s.total), bold: true),
                ],
              ),
      ),
      bottomNavigationBar: shop.cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                  child: Text('Checkout · ${money(s.total)}'),
                ),
              ),
            ),
    );
  }

  Widget _line(BuildContext context, String label, String value, {bool bold = false}) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.run});

  final CartItem item;
  final Future<void> Function(BuildContext, Future<void> Function()) run;

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 72, height: 72, child: ProductImage(url: item.product.imageUrl)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: item.quantity > 1
                          ? () => run(context, () => shop.updateQuantity(item, item.quantity - 1))
                          : null,
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: item.quantity < item.product.stock
                          ? () => run(context, () => shop.updateQuantity(item, item.quantity + 1))
                          : null,
                    ),
                  ]),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => run(context, () => shop.removeFromCart(item)),
            ),
          ],
        ),
      ),
    );
  }
}
