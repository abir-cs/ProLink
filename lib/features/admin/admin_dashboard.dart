import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as ref;
import 'package:pro_link/features/providers.dart';
import '../../core/app_colors.dart';
import '../../routes/routes.dart';
import '../intern/workid.dart';
import 'intern_service.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  String query = "";

  List<Intern> validate = [];
  List<Intern> assign = [];
  List<Intern> assigned = [];
  List<SearchResult> results = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    validate = await InternService.fetchPendingInterns();
    assign = await InternService.fetchInternsnotAssignedToMentor();
    assigned = await InternService.fetchAssignedInterns();
    setState(() {});
  }

  List<SearchResult> searchInterns(
    String query,
    List<Intern> validate,
    List<Intern> assign,
  ) {
    if (query.isEmpty) return [];

    final q = query.toLowerCase();
    List<SearchResult> results = [];

    for (final i in validate) {
      if ("${i.name} ${i.lname}".toLowerCase().contains(q)) {
        results.add(SearchResult(intern: i, source: "validate"));
      }
    }

    for (final i in assign) {
      if ("${i.name} ${i.lname}".toLowerCase().contains(q)) {
        results.add(SearchResult(intern: i, source: "assign"));
      }
    }

    for (final i in assigned) {
      if ("${i.name} ${i.lname}".toLowerCase().contains(q)) {
        results.add(SearchResult(intern: i, source: "assigned"));
      }
    }

    return results;
  }

  void openIntern(SearchResult item) {
    if (item.source == "validate") {
      Navigator.pushNamed(context, AppRoutes.iv, arguments: item.intern);
    } else if(item.source == "assign") {
      Navigator.pushNamed(context, AppRoutes.isa, arguments: item.intern);
    }
    else{
      Navigator.pushNamed(context, AppRoutes.ai, arguments: item.intern);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              children: [
                _SearchBar(
                  onChanged: (value) {
                    setState(() {
                      query = value;
                      results = searchInterns(query, validate, assign);
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.ca);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings_sharp,
                                size: 28,
                                color: AppColors.cardDark,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Create Admin",
                                style: TextStyle(
                                  color: AppColors.cardDark,
                                  fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.cm);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.person_add_alt_1,
                                size: 28,
                                color: AppColors.cardDark,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Create Mentor",
                                style: TextStyle(
                                  color: AppColors.cardDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _UploadButton(),
                SizedBox(height: 15),
                Expanded(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: const [
                            PendingInternsCard(),
                            SizedBox(height: 10),
                            InternsToAssignCard(),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
            if (query.isNotEmpty && results.isNotEmpty)
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.cardDark,
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];

                        return ListTile(
                          title: Text(
                            "${item.intern.name} ${item.intern.lname}",
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(item.source),
                          onTap: () => openIntern(item),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchResult {
  final Intern intern;
  final String source; // "validate" or "assign"

  SearchResult({required this.intern, required this.source});
}

class _SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Search interns...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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
          backgroundImage: intern.avatar != null ?

          NetworkImage("http://192.168.1.4:3000/${intern.avatar!.replaceAll('\\', '/')}")
              : const AssetImage("assets/images/pfp.png") as ImageProvider,
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

  final days = ["Sun", "Mon", "Tue", "Wed", "Thu"];

  @override
  void initState() {
    super.initState();
    loadMentors();
  }

  Future<void> loadMentors() async {
    mentors = await InternService.fetchMentors();
    setState(() => loadingMentors = false);
  }

  void showBottomMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
                              const int minWorkTime = 8 * 60; // 08:00
                              const int maxWorkTime = 18 * 60; // 20:00
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
                              if (start < minWorkTime || end > maxWorkTime) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Working hours must be between 08:00 and 18:00",
                                    ),
                                  ),
                                );
                                return;
                              }
                              Future<void> submitSchedule() async {
                                await InternService.replaceSchedule(
                                  mentorId: selectedMentor!.id,
                                  days: selectedDays,
                                  startTime: formatTime24(startTime!),
                                  endTime: formatTime24(endTime!),
                                );
                                showBottomMessage(
                                  context,
                                  "Schedule replaced successfully",
                                );
                              }

                              try {
                                bool exists =
                                    await InternService.checkMentorSchedule(
                                      selectedMentor!.id,
                                    );

                                if (exists) {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: AppColors.cardLight,
                                        title: const Text(
                                          "Schedule already exists",
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "This mentor already has a schedule.",
                                            ),
                                            const SizedBox(height: 10),
                                            // Placeholder schedule preview button
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Cancel"),
                                          ),

                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text("Replace"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm != true) return;

                                  await submitSchedule();
                                } else {
                                  await InternService.createScheduleBatch(
                                    mentorId: selectedMentor!.id,
                                    days: selectedDays,
                                    startTime: formatTime24(startTime!),
                                    endTime: formatTime24(endTime!),
                                  );
                                  showBottomMessage(
                                    context,
                                    "Schedule created successfully",
                                  );
                                }
                              } catch (e) {
                                showBottomMessage(
                                  context,
                                  "Operation failed: $e",
                                  isError: true,
                                );
                              }
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
