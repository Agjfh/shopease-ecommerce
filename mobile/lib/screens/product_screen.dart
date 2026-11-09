import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ui.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../widgets/product_tile.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;
  bool _adding = false;

  Future<void> _add() async {
    setState(() => _adding = true);
    try {
      await context.read<ShopProvider>().addToCart(widget.product, quantity: _quantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $_quantity × ${widget.product.name} to your cart')),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final theme = Theme.of(context);
    final inCart = context.watch<ShopProvider>().quantityInCart(p.id);
    final maxQty = (p.stock - inCart).clamp(0, 99).toInt();

    return Scaffold(
      appBar: AppBar(title: Text(p.category?.name ?? 'Product')),
      body: ListView(
        children: [
          AspectRatio(aspectRatio: 1, child: ProductImage(url: p.imageUrl)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(p.rating.toStringAsFixed(1)),
                  const SizedBox(width: 16),
                  Text(
                    p.inStock ? (p.stock < 10 ? 'Only ${p.stock} left' : 'In stock') : 'Out of stock',
                    style: TextStyle(color: p.inStock && p.stock >= 10 ? Colors.green : theme.colorScheme.error),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(money(p.price),
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  if (p.compareAtPrice != null) ...[
                    const SizedBox(width: 10),
                    Text(money(p.compareAtPrice!),
                        style: theme.textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.lineThrough, color: theme.colorScheme.outline)),
                  ],
                ]),
                const SizedBox(height: 20),
                Text(p.description, style: theme.textTheme.bodyLarge),
                if (inCart > 0) ...[
                  const SizedBox(height: 16),
                  Text('You have $inCart in your cart', style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton.outlined(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_quantity', style: theme.textTheme.titleMedium),
              ),
              IconButton.outlined(
                onPressed: _quantity < maxQty ? () => setState(() => _quantity++) : null,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: (_adding || maxQty == 0) ? null : _add,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(maxQty == 0 ? 'Unavailable' : 'Add to cart'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
