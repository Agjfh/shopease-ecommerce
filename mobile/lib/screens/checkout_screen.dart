import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ui.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import 'order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: context.read<AuthProvider>().user?.name);
  late final _phone = TextEditingController(text: context.read<AuthProvider>().user?.phone);
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _notes = TextEditingController();
  String _payment = 'cash_on_delivery';
  bool _placing = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _city, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);
    try {
      final order = await context.read<ShopProvider>().checkout({
        'shipping_name': _name.text.trim(),
        'shipping_phone': _phone.text.trim(),
        'shipping_address': _address.text.trim(),
        'shipping_city': _city.text.trim(),
        'payment_method': _payment,
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order, justPlaced: true)),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = context.watch<ShopProvider>().summary.total;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Shipping address', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: requiredField),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: requiredField,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Street address'), validator: requiredField),
            const SizedBox(height: 12),
            TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City'), validator: requiredField),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Delivery notes (optional)'),
            ),
            const SizedBox(height: 20),
            Text('Payment', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'cash_on_delivery', icon: Icon(Icons.payments_outlined), label: Text('Cash on delivery')),
                ButtonSegment(value: 'card', icon: Icon(Icons.credit_card), label: Text('Card')),
              ],
              selected: {_payment},
              onSelectionChanged: (s) => setState(() => _payment = s.first),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _placing ? null : _placeOrder,
            child: Text(_placing ? 'Placing order...' : 'Place order · ${money(total)}'),
          ),
        ),
      ),
    );
  }
}
