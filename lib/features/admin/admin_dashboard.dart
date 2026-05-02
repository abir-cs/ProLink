import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../routes/routes.dart';
import '../intern/workid.dart';
import 'intern_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SearchBar(),

            const SizedBox(height: 20),

            _UploadButton(),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    PendingInternsCard(),
                    SizedBox(height: 20),
                    InternsToAssignCard(),
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

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.cardDark,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.primarySoft),
          ),
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => const CreateScheduleDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: AppGradients.teal,
          borderRadius: BorderRadius.circular(80),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, size: 30, color: AppColors.cardDark),
            SizedBox(width: 10),
            Text(
              "Upload Schedules",
              style: TextStyle(
                color: AppColors.cardDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingInternsCard extends StatelessWidget {
  const PendingInternsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.iv);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primarySoft, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Interns to Validate",
              style: TextStyle(color: AppColors.primarySoft, fontSize: 22),
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<Intern>>(
              future: InternService.fetchPendingInterns(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Error loading interns");
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No waiting interns horay!",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                final preview = data.take(3).toList();
                return SizedBox(
                  height: preview.length * 50,
                  child: ListView.builder(
                    itemCount: preview.length,
                    itemBuilder: (context, index) {
                      return _internRow(data[index]);
                    },
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,

              child: const Text(
                "View all",
                style: TextStyle(
                  color: AppColors.primarySoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InternsToAssignCard extends StatelessWidget {
  const InternsToAssignCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.isa);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primarySoft, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Interns to Assign",
              style: TextStyle(color: AppColors.primarySoft, fontSize: 22),
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<Intern>>(
              future: InternService.fetchInternsnotAssignedToMentor(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Error loading interns");
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No interns waiting for assignment.",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                final preview = data.take(3).toList();

                return SizedBox(
                  height: preview.length * 50,
                  child: ListView.builder(
                    itemCount: preview.length,
                    itemBuilder: (context, index) {
                      return _internRow(data[index]);
                    },
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: const Text(
                "View all",
                style: TextStyle(
                  color: AppColors.primarySoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _internRow(Intern intern) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage(intern.avatar ?? 'assets/images/pfp.png'),
        ),
        const SizedBox(width: 10),
        Text(
          "${intern.name} ${intern.lname}",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class CreateScheduleDialog extends StatefulWidget {
  const CreateScheduleDialog({super.key});

  @override
  State<CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<CreateScheduleDialog> {
  Mentor? selectedMentor;

  List<Mentor> mentors = [];
  bool loadingMentors = true;

  List<String> selectedDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final days = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    loadMentors();
  }

  Future<void> loadMentors() async {
    mentors = await InternService.fetchMentors();
    setState(() => loadingMentors = false);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final canSave =
        selectedMentor != null &&
        selectedDays.isNotEmpty &&
        startTime != null &&
        endTime != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Text(
                "Create Schedule",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              /// 👨‍🏫 MENTOR
              const Text(
                "Mentor",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              loadingMentors
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Mentor>(
                    value: selectedMentor,
                    dropdownColor: AppColors.cardDark,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        mentors.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text("${m.fname} ${m.lname}"),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => selectedMentor = value);
                    },
                  ),

              const SizedBox(height: 20),

              /// 📅 DAYS
              const Text(
                "Select Days",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    days.map((day) {
                      final selected = selectedDays.contains(day);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selected
                                ? selectedDays.remove(day)
                                : selectedDays.add(day);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? AppColors.primarySoft
                                    : AppColors.background,
                            borderRadius: BorderRadius.circular(50), // 🔥 HERE
                            border: Border.all(
                              color:
                                  selected
                                      ? AppColors.primarySoft
                                      : AppColors.primarySoft.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              color:
                                  selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              /// ⏰ TIME SECTION
              Row(
                children: [
                  Expanded(
                    child: _buildTimeBox(
                      label: "Start",
                      value: startTime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => startTime = time);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeBox(
                      label: "End",
                      value: endTime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => endTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// ACTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canSave
                              ? AppColors.primarySoft
                              : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:
                        canSave
                            ? () async {
                              final start =
                                  startTime!.hour * 60 + startTime!.minute;
                              final end = endTime!.hour * 60 + endTime!.minute;

                              if (end <= start) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "End time must be after start time",
                                    ),
                                  ),
                                );
                                return;
                              }
                              await InternService.createScheduleBatch(
                                mentorId: selectedMentor!.id,
                                days: selectedDays,
                                startTime: formatTime24(startTime!),
                                endTime: formatTime24(endTime!),
                              );

                              if (mounted) Navigator.pop(context, true);
                            }
                            : null,
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primarySoft.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 5),
            Text(
              value == null ? "--:--" : value.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime24(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m:00";
  }
}
