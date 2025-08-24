import 'package:e_riksha/res/MapApiKey.dart';
import 'package:e_riksha/utils/routes/RoutesName.dart';
import 'package:e_riksha/view/Driver/Driver_map.dart';
import 'package:e_riksha/view/Passenger/PassengerScreenMap.dart';
import 'package:e_riksha/view/Passenger/RoutePolylineScreen.dart';
import 'package:e_riksha/view/RoleSectionScreen.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routesname.RoleSelection:
        return MaterialPageRoute(builder: (context) => Rolesectionscreen());
      case Routesname.DiverMapScreen:
        return MaterialPageRoute(
          builder:
              (context) =>
                  MapScreen(),
        );
      case Routesname.PassengerHome:
        return MaterialPageRoute(
          builder: (context) => const Passengerscreenmap(),
        );
      case Routesname.DriverBasicInfo:
        return MaterialPageRoute(
          builder: (context) => const Passengerscreenmap(),
        );  
      default:
        return MaterialPageRoute(
          builder: (Context) {
            return const Scaffold(
              body: Center(child: Text('No route defined for ')),
            );
          },
        );
    }
  }
}
