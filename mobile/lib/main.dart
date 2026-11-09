import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  final api = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api)..init()),
        ChangeNotifierProvider(create: (_) => ShopProvider(api)),
      ],
      child: const ShopEaseApp(),
    ),
  );
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE4572E)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.initializing) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
