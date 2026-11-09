import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(url: product.imageUrl),
                  if (product.discountPercent != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Tag(text: '-${product.discountPercent}%', color: theme.colorScheme.primary),
                    ),
                  if (!product.inStock)
                    const Positioned(top: 8, right: 8, child: _Tag(text: 'Sold out', color: Colors.black54)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(money(product.price),
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(product.rating.toStringAsFixed(1), style: theme.textTheme.bodySmall),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined, size: 40),
    );
    if (url == null) return placeholder;
    return Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
