import 'package:flutter/material.dart';
import 'package:pro_link/features/admin/intern_service.dart';
import '../intern/workid.dart';
import '../../core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignedInterns extends StatefulWidget {
  const AssignedInterns({super.key});

  @override
  State<AssignedInterns> createState() => _AssignedInternsState();
}

class _AssignedInternsState extends State<AssignedInterns> {
  final ScrollController _scrollController = ScrollController();
  int? highlightedIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future<List<Intern>> interns = InternService.fetchAssignedInterns();
  Future<void> refreshPage() async {
    setState(() {
      interns = InternService.fetchAssignedInterns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIntern =
        ModalRoute.of(context)!.settings.arguments as Intern?;
    return Scaffold(
      appBar: AppBar(title: Text("Interns")),
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
                    "Action",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.primarySoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 30),
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
                      final targetIndex =
                          selectedIntern == null
                              ? -1
                              : data.indexWhere(
                                (i) => i.id == selectedIntern!.id,
                              );
                      if (data.isEmpty) {
                        return const Center(child: Text("No assigned interns"));
                      }
                      if (targetIndex != -1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await _scrollController.animateTo(
                            targetIndex * 97.0, // better if fixed row height
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );

                          setState(() {
                            highlightedIndex = targetIndex;
                          });

                          Future.delayed(const Duration(milliseconds: 900), () {
                            if (mounted) {
                              setState(() {
                                highlightedIndex = null;
                              });
                            }
                          });
                        });
                      }

                      return ListView.builder(
                        itemCount: data.length,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          final isHighlighted = highlightedIndex == index;
                          return internAssignmentRow(data[index], context, (
                            mentor,
                          ) {
                            setState(() {});
                          }, isHighlighted);
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
  bool isHighlighted,
) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 1.0, end: isHighlighted ? 1 : 1),
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutBack,
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isHighlighted
                    ? AppColors.primarySoft.withOpacity(0.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isHighlighted ? 1.0 : 0.92,
            child: child,
          ),
        ),
      );
    },

    // 👇 YOUR ORIGINAL UI (UNCHANGED)
    child: Padding(
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
                      backgroundImage: intern.avatar != null ?

                      NetworkImage("http://192.168.1.4:3000/${intern.avatar!.replaceAll('\\', '/')}")
                          : const AssetImage("assets/images/pfp.png") as ImageProvider,
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
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),

                          if (intern.cv != null) ...[
                            GestureDetector(
                              onTap: () async {
                                final cv = intern.cv!.replaceAll('\\', '/');
                                final uri = Uri.parse(
                                  "http://192.168.1.4:3000/$cv",
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Row(
                children: [
                  /// INFO BUTTON
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: AppColors.primarySoft,
                      size: 20,
                    ),
                    onPressed: () {
                      showInternInfo(context, intern);
                    },
                  ),

                  /// EDIT BUTTON
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primaryStart, size: 20,),
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => AssignInternDialog(intern: intern),
                      );

                      if (result != null) {
                        intern.mentor = result;
                        onAssigned(result);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
        ],
      ),
    ),
  );
}

void showInternInfo(BuildContext context, Intern intern) {
  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text("Intern Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("First name: ${intern.name}"),
              Text("Last name: ${intern.lname}"),
              Text("Email: ${intern.email}"),
              Text("Age: ${intern.age}"),

              /// DEPARTMENT
              FutureBuilder<Department>(
                future: InternService.fetchDepartmentFromId(
                  int.parse(intern.department!),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Department: loading...");
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    print("❤️Department ERROR: ${snapshot.error}");
                    return const Text("Department: N/A");
                  }
                  return Text("Department: ${snapshot.data!.name}");
                },
              ),
              FutureBuilder<Mentor>(
                future: InternService.fetchMentorFromId(
                  int.parse(intern.mentor!),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Mentor: loading...");
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text("Mentor: N/A");
                  }

                  final m = snapshot.data!;
                  return Text("Mentor: ${m.fname} ${m.lname}");
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
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
        "Update",
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
          child: const Text("Update"),
        ),
      ],
    );
  }
}
