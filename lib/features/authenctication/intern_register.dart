import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'waiting.dart';
import 'package:file_picker/file_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final ageController = TextEditingController();

  File? selectedCV;
  bool isLoading = false;

  // Pick CV
  Future<void> pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedCV = File(result.files.single.path!);
      });
    }
  }

  // Register function
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final fname = fnameController.text.trim();
    final lname = lnameController.text.trim();
    final age = ageController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        fname.isEmpty ||
        lname.isEmpty ||
        age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://192.168.1.6:3000/register/intern"),
      );

      request.fields["email"] = email;
      request.fields["password"] = password;
      request.fields["fname"] = fname;
      request.fields["lname"] = lname;
      request.fields["age"] = age;

      if (selectedCV != null) {
        request.files.add(
          await http.MultipartFile.fromPath("cv", selectedCV!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Waiting()),
        );
      } else {
        print("STATUS: ${response.statusCode}");
        final responseData = await http.Response.fromStream(response);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData.body)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Intern")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
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
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
            ),

            const SizedBox(height: 20),

            // 📄 CV picker
            ElevatedButton(
              onPressed: pickCV,
              child: Text(
                selectedCV == null
                    ? "Upload CV"
                    : "CV Selected",
              ),
            ),

            const SizedBox(height: 20),

            // 🚀 Register button
            ElevatedButton(
              onPressed: isLoading ? null : register,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}