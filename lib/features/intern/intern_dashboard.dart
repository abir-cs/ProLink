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

  @override
  void initState() {
    super.initState();
    fetchIntern();
  }

  Future<void> fetchIntern() async {
    final userId = ref.read(userIdProvider);

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.6:3000/intern/$userId"),
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


  static int totalModules=5;
  static int completedModules=3;

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
                  fontSize: 25
              ),
            ),
            Row(
              children: List.generate(totalModules, (index) {
                bool isCompleted = index < completedModules;

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
              "succeeded ${completedModules} training modules out of ${totalModules}",
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
                      showSchedule(context);
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
