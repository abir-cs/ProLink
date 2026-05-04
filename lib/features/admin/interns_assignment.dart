import 'package:flutter/material.dart';
import 'package:pro_link/features/admin/intern_service.dart';
import '../intern/workid.dart';
import '../../core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class InternsAssignment extends StatefulWidget {
  const InternsAssignment({super.key});

  @override
  State<InternsAssignment> createState() => _InternsAssignmentState();
}

class _InternsAssignmentState extends State<InternsAssignment> {
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<Intern>> interns =
      InternService.fetchInternsnotAssignedToMentor();
  Future<void> refreshPage() async {
    setState(() {
      interns = InternService.fetchInternsnotAssignedToMentor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Intern? selected =
        ModalRoute.of(context)!.settings.arguments as Intern?;
    return Scaffold(
      appBar: AppBar(title: Text("Interns to Validate")),
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
                  // pushes the next widget to the far right
                  Spacer(),
                  Text(
                    "Decision",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.primarySoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.05)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshPage,
                  child: FutureBuilder<List<Intern>>(
                    future: interns,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading interns"),
                        );
                      }
                      final data = snapshot.data ?? [];
                      if (data.isEmpty) {
                        return const Center(child: Text("No pending interns"));
                      }
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return internAssignmentRow(data[index], context, (
                            mentor,
                          ) {
                            setState(() {});
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget internAssignmentRow(
  Intern intern,
  BuildContext context,
  Function(Mentor mentor) onAssigned,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      children: [
        Row(
          children: [
            /// Avatar + Info
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      intern.avatar ?? 'assets/images/pfp.png',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${intern.name} ${intern.lname}",
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          intern.email,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(
                              "http://192.168.1.4:3000/uploads/cv/cv.pdf", //to change later
                            );

                            final success = await launchUrl(
                              uri,
                              mode: LaunchMode.platformDefault,
                            );

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Could not open CV"),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "View CV",
                            style: TextStyle(
                              color: AppColors.primarySoft,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (intern.mentor != null) ...[
              Text(
                "Assigned",
                style: TextStyle(
                  color: AppColors.primarySoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (_) => AssignInternDialog(intern: intern),
                  );

                  if (result != null) {
                    intern.mentor = result;
                    onAssigned(result);
                  }
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
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
      ],
    ),
  );
}

class AssignInternDialog extends StatefulWidget {
  final Intern intern;

  const AssignInternDialog({Key? key, required this.intern}) : super(key: key);
  @override
  State<AssignInternDialog> createState() => _AssignInternDialogState();
}

class _AssignInternDialogState extends State<AssignInternDialog> {
  Department? selectedDepartment;
  Mentor? selectedMentor;

  List<Department> departments = [];
  List<Mentor> mentors = [];

  bool loadingDepartments = true;
  bool loadingMentors = false;

  @override
  void initState() {
    super.initState();
    loadDepartments();
    loadMentors(null);
  }

  Future<void> loadDepartments() async {
    departments = await InternService.fetchDepartments();
    setState(() => loadingDepartments = false);
  }

  Future<void> loadMentors(int? deptId) async {
    setState(() => loadingMentors = true);

    mentors =
        deptId == null
            ? await InternService.fetchMentors()
            : await InternService.fetchSpecificDepartmentMentors(deptId);

    selectedMentor = null;

    setState(() => loadingMentors = false);
  }

  @override
  Widget build(BuildContext context) {
    final canAssign = selectedDepartment != null && selectedMentor != null;

    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: Text(
        "Assign Intern",
        style: TextStyle(color: AppColors.textPrimary),
      ),

      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loadingDepartments
                  ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : DropdownButtonFormField<Department>(
                    dropdownColor: AppColors.cardDark,
                    decoration: InputDecoration(
                      labelText: "Department",
                      labelStyle: TextStyle(color: AppColors.textPrimary),
                    ),
                    value: selectedDepartment,
                    items:
                        departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment = value;
                      });

                      loadMentors(value?.id);
                    },
                  ),
              const SizedBox(height: 15),

              loadingMentors
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Mentor>(
                    dropdownColor: AppColors.cardDark,
                    decoration: InputDecoration(
                      labelText: "Mentor",
                      labelStyle: TextStyle(color: AppColors.textPrimary),
                    ),
                    value: selectedMentor,
                    items:
                        mentors.map((mentor) {
                          return DropdownMenuItem(
                            value: mentor,
                            child: Text("${mentor.fname} ${mentor.lname}"),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMentor = value;
                      });
                    },
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed:
              canAssign
                  ? () async {
                    final success = await InternService.assignIntern(
                      internId: widget.intern.id,
                      mentorId: selectedMentor!.id,
                      departmentId: selectedDepartment!.id,
                    );
                    if (success && mounted) {
                      Navigator.pop(context, selectedMentor!.id.toString());
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Assignment failed")),
                      );
                    }
                  }
                  : null,
          child: const Text("Assign"),
        ),
      ],
    );
  }
}
