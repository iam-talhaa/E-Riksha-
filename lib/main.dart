import 'package:e_riksha/firebase_options.dart';
import 'package:e_riksha/utils/routes/Routes.dart';
import 'package:e_riksha/utils/routes/RoutesName.dart';
import 'package:e_riksha/view/Driver/Driver_class.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SampleDataService sampleService = SampleDataService();
  await sampleService.addSampleDrivers();
  runApp(E_riksha());
}

class E_riksha extends StatefulWidget {
  E_riksha({super.key});

  @override
  State<E_riksha> createState() => _E_rikshaState();
}

class _E_rikshaState extends State<E_riksha> {
  @override
  Widget build(BuildContext context) {
    print('Main Screen Called');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routesname.PassengerHome,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
