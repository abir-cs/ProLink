import 'package:flutter/material.dart';
import '../core/button.dart';
import '../routes/routes.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<LoginForm> {
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
          onPressed: () {
            if (role == "Admin") {
              Navigator.pushNamed(context, AppRoutes.admin);
            } else if (role == "Mentor") {
              Navigator.pushNamed(context, AppRoutes.mentor);
            } else {
              Navigator.pushNamed(context, AppRoutes.intern);
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
        child: SizedBox(
          width: 400,
          child: Card(
            margin: EdgeInsets.all(10),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}