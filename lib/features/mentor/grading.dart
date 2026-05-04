import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_link/core/app_colors.dart';
import '../providers.dart';

class GradingPage extends ConsumerStatefulWidget {
  const GradingPage({super.key});

  @override
  ConsumerState<GradingPage> createState() => _GradingPageState();
}

class _GradingPageState extends ConsumerState<GradingPage> {
  List skills = [];
  List attendance = [];
  bool isLoading = true;

  final Map<int, TextEditingController> controllers = {};

  late int internId;
  late String baseUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    internId = ModalRoute.of(context)!.settings.arguments as int;
    baseUrl = ref.read(baseUrlProvider);

    fetchData();
  }

  Future<void> fetchData() async {
    final skillsRes = await http.get(
      Uri.parse("$baseUrl/intern/$internId/skills-with-marks"),
    );

    final attendanceRes = await http.get(
      Uri.parse("$baseUrl/intern/$internId/attendance"),
    );

    if (skillsRes.statusCode == 200 && attendanceRes.statusCode == 200) {
      final skillsData = jsonDecode(skillsRes.body);
      final attendanceData = jsonDecode(attendanceRes.body);

      for (var skill in skillsData) {
        controllers[skill["skill_id"]] =
            TextEditingController(text: skill["mark"].toString());
      }

      setState(() {
        skills = skillsData;
        attendance = attendanceData;
        isLoading = false;
      });
    }
  }

  Future<void> saveMarks() async {
    for (var skill in skills) {
      final skillId = skill["skill_id"];
      final mark = int.tryParse(controllers[skillId]!.text) ?? 0;

      await http.post(
        Uri.parse("$baseUrl/marks"),
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

  Future<void> markPresent() async {
    await http.post(
      Uri.parse("$baseUrl/attendance"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "intern_id": internId,
        "date": DateTime.now().toIso8601String(),
        "status": "present",
      }),
    );

    fetchData(); // refresh list
  }

  Widget buildSkillSection() {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Skill Evaluation",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:AppColors.accentPurple)),
          Container(height: 1,width: 300,color: AppColors.accentPurple,margin: EdgeInsets.all(10),),

          const SizedBox(height: 15),

          ...skills.map((skill) {
            final controller = controllers[skill["skill_id"]]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(skill["skill"],
                        style: TextStyle(color:AppColors.textPrimary)),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "0-100",
                      ),
                    ),
                  )
                ],
              ),
            );
          }),

          const SizedBox(height: 10),

          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardLight,     // button color
                foregroundColor: AppColors.accentPurple,
                side: BorderSide(
                color: AppColors.accentPurple,            // border color
                width: 2,                       // border width
                ),
              ),
              onPressed: saveMarks,
              child: const Text("Save Marks" ),
          ),

        ],
      ),
    );
  }

  Widget buildAttendanceSection() {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Attendances",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:AppColors.progressBlue)),
          Container(height: 1,width: 300,color: AppColors.progressBlue,margin: EdgeInsets.all(10),),
          const SizedBox(height: 15),

          ...attendance.map((a) {
            final date = a["date"].toString().split("T")[0];
            return ListTile(
              title: Text(date,
                  style: TextStyle(color:AppColors.textPrimary)),
              trailing: Text(a["status"],
                  style: TextStyle(color:AppColors.textSecondary)),
            );
          }),

          const SizedBox(height: 15),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardLight,     // button color
              foregroundColor: AppColors.progressBlue,
              side: BorderSide(
                color: AppColors.progressBlue,            // border color
                width: 2,                       // border width
              ),
            ),
            onPressed: markPresent,
            child: const Text("Mark Present"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Grading Dashboard")),
      backgroundColor:AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSkillSection(),
            const SizedBox(height: 20),
            buildAttendanceSection(),
          ],
        ),
      ),
    );
  }
}