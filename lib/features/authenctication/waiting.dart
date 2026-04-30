import 'package:flutter/material.dart';
class Waiting extends StatelessWidget {
  const Waiting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("wait for the admin to validate your registration ..."),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Image(image: AssetImage("assets/images/img.png",)),
            )
          ],
        ),
      ),
    );
  }
}
