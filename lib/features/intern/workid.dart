import '../../core/app_colors.dart';
import 'package:flutter/material.dart';
class Intern{
  late String avatar;
  late String name;
  late String Lname;
  late String email;
  late String speciality;

  Intern(String a,String b,String c,String g,String s){
    avatar = a;
    name =b;
    Lname =c;
    email = g;
    speciality = s;
  }
}

class DigitalIDCard extends StatelessWidget {
  final Intern intern;
  const DigitalIDCard({super.key,required this.intern,});

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
            backgroundImage: AssetImage(intern.avatar),
            radius: 60,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(intern.name+' '+intern.Lname ,style: TextStyle(
                  color: AppColors.accentPurple,
                  fontSize: 20
              ),),
              Text(intern.email),
            ],
          )
        ],
      ),
    );
  }
}
