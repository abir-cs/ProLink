import 'package:flutter/material.dart';
import '../intern/workid.dart';
import '../../core/app_colors.dart';
import 'intern_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InternsValidation extends StatefulWidget {
  const InternsValidation({Key? key}) : super(key: key);

  @override
  State<InternsValidation> createState() => _InternsValidationState();
}
class _InternsValidationState extends State<InternsValidation> {
  Future<List<Intern>> interns = InternService.fetchPendingInterns();
  Future<void> refreshPage() async {
    setState(() {
      interns = InternService.fetchPendingInterns();
    });
  }
  @override
  Widget build(BuildContext context) {
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
                  SizedBox(width: 15),
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
                      return const Center(child: Text("Error loading interns"));
                    }

                    final data = snapshot.data ?? [];

                    if (data.isEmpty) {
                      return const Center(child: Text("No pending interns"));
                    }

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return internValidationRow(context,data[index],setState,);
                      },
                    );
                  },
                ),
              ),)
            ],
          ),
        ),
      ),
    );
  }
}

Widget internValidationRow( BuildContext context,Intern intern,void Function(void Function()) setState,) {

  Future<bool> _showConfirmDialog(String action) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text(
            "Confirm $action",
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to $action this intern?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Yes",
                style: TextStyle(
                  color: action == "accept"
                      ? AppColors.teal
                      : Colors.pink,
                ),
              ),
            ),
          ],
        );
      },
    ) ??
        false;
  }

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
                              "http://192.168.1.7:3000/uploads/cv/cv.pdf",//to change later
                            );

                            final success = await launchUrl(
                              uri,
                              mode: LaunchMode.platformDefault,
                            );

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Could not open CV")),
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

            if (intern.status == "waiting") ...[
              /// ACCEPT BUTTON
              GestureDetector(
                onTap: () async {
                  final confirmed = await _showConfirmDialog("accept");

                  if (confirmed) {
                    await InternService.updateInternStatus(intern.id, "accepted");

                    setState(() {
                      intern.status = "accepted";
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.teal,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// REJECT BUTTON
              GestureDetector(
                onTap: () async {
                  final confirmed = await _showConfirmDialog("reject");

                  if (confirmed) {
                    await InternService.updateInternStatus(intern.id, "rejected");

                    setState(() {
                      intern.status = "rejected";
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.pink,
                  ),
                ),
              ),
            ] else ...[
              /// STATUS BADGE (AFTER UPDATE)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: intern.status == "accepted"
                      ? AppColors.teal.withOpacity(0.12)
                      : Colors.pink.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  intern.status.toUpperCase(),
                  style: TextStyle(
                    color: intern.status == "accepted"
                        ? AppColors.teal
                        : Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
      ],
    ),
  );
}

