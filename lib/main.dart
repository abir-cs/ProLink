import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'routes/routes.dart';

void main() {
  runApp(const ProLinkApp());
}

class ProLinkApp extends StatelessWidget {
  const ProLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
