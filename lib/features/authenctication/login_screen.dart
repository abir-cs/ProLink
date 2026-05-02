import 'package:flutter/material.dart';
import '../../core/button.dart';
import '../../routes/routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'waiting.dart';


class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends ConsumerState<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "Intern";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("ProLink Login", style: TextStyle(fontSize: 22)),

        const SizedBox(height: 20),

        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password"),
        ),

        const SizedBox(height: 10),

        DropdownButton<String>(
          value: role,
          items: ["Admin", "Mentor", "Intern"]
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (value) {
            setState(() {
              role = value!;
            });
          },
        ),

        const SizedBox(height: 20),

        CustomButton(
          text: "Login",
          onPressed: () async {
            final email = emailController.text.trim();
            final password = passwordController.text.trim();

            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please fill all fields")),
              );
              return;
            }

            try {
              final response = await http.post(
                Uri.parse("http://192.168.1.7:3000/login"), // emulator -> localhost
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "email": email,
                  "password": password,
                  "role": role.toLowerCase(), // important
                }),
              );

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);

                final returnedRole = data["role"];
                final user = data["user"];

                int userId;
                if (returnedRole == "admin") {
                  Navigator.pushNamed(context, AppRoutes.admin);
                  userId = user["admin_id"];
                } else if (returnedRole == "mentor") {
                  Navigator.pushNamed(context, AppRoutes.mentor);
                  userId = user["mentor_id"];
                } else {
                  final status = user["status"];
                  userId = user["intern_id"];
                  if (status == "waiting") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Waiting()),
                    );
                  } else if (status == "accepted") {
                    Navigator.pushNamed(context, AppRoutes.intern);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account rejected")),
                    );
                  }
                }
                ref.read(userIdProvider.notifier).state = userId;
                ref.read(userRoleProvider.notifier).state = returnedRole;

              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid credentials")),
                );
              }

            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Connection error: $e")),
              );
            }
          },
        )
      ],
    );
  }
}


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 400,
              child: Card(
                margin: EdgeInsets.all(10),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoginForm(),
                ),
              ),
            ),
            TextButton(onPressed: (){
              Navigator.pushNamed(context, AppRoutes.register);
            }, child: Text("dont have an account ? register as intern"))
          ],

        ),
      ),
    );
  }
}