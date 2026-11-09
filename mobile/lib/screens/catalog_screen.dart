import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/product_tile.dart';
import 'product_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String? _category;
  String _sort = 'newest';
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<ShopProvider>().loadCategories().catchError((_) {});
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await context
          .read<ShopProvider>()
          .products(query: _search.text.trim(), category: _category, sort: _sort);
      if (mounted) {
        setState(() {
          _products = products;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ShopProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopEase'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) {
              _sort = v;
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'newest', child: Text('Newest')),
              PopupMenuItem(value: 'price_asc', child: Text('Price: low to high')),
              PopupMenuItem(value: 'price_desc', child: Text('Price: high to low')),
              PopupMenuItem(value: 'rating', child: Text('Top rated')),
            ],
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('All', null),
                for (final c in categories) _chip(c.name, c.slug),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _chip(String label, String? slug) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: _category == slug,
          onSelected: (_) {
            _category = slug;
            _load();
          },
        ),
      );

  Widget _body() {
    if (_loading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _load, child: const Text('Try again')),
        ]),
      );
    }
    if (_products.isEmpty) {
      return const Center(child: Text('No products match your search.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 0.68,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _products.length,
        itemBuilder: (context, i) => ProductTile(
          product: _products[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductScreen(product: _products[i])),
          ),
        ),
      ),
    );
  }
}
