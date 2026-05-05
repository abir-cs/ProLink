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
  int? highlightedIndex;
  @override
  Widget build(BuildContext context) {
    final selectedIntern = ModalRoute.of(context)!.settings.arguments as Intern?;
    final ScrollController _scrollController = ScrollController();

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
                    final targetIndex = selectedIntern == null
                        ? -1
                        : data.indexWhere((i) => i.id == selectedIntern!.id);

                    if (data.isEmpty) {
                      return const Center(child: Text("No pending interns"));
                    }
                    if (targetIndex != -1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        // 1. scroll first
                        await _scrollController.animateTo(
                          targetIndex * 100.0, // better if fixed row height
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );

                        // 2. highlight after scroll finishes
                        setState(() {
                          highlightedIndex = targetIndex;
                        });

                        // 3. fade out highlight
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
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final isHighlighted = highlightedIndex == index;
                        return internValidationRow(context, data[index], setState,isHighlighted);
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

Widget internValidationRow(
    BuildContext context,
    Intern intern,
    void Function(void Function()) setState,
    bool isHighlighted,
    ) {


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

  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutBack,
    tween: Tween<double>(
      begin: 1.0,
      end: isHighlighted ? 1.0: 1.0,
    ),
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.teal.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isHighlighted ? 1.0 : 0.92, // 🌫 subtle fade
            child: child,
          ),
        ),
      );
    },

    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
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
                                final cv =
                                intern.cv!.replaceAll('\\', '/');
                                final uri = Uri.parse(
                                  "http://192.168.1.4:3000/$cv",
                                );

                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.platformDefault,
                                );
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
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (intern.status == "waiting") ...[
                GestureDetector(
                  onTap: () async {
                    final confirmed =
                    await _showConfirmDialog("accept");

                    if (confirmed) {
                      await InternService.updateInternStatus(
                          intern.id, "accepted");

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
                    child: const Icon(Icons.check,
                        size: 18, color: AppColors.teal),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () async {
                    final confirmed =
                    await _showConfirmDialog("reject");

                    if (confirmed) {
                      await InternService.updateInternStatus(
                          intern.id, "rejected");

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
                    child: const Icon(Icons.close,
                        size: 18, color: Colors.pink),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: intern.status == "accepted"
                        ? AppColors.teal.withOpacity(0.12)
                        : Colors.pink.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    intern.status!.toUpperCase(),
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
    ),
  );
}