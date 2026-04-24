import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
void showSchedule(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text("Schedules"),
        content: const Text("Tmmmmmmmmmm."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}