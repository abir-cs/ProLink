import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import '../../core/app_colors.dart';
import 'workid.dart';
import 'schedule.dart';
import '../../routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'package:http/http.dart' as http;

class InternDashboard extends ConsumerStatefulWidget {
  const InternDashboard({super.key});

  @override
  ConsumerState<InternDashboard> createState() => _InternDashboardState();
}
class _InternDashboardState extends ConsumerState<InternDashboard> {
  Intern? intern;
  bool isLoading = true;
  double avg = 0;
  int progressSections = 0;

  @override
  void initState() {
    super.initState();
    fetchIntern();
    fetchAverage();

  }

  Future<void> fetchIntern() async {
    final userId = ref.read(userIdProvider);
    final baseUrl = ref.read(baseUrlProvider);

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/intern/$userId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          intern = Intern.fromJson(data);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchAverage() async {
    final internId = ref.read(userIdProvider);
    final baseUrl = ref.read(baseUrlProvider);

    final response = await http.get(
      Uri.parse("$baseUrl/intern/$internId/average-mark"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final avgMark = double.tryParse(data["avg_mark"].toString()) ?? 0;

      setState(() {
        avg = (avgMark*100).floor()/100;
        progressSections = (avgMark / 10).floor(); // 👈 your requirement
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (intern == null) {
      return const Center(child: Text("Error loading data"));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Intern Dashboard")),
      body:
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DigitalIDCard(
              intern: intern!,
              onPictureUpdated: fetchIntern,
            ),
            SizedBox(height: 20),
            Text(
              "Progress Made",
              style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 20
              ),
            ),
            Row(
              children: List.generate(10, (index) {
                bool isCompleted = index < progressSections;

                return Expanded(
                  child: Container(

                    margin: const EdgeInsets.symmetric(vertical: 5 ,horizontal: 1),
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.teal : AppColors.textMuted,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              }),
            ),
            Text(
              "Average of your marks so far is ${avg}/100",
              style: TextStyle(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      showSchedule(context, ref);
                    },
                    child: Container(

                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark, // Dark navy circle
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.schedule,
                              size: 30,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      SizedBox(height: 12),
                      Text(
                        "Shift Schedule",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "check them out",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary, // Beige-like color
                        ),
                      ),
                    ]
                                    ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, AppRoutes.tf);
                    },
                    child: Container(

                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primarySoft,
                          width: 0.5,
                        ),
                      ),

                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary, // Dark navy circle
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.file_copy,
                                size: 30,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Training Files",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "Read",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary, // Beige-like color
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, AppRoutes.ia);
                    },
                    child: Container(

                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primarySoft,
                          width: 0.5,
                        ),
                      ),

                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary, // Dark navy circle
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment,
                                size: 30,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Assignments",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "what to do + export",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary, // Beige-like color
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, AppRoutes.marks);
                    },
                    child: Container(

                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppGradients.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark, // Dark navy circle
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.checklist_rtl_sharp,
                                size: 30,
                                color: AppColors.teal,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Skill marks",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                            Text(
                              "check them out",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.teal, // Beige-like color
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ]
        ),
      )
    );
  }
}
