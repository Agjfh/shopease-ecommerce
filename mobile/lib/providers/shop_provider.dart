import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../models/product.dart';

class ShopProvider extends ChangeNotifier {
  ShopProvider(this.api);

  final ApiClient api;

  List<Category> categories = [];
  List<CartItem> cart = [];
  CartSummary summary = const CartSummary();
  List<Order> orders = [];

  Future<void> loadCategories() async {
    final data = await api.get('/categories') as List;
    categories = data.map((c) => Category.fromJson(c as Map<String, dynamic>)).toList();
    notifyListeners();
  }

  Future<List<Product>> products({String? query, String? category, String sort = 'newest'}) async {
    final data = await api.get('/products', query: {
      if (query != null && query.isNotEmpty) 'q': query,
      if (category != null) 'category': category,
      'sort': sort,
      'per_page': 50,
    }) as Map<String, dynamic>;
    return (data['data'] as List)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  int quantityInCart(int productId) =>
      cart.where((i) => i.product.id == productId).fold(0, (sum, i) => sum + i.quantity);

  void _setCart(dynamic data) {
    final map = data as Map<String, dynamic>;
    cart = (map['items'] as List)
        .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
        .toList();
    summary = CartSummary.fromJson(map['summary'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> loadCart() async => _setCart(await api.get('/cart'));

  Future<void> addToCart(Product product, {int quantity = 1}) async =>
      _setCart(await api.post('/cart', {'product_id': product.id, 'quantity': quantity}));

  Future<void> updateQuantity(CartItem item, int quantity) async =>
      _setCart(await api.patch('/cart/${item.id}', {'quantity': quantity}));

  Future<void> removeFromCart(CartItem item) async =>
      _setCart(await api.delete('/cart/${item.id}'));

  Future<Order> checkout(Map<String, dynamic> shipping) async {
    final data = await api.post('/orders', shipping) as Map<String, dynamic>;
    final order = Order.fromJson(data);
    orders.insert(0, order);
    cart = [];
    summary = const CartSummary();
    notifyListeners();
    return order;
  }

  Future<void> loadOrders() async {
    final data = await api.get('/orders') as Map<String, dynamic>;
    orders = (data['data'] as List)
        .map((o) => Order.fromJson(o as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<Order> cancelOrder(Order order) async {
    final updated = Order.fromJson(
        await api.post('/orders/${order.id}/cancel') as Map<String, dynamic>);
    final i = orders.indexWhere((o) => o.id == order.id);
    if (i != -1) orders[i] = updated;
    notifyListeners();
    return updated;
  }
}
