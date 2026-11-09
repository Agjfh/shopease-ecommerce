import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../providers/shop_provider.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      await context.read<ShopProvider>().loadOrders();
    } catch (_) {
      // Shown as empty state; pull to retry.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<ShopProvider>().orders;
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: orders.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 140),
                      Center(child: Text('No orders yet.')),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, i) {
                        final o = orders[i];
                        return Card(
                          child: ListTile(
                            title: Text(o.number),
                            subtitle: Text(
                                '${DateFormat('d MMM yyyy').format(o.createdAt)} · ${o.items.length} item(s)'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(money(o.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(o.status.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o))),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
