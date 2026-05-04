import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class Marks extends ConsumerStatefulWidget {
  const Marks({super.key});

  @override
  ConsumerState<Marks> createState() => _MarksState();
}

class _MarksState extends ConsumerState<Marks> {
  List skills = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchSkills();
  }

  Future<void> fetchSkills() async {
    final internId = ref.read(userIdProvider);
    final baseUrl = ref.read(baseUrlProvider);

    final response = await http.get(
      Uri.parse("${baseUrl}/intern/$internId/skills-with-marks"),
    );

    if (response.statusCode == 200) {
      setState(() {
        skills = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skill Marks")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          final int mark = skill["mark"];
          final double progress = mark / 100;

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skill name
                  Text(
                    skill["skill"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Progress bar
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),

                  const SizedBox(height: 5),

                  // Mark text
                  Text("Score: $mark / 100"),

                  const SizedBox(height: 10),

                  // Complaint button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Complaint sent (not implemented)"),
                          ),
                        );
                      },
                      child: const Text("Send Complaint"),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}