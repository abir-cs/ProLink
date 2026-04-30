import 'package:flutter/material.dart';
import '../intern/workid.dart';
import '../../core/app_colors.dart';

class InternsValidation extends StatelessWidget {

  const InternsValidation({
    super.key,
  });
  static List<Intern> interns = [
    Intern("assets/images/pfp.png", "Abir", "Belhadef", "abir@mail.com", "CS"),
    Intern("assets/images/pfp.png", "Sara", "Ali", "sara@mail.com", "IS"),
    Intern("assets/images/pfp.png", "Mohamed", "Amine", "mohamed@mail.com", "AI"),
    Intern("assets/images/pfp.png", "Yasmine", "Kouider", "yasmine@mail.com", "Cyber Security"),
    Intern("assets/images/pfp.png", "Karim", "Haddad", "karim@mail.com", "Data Science"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interns to Validate"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Intern",
                      style: TextStyle(
                        color: AppColors.primarySoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Speciality",
                      style: TextStyle(
                        color: AppColors.primarySoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 80), // space for buttons
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.05)),
              Expanded(
                child: ListView.builder(
                  itemCount: interns.length,
                  itemBuilder: (context, index) {
                    final intern = interns[index];
                    return internValidationRow(intern);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget internValidationRow(Intern intern) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage(intern.avatar),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "${intern.name} ${intern.Lname}",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                intern.speciality,
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.check, size: 18, color: AppColors.teal),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 18, color: Colors.pink),
                  ),
                ),
              ],
            ),
          ],
        ),
        Divider(color: Colors.white.withOpacity(0.05)),
      ],
    ),

  );
}