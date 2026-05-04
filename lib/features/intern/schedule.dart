import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../providers.dart';

void showSchedule(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return _ScheduleDialog(ref: ref);
    },
  );
}

class _ScheduleDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _ScheduleDialog({required this.ref});

  @override
  ConsumerState<_ScheduleDialog> createState() => _ScheduleDialogState();
}
class _ScheduleDialogState extends ConsumerState<_ScheduleDialog> {
  List schedules = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    final internId = widget.ref.read(userIdProvider);
    final baseUrl = widget.ref.read(baseUrlProvider);

    final response = await http.get(
      Uri.parse("$baseUrl/intern/$internId/schedule"),
    );

    if (response.statusCode == 200) {
      setState(() {
        schedules = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }
  String getTodayString() {
    const days = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun",
    };

    return days[DateTime.now().weekday]!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: const Text("Schedules"),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : schedules.isEmpty
            ? const Text("No schedule available")
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.cardLight),
            columns: const [
              DataColumn(label: Text("Day")),
              DataColumn(label: Text("Start")),
              DataColumn(label: Text("End")),
            ],
            rows: schedules.map((s) {
              final today = getTodayString();
              if (s["day_of_week"]==today){
                return DataRow(cells: [

                  DataCell(Text(s["day_of_week"], style: TextStyle(color: AppColors.teal),)),

                  DataCell(Text(
                    s["start_time"].toString().substring(0, 5),
                     style: TextStyle(color: AppColors.teal)
                  )),

                  DataCell(Text(
                    s["end_time"].toString().substring(0, 5),
                     style: TextStyle(color: AppColors.teal)
                  )),
                ]);
              }else{
                print("today is ${today}");
              return DataRow(cells: [

                DataCell(Text(s["day_of_week"])),

                DataCell(Text(
                  s["start_time"].toString().substring(0, 5),
                )),

                DataCell(Text(
                  s["end_time"].toString().substring(0, 5),
                )),
              ]);
              }
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}