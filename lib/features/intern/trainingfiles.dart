import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers.dart';

class TrainingFiles extends ConsumerStatefulWidget {
  const TrainingFiles({super.key});

  @override
  ConsumerState<TrainingFiles> createState() => _TrainingFilesState();
}
class _TrainingFilesState extends ConsumerState<TrainingFiles> {
  List modules = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    final internId = ref.read(userIdProvider);
    final baseUrl = ref.read(baseUrlProvider);

    final response = await http.get(
      Uri.parse("${baseUrl}/intern/$internId/training"),
    );

    if (response.statusCode == 200) {
      setState(() {
        modules = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }
  Future<void> openFile(String path) async {
    final baseUrl = ref.read(baseUrlProvider);
    final url = Uri.parse("${baseUrl}/$path");

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Training Files")),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : modules.isEmpty
        ? const Center(child: Text("No training modules available"),)
        : ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];

          final date = DateTime.parse(module["uploaded_at"])
              .toLocal()
              .toString()
              .split(" ")[0];

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module["name"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text("Published: $date"),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () =>
                          openFile(module["file_url"]),
                      child: const Text("View"),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

