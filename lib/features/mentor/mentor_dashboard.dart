import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers.dart';
import 'dart:convert';
import '../../core/app_colors.dart';


class MentorDashboard extends ConsumerStatefulWidget {
  const MentorDashboard({super.key});

  @override
  ConsumerState<MentorDashboard> createState() => _MentorDashboardState();
}
class _MentorDashboardState extends ConsumerState<MentorDashboard> {
  List interns = [];
  List filteredInterns = [];
  bool isLoading = true;
  late final baseUrl;
  @override
  void initState() {
    super.initState();
    baseUrl = ref.read(baseUrlProvider);
    fetchInterns();
  }

  Future<void> fetchInterns() async {
    final mentorId = ref.read(userIdProvider);

    final response = await http.get(
      Uri.parse("${baseUrl}/mentor/$mentorId/interns"),
    );

    if (response.statusCode == 200) {
      setState(() {
        interns = jsonDecode(response.body);
        filteredInterns = interns;
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mentor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/mentor/addTraining");
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: _SearchBar(
              onChanged: (value) {
                setState(() {
                  filteredInterns = interns.where((intern) {
                    final name =
                    "${intern["fname"]} ${intern["lname"]}".toLowerCase();
                    final email = intern["email"].toLowerCase();
                    final query = value.toLowerCase();

                    return name.contains(query) || email.contains(query);
                  }).toList();
                });
              },
            ),
          ),

          Expanded( // 🔥 THIS IS THE FIX
            child: ListView.builder(
              itemCount: filteredInterns.length,
              itemBuilder: (context, index) {
                final intern = filteredInterns[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: intern["picture_url"] != null
                          ? NetworkImage(
                          "${baseUrl}/${intern["picture_url"]}")
                          : const AssetImage("assets/images/pfp.png")
                      as ImageProvider,
                    ),
                    title: Text("${intern["fname"]} ${intern["lname"]}"),
                    subtitle: Text(intern["email"]),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/mentor/grading",
                        arguments: intern["intern_id"],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
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