import 'package:flutter/material.dart';
import '../features/login_screen.dart';
import '../features/admin_dashboard.dart';
import '../features/mentor_dashboard.dart';
import '../features/intern_dashboard.dart';

class AppRoutes {
  static const login = "/";
  static const admin = "/admin";
  static const mentor = "/mentor";
  static const intern = "/intern";

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    admin: (context) => const AdminDashboard(),
    mentor: (context) => const MentorDashboard(),
    intern: (context) => const InternDashboard(),
  };
}