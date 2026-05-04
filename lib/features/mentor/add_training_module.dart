import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class AddTrainingPage extends ConsumerStatefulWidget {
  const AddTrainingPage({super.key});

  @override
  ConsumerState<AddTrainingPage> createState() => _AddTrainingPageState();
}

class _AddTrainingPageState extends ConsumerState<AddTrainingPage> {
  final nameController = TextEditingController();

  File? selectedFile;
  bool isLoading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadModule() async {
    final mentorId = ref.read(userIdProvider);
    final name = nameController.text.trim();
    final baseUrl = ref.read(baseUrlProvider);

    if (name.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${baseUrl}/training"),
      );

      request.fields["mentor_id"] = mentorId.toString();
      request.fields["name"] = name;

      request.files.add(
        await http.MultipartFile.fromPath("file", selectedFile!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Module uploaded")),
        );

        Navigator.pop(context);
      } else {
        final resBody = await http.Response.fromStream(response);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resBody.body)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Training Module")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Module Name"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickFile,
              child: Text(
                selectedFile == null
                    ? "Select PDF"
                    : "PDF Selected",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : uploadModule,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}