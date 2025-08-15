import 'package:e_riksha/res/AppImages.dart';
import 'package:flutter/material.dart';

class Rolesectionscreen extends StatefulWidget {
  const Rolesectionscreen({super.key});

  @override
  State<Rolesectionscreen> createState() => _RolesectionscreenState();
}

class _RolesectionscreenState extends State<Rolesectionscreen> {
  @override
  Widget build(BuildContext context) {
    final s_height = MediaQuery.of(context).size.height * 1.0;
    final s_Width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.teal,
        body: Column(
          children: [
            RoleSection(
              'Driver',
              'Subtitle',
              Image.asset(AppImages.riksha, height: 120),
              'Button Text',
              () {},
            ),
            RoleSection(
              'Passenger',
              'Subtitle',
              Image.asset(AppImages.passenger, height: 120),
              'Button Text',
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget RoleSection(
    String title,
    String subtitle,
    Image image,
    String buttonText,
    VoidCallback onpressed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 6,
        shadowColor: Colors.teal.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          height: 200,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),

              Divider(thickness: 4, color: Colors.teal),
              SizedBox(height: 15),
              ClipRRect(borderRadius: BorderRadius.circular(15), child: image),
            ],
          ),
        ),
      ),
    );
  }
}
