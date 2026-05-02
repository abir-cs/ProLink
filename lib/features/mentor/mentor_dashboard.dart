import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers.dart';
import 'dart:convert';


class MentorDashboard extends ConsumerStatefulWidget {
  const MentorDashboard({super.key});

  @override
  ConsumerState<MentorDashboard> createState() => _MentorDashboardState();
}
class _MentorDashboardState extends ConsumerState<MentorDashboard> {
  List interns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  Future<void> fetchInterns() async {
    final mentorId = ref.read(userIdProvider);

    final response = await http.get(
      Uri.parse("http://192.168.1.6:3000/mentor/$mentorId/interns"),
    );

    if (response.statusCode == 200) {
      setState(() {
        interns = jsonDecode(response.body);
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
          : ListView.builder(
        itemCount: interns.length,
        itemBuilder: (context, index) {
          final intern = interns[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: intern["picture_url"] != null
                    ? NetworkImage(
                    "http://192.168.1.6:3000/${intern["picture_url"]}")
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
    );
  }
}