import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverBasicInformation extends StatefulWidget {
  const DriverBasicInformation({super.key});

  @override
  State<DriverBasicInformation> createState() => _DriverBasicInformationState();
}

class _DriverBasicInformationState extends State<DriverBasicInformation> {
  double _driverLat = 0.0;
  double _driverLng = 0.0;

  bool isDriverOnline = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofMarker.addAll(_marker);
  }

  final List<Marker> _marker = [
    Marker(
      markerId: MarkerId('My location'),
      position: LatLng(34.0097, 34.0097),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: 'MY Current location'),
    ),
  ];

  final List<Marker> _listofMarker = [];

  final _googleMapController = GoogleMapController;

  final _cameraPosition = CameraPosition(
    zoom: 14,
    target: LatLng(34.0097, 34.0097),
  );

  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(34.0097, 71.8047),
    zoom: 14,
  );
  Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Goole Map"),
        actions: [
          Switch(
            value: isDriverOnline,
            onChanged: (value) {
              setState(() {
                isDriverOnline = value;

                print("Driver is $isDriverOnline");
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.redAccent,
          ),
        ],
      ),
      body: GoogleMap(
        markers: Set<Marker>.of(_listofMarker),
        initialCameraPosition: _initialCameraPosition!,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
