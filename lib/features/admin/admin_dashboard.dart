import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/app_colors.dart';
import '../../routes/routes.dart';
import '../intern/workid.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  static Intern intern = Intern(
    "/assets/images/pfp.png",
    "abir",
    "belhadef",
    "abir@gmail.com",
    "CS",
  );
  static int pendingInterns = 5;
  static int InternsToAssign = 5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: AppColors.textSecondary),

                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),

                  filled: true,
                  fillColor: AppColors.cardDark,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.border),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.primarySoft,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 400,
              height: 50,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppGradients.teal,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: AppColors.cardDark,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Upload Schedules",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.iv);
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primarySoft, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Interns to Validate (${pendingInterns})",
                      style: TextStyle(
                        color: AppColors.primarySoft,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Intern',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primarySoft,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Speciality',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primarySoft,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    internRow(intern),
                    internRow(intern),
                    internRow(intern),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.isa);
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primarySoft, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Interns to Assign (${InternsToAssign})",
                      style: TextStyle(
                        color: AppColors.primarySoft,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text(
                          'Intern',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primarySoft,
                          ),
                        ),
                        SizedBox(width: 210),
                        Text(
                          'Speciality',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primarySoft,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    internRow(intern),
                    internRow(intern),
                    internRow(intern),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget internRow(Intern intern) {
  Color statusColor;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage("assets/images/pfp.png"),
        ),
        SizedBox(width: 10),
        Text(
          intern.name + " " + intern.Lname,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 160),
        Text(
          intern.speciality,
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
