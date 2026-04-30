import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  runApp(ProviderScope(child: const ProLinkApp()));
}

class ProLinkApp extends StatelessWidget {
  const ProLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
