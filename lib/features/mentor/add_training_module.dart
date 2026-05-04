import 'dart:io';
import '../../core/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  @override
  Widget build(BuildContext context) {
    // final AppColors = context.AppColors;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Add Training Module"),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Title
                Text(
                  "Upload Training Module",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Provide a module name and upload a PDF file.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 25),

                // 🔹 Module Name Input
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Module Name",
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.cardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 File Picker Card
                GestureDetector(
                  onTap: pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: AppColors.progressBlue, size: 32),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            selectedFile == null
                                ? "Select PDF file"
                                : selectedFile!.path.split("/").last,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Icon(Icons.upload_file,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : uploadModule,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primaryStart,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      "Upload Module",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}