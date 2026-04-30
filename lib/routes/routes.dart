import 'package:flutter/material.dart';
import 'package:pro_link/features/admin/interns_assignment.dart';
import 'package:pro_link/features/admin/interns_validation.dart';
import '../features/login_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/mentor/mentor_dashboard.dart';
import '../features/intern/intern_dashboard.dart';
import '../features/intern/trainingfiles.dart';
import '../features/intern/assignments.dart';
import '../features/intern/marks.dart';


class AppRoutes {
  static const login = "/";
  static const admin = "/admin";
  static const mentor = "/mentor";
  static const intern = "/intern";
  static const tf ='/intern/trainingfiles';
  static const ia ='/intern/assignments';
  static const marks ='/intern/skillmarks';
  static const iv ='/admin/interns_validation';
  static const isa ='/admin/interns_assignment';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    admin: (context) => const AdminDashboard(),
    mentor: (context) => const MentorDashboard(),
    intern: (context) => const InternDashboard(),
    tf:(context) =>const TrainingFiles(),
    ia:(context) =>const Assignments(),
    marks:(context) =>const Marks(),
    iv:(context) =>const InternsValidation(),
    isa:(context) =>const InternsAssignment(),
  };
}