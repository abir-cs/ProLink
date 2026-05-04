import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/app_colors.dart';
import 'intern_service.dart';

class CreateMentorScreen extends StatefulWidget {
  const CreateMentorScreen({super.key});

  @override
  State<CreateMentorScreen> createState() => _CreateMentorScreenState();
}

class _CreateMentorScreenState extends State<CreateMentorScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  List<Department> departments = [];
  bool loadingDepartments = true;
  Department? selectedDepartment;
  Future<void> loadDepartments() async {
    departments = await InternService.fetchDepartments();
    setState(() => loadingDepartments = false);
  }

  void initState() {
    super.initState();
    loadDepartments();
  }

  bool loading = false;

  Future<void> createMentor() async {
    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a department")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.4:3000/mentor/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "fname": fnameController.text.trim(),
          "lname": lnameController.text.trim(),
          "department_id": selectedDepartment!.id,
        }),
      );
      print("❤️STATUS: ${response.statusCode}");
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mentor created successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Mentor")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: fnameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lnameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            loadingDepartments
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
                : DropdownButtonFormField<Department>(
              dropdownColor: AppColors.cardDark,
              decoration: InputDecoration(
                labelText: "Department",
                labelStyle: TextStyle(color: AppColors.textPrimary),
              ),
              value: selectedDepartment,
              items:
              departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : createMentor,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Create Mentor"),
            ),
          ],
        ),
      ),
    );
  }
}