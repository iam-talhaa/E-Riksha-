import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Passengerscreenmap extends StatefulWidget {
  const Passengerscreenmap({super.key});

  @override
  State<Passengerscreenmap> createState() => _PassengerscreenmapState();
}

class _PassengerscreenmapState extends State<Passengerscreenmap> {
  Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _iCamera = CameraPosition(
    zoom: 14,
    target: LatLng(34.0077, 71.7919),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _iCamera,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),

            Positioned(
              top: 10,
              bottom: 100,
              right: 10,
              left: 10,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
