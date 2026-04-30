import 'package:flutter/material.dart';
import '../intern/workid.dart';
import '../../core/app_colors.dart';

class InternsAssignment extends StatelessWidget {

  const InternsAssignment({
    super.key,
  });
  static List<Intern> interns = [
    Intern("assets/images/pfp.png", "Abir", "Belhadef", "abir@mail.com"),
    Intern("assets/images/pfp.png", "Sara", "Ali", "sara@mail.com"),
    Intern("assets/images/pfp.png", "Mohamed", "Amine", "mohamed@mail.com"),
    Intern("assets/images/pfp.png", "Yasmine", "Kouider", "yasmine@mail.com"),
    Intern("assets/images/pfp.png", "Karim", "Haddad", "karim@mail.com"),
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
                    return internValidationRow(intern,context);
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
Widget internValidationRow(Intern intern,BuildContext context) {
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

            GestureDetector(
              onTap: () {
                showAssignDialog(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Assign',
                  style: TextStyle(
                    color: AppColors.primarySoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
        Divider(color: Colors.white.withOpacity(0.05)),
      ],
    ),

  );
}
void showAssignDialog(BuildContext context) {
  String? selectedDepartment;
  String? selectedMentor;

  final departments = ["IT", "AI", "Networks", "Security"];
  final mentors = ["Dr. Smith", "Prof. Ali", "Dr. Sara"];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          "Assign Intern",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Department Dropdown
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.cardDark,
                      decoration: InputDecoration(
                        labelText: "Department",
                        labelStyle:
                        TextStyle(color: AppColors.textPrimary),
                      ),
                      items: departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value;
                        });
                      },
                    ),

                    SizedBox(height: 15),

                    /// Mentor Dropdown
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.cardDark,
                      decoration: InputDecoration(
                        labelText: "Mentor",
                        labelStyle:
                        TextStyle(color: AppColors.textPrimary),
                      ),
                      items: mentors.map((mentor) {
                        return DropdownMenuItem(
                          value: mentor,
                          child: Text(mentor),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMentor = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        /// Actions
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: save assignment
              print("Dept: $selectedDepartment");
              print("Mentor: $selectedMentor");

              Navigator.pop(context);
            },
            child: Text("Assign"),
          ),
        ],
      );
    },
  );
}