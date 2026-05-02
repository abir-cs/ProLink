import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GradingPage extends StatefulWidget {
  const GradingPage({super.key});

  @override
  State<GradingPage> createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {
  List skills = [];
  bool isLoading = true;

  final Map<int, TextEditingController> controllers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchSkills();
  }

  Future<void> fetchSkills() async {
    final internId =
    ModalRoute
        .of(context)!
        .settings
        .arguments as int;

    final response = await http.get(
      Uri.parse("http://192.168.1.6:3000/intern/$internId/skills-with-marks"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (var skill in data) {
        controllers[skill["skill_id"]] =
            TextEditingController(text: skill["mark"].toString());
      }

      setState(() {
        skills = data;
        isLoading = false;
      });
    }
  }

  Future<void> saveMarks() async {
    final internId =
    ModalRoute
        .of(context)!
        .settings
        .arguments as int;

    for (var skill in skills) {
      final skillId = skill["skill_id"];
      final mark = int.tryParse(controllers[skillId]!.text) ?? 0;

      await http.post(
        Uri.parse("http://192.168.1.6:3000/marks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "intern_id": internId,
          "skill_id": skillId,
          "mark": mark,
        }),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marks saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grading Page")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(

            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                final controller =
                controllers[skill["skill_id"]]!;

                return ListTile(
                  title: Text(skill["skill"]),
                  trailing: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(hintText: "0-100"),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: saveMarks,
              child: const Text("Save Marks"),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final internId =
              ModalRoute
                  .of(context)!
                  .settings
                  .arguments as int;

              await http.post(
                Uri.parse("http://192.168.1.6:3000/attendance"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "intern_id": internId,
                  "date": DateTime.now().toIso8601String(),
                  "status": "present",
                }),
              );
            },
            child: const Text("Mark Present"),
          ),
        ],
      ),
    );
  }

}