import 'package:flutter/material.dart';
import 'package:pro_link/features/admin/assigned_interns.dart';
import 'package:pro_link/features/admin/create_admin.dart';
import 'package:pro_link/features/admin/create_mentor.dart';
import 'package:pro_link/features/admin/interns_assignment.dart';
import 'package:pro_link/features/admin/interns_validation.dart';
import 'package:pro_link/features/authenctication/intern_register.dart';
import 'package:pro_link/features/mentor/grading.dart';
import '../features/authenctication/login_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/mentor/mentor_dashboard.dart';
import '../features/intern/intern_dashboard.dart';
import '../features/intern/trainingfiles.dart';
import '../features/intern/assignments.dart';
import '../features/intern/marks.dart';
import '../features/authenctication/intern_register.dart';
import '../features/mentor/add_training_module.dart';

class AppRoutes {
  static const login = "/";
  static const admin = "/admin";
  static const mentor = "/mentor";
  static const intern = "/intern";
  static const tf ='/intern/trainingfiles';
  static const ia ='/intern/assignments';
  static const marks ='/intern/skillmarks';
  static const register ='/register';
  static const grading ="/mentor/grading" ;
  static const atf ="/mentor/addTraining";
  static const iv ='/admin/interns_validation';
  static const isa ='/admin/interns_assignment';
  static const ca ='/admin/create_admin';
  static const cm ='/admin/create_mentor';
  static const ai ='/admin/assigned_interns';

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
    register:(context) =>const RegisterScreen(),
    grading:(context)=>const GradingPage(),
    atf:(context)=> const AddTrainingPage(),
    ca:(context)=> const CreateAdminScreen(),
    cm:(context)=> const CreateMentorScreen(),
    ai:(context)=> const AssignedInterns(),
  };

}