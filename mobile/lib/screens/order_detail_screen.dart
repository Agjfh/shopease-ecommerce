import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ui.dart';
import '../models/order.dart';
import '../providers/shop_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order, this.justPlaced = false});

  final Order order;
  final bool justPlaced;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order = widget.order;

  Future<void> _cancel() async {
    try {
      final updated = await context.read<ShopProvider>().cancelOrder(_order);
      if (mounted) setState(() => _order = updated);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cancelled = _order.status == 'cancelled';

    return Scaffold(
      appBar: AppBar(title: Text(_order.number)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.justPlaced)
            Card(
              color: theme.colorScheme.primaryContainer,
              child: const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text('Order placed!'),
                subtitle: Text("We'll let you know when it ships."),
              ),
            ),
          if (cancelled)
            Card(
              color: theme.colorScheme.errorContainer,
              child: const ListTile(leading: Icon(Icons.cancel), title: Text('This order was cancelled')),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    for (var i = 0; i < Order.steps.length; i++)
                      Expanded(
                        child: Column(children: [
                          Icon(
                            i <= _order.stepIndex ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: i <= _order.stepIndex ? theme.colorScheme.primary : theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 4),
                          Text(Order.steps[i][0].toUpperCase() + Order.steps[i].substring(1),
                              style: theme.textTheme.labelSmall),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              for (final line in _order.items)
                ListTile(
                  title: Text(line.name),
                  subtitle: Text('${line.quantity} × ${money(line.unitPrice)}'),
                  trailing: Text(money(line.lineTotal)),
                ),
              const Divider(height: 1),
              ListTile(title: const Text('Shipping'), trailing: Text(_order.shipping == 0 ? 'Free' : money(_order.shipping))),
              ListTile(
                title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(money(_order.total), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text('${_order.address['name']} · ${_order.address['phone']}'),
              subtitle: Text('${_order.address['address']}, ${_order.address['city']}'),
            ),
          ),
          if (_order.canCancel) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _cancel, child: const Text('Cancel order')),
          ],
        ],
      ),
    );
  }
}
