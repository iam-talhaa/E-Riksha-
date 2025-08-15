import 'package:e_riksha/utils/routes/Routes.dart';
import 'package:e_riksha/utils/routes/RoutesName.dart';
import 'package:e_riksha/view/Passenger/PassengerScreenMap.dart';
import 'package:e_riksha/view/RoleSectionScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const E_riksha());
}

class E_riksha extends StatefulWidget {
  const E_riksha({super.key});

  @override
  State<E_riksha> createState() => _E_rikshaState();
}

class _E_rikshaState extends State<E_riksha> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routesname.PassengerHome,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
