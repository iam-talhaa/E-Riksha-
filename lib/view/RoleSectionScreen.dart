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
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Rolesectionscreen()),
                );
              },
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
        elevation: 12,
        shadowColor: Colors.teal.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.shade50,
                Colors.teal.shade100,
                Colors.teal.shade200,
                Colors.cyan.shade100,
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.teal.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 8),
                spreadRadius: 0.5,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: Offset(-5, -5),
                spreadRadius: 0.5,
              ),
            ],
          ),
          height: 220,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(1, 1),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                        spreadRadius: 1,
                      ),
                    ],
                    // border: Border.all(color: Colors.teal.shade200, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: image,
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
