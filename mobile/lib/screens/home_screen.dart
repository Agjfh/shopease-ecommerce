import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Load the cart early so the badge is correct from the start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadCart().catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<ShopProvider>().summary.count;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [CatalogScreen(), CartScreen(), OrdersScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        ],
      ),
    );
  }
}
