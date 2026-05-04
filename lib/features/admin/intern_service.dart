import 'dart:convert';
import 'package:http/http.dart' as http;
import '/features/intern/workid.dart';

class InternService {
  static Future<List<Intern>> fetchPendingInterns() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/interns/pending'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((json) => Intern.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load interns");
    }
  }

  static Future<void> updateInternStatus(int internId, String status) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.4:3000/interns/$internId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update status");
    }
  }

  static Future<bool> assignIntern({
    required int internId,
    required int mentorId,
    required int departmentId
  }) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.4:3000/interns/$internId/assign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mentor_id': mentorId, 'department_id': departmentId}),
    );

    if (response.statusCode == 200) {
      return true;
    }
    else{
      throw Exception("Failed to assign intern");
    }
  }

  static Future<List<Intern>> fetchInternsnotAssignedToMentor() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/interns/waitingassignment'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((json) => Intern.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load interns");
    }
  }

  static Future<List<Department>> fetchDepartments() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/departments'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Department.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load departments");
    }
  }

  static Future<List<Mentor>> fetchMentors() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/mentors'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Mentor.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load mentors");
    }
  }

  static Future<List<Mentor>> fetchSpecificDepartmentMentors(
    int departmentId,
  ) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/departments/$departmentId/mentors'),
    );
    print("❤️STATUS: ${response.statusCode}");
    print("❤️BODY: ${response.body}");
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Mentor.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load Mentors");
    }
  }
  static Future<void> createScheduleBatch({
    required int mentorId,
    required List<String> days,
    required String startTime,
    required String endTime,
  }) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.4:3000/schedules/batch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mentor_id': mentorId,
        'days': days,
        'start_time': startTime,
        'end_time': endTime,
      }),
    );
    print("❤️STATUS: ${response.statusCode}");
    if (response.statusCode != 201) {
      throw Exception("Failed to create schedule batch");
    }
  }
  static Future<void> replaceSchedule({
    required int mentorId,
    required List<String> days,
    required String startTime,
    required String endTime,
  }) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.4:3000/schedules/replace'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mentor_id': mentorId,
        'days': days,
        'start_time': startTime,
        'end_time': endTime,
      }),
    );
    print("❤️STATUS: ${response.statusCode}");
    if (response.statusCode != 201) {
      throw Exception("Failed to replace schedule");
    }
  }
  static Future<bool> checkMentorSchedule(int mentorId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/schedules/mentor/$mentorId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["exists"] == true;
    } else {
      throw Exception("Failed to check schedule");
    }
  }
}

class Department {
  final int id;
  final String name;
  final String description;
  Department({required this.id, required this.name, required this.description});
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json["department_id"],
      name: json["name"],
      description: json["description"],
    );
  }
}

class Mentor {
  final int id;
  final String fname;
  final String lname;
  final String email;
  final int departmentId;

  Mentor({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.departmentId,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json["mentor_id"],
      fname: json["fname"],
      lname: json["lname"],
      email: json["email"],
      departmentId: json["department_id"],
    );
  }
}
