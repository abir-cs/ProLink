import '../../core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Intern {
  final int id;
  final String? avatar;
  final String name;
  final String lname;
  final String email;
  late String? status;
  final String? department;
  final String? mentor;
  final String? cv;

  Intern({
    required this.id,
    required this.avatar,
    required this.name,
    required this.lname,
    required this.email,
    required this.status,
    required this.department,
    required this.mentor,
    required this.cv,
  });

  factory Intern.fromJson(Map<String, dynamic> json) {
    return Intern(
      id: json["intern_id"],
      avatar: json["picture_url"],
      name: json["fname"],
      lname: json["lname"],
      email: json["email"],
      status: json["status"],
      department: json["department_name"],
      mentor: json["mentor_fname"],
      cv: json["cv"],
    );
  }
}

class DigitalIDCard extends ConsumerStatefulWidget {
  final Intern intern;
  final VoidCallback? onPictureUpdated;

  const DigitalIDCard({
    super.key,
    required this.intern,
    this.onPictureUpdated,
  });

  @override
  ConsumerState<DigitalIDCard> createState() => _DigitalIDCardState();
}

class _DigitalIDCardState extends ConsumerState<DigitalIDCard> {
  late final baseUrl ;
  @override
  void initState() {
    super.initState();
    baseUrl = ref.read(baseUrlProvider);
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primarySoft,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(

            backgroundImage: widget.intern.avatar != null ?

                  NetworkImage("${baseUrl}/${widget.intern.avatar}")
                : const AssetImage("assets/images/pfp.png") as ImageProvider,
            radius: 60,
          ),
          Container(width: 1,height: 100,color: AppColors.textMuted,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.intern.name+' '+widget.intern.lname ,style: TextStyle(
                  color: AppColors.accentPurple,
                  fontSize: 20
              ),),
              Text(widget.intern.email),
              Text("department : ${widget.intern.department}"),
              Text("mentor : ${widget.intern.mentor}"),

              //edit picture button
              TextButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile == null) return;

                    final userId = ref.read(userIdProvider);

                    try {
                      var request = http.MultipartRequest(
                        "PUT",
                        Uri.parse("${baseUrl}/intern/$userId/picture"),
                      );

                      request.files.add(
                        await http.MultipartFile.fromPath("picture", pickedFile.path),
                      );

                      var response = await request.send();

                      if (response.statusCode == 200) {
                        widget.onPictureUpdated?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile picture updated")),
                        );

                        // Refresh dashboard
                        if (context.mounted) {
                          (context as Element).markNeedsBuild();
                        }

                      } else {
                        print (response.statusCode);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Upload failed")),
                        );
                      }

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error uploading image")),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.edit ,color: AppColors.progressBlue,),
                      SizedBox(width: 5,),
                      Text("edit picture",
                      style: TextStyle(
                        color: AppColors.progressBlue
                      ),)
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
