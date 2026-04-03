import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class DigitalIDCard extends StatelessWidget {
  const DigitalIDCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.white),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("John Doe",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Text("Software Intern",
                  style: TextStyle(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }
}

class InternDashboard extends StatelessWidget {
  const InternDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Intern Dashboard")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DigitalIDCard(),
          ],
        ),
      ),
    );
  }
}