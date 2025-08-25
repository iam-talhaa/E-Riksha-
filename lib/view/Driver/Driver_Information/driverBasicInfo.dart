import 'dart:async';

import 'package:another_flushbar/flushbar_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverBasicInformation extends StatefulWidget {
  const DriverBasicInformation({super.key});

  @override
  State<DriverBasicInformation> createState() => _DriverBasicInformationState();
}

class _DriverBasicInformationState extends State<DriverBasicInformation> {
  final driverfirestore = FirebaseFirestore.instance.collection(
    'drivers_locations',
  );

  void updateDriverLocation() async {
    String driverId = Timestamp.now().millisecondsSinceEpoch.toString();
    await driverfirestore
        .doc(driverId)
        .set({
          "lat": _driverCurrentlat,
          "lng": _driverCurrentLng,
          "isOnline": true,
          "lastUpdated": FieldValue.serverTimestamp(),
        })
        .then((v) {
          print("Driver Added Successfulyy ");
        })
        .onError((error, s) {
          print("ERROR IS $error");
        });
  }

  CameraPosition? _initialCameraPosition;
  double _driverCurrentlat = 0.0;
  double _driverCurrentLng = 0.0;

  Future<void> _getCurrentLocationOfDriver() async {
    Position pos = await _getcurrentlatlng();

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );
    });
  }

  Future<Position> _getcurrentlatlng() async {
    LocationPermission locationPermission =
        await Geolocator.requestPermission();

    Position pos = await Geolocator.getCurrentPosition();

    setState(() {
      _driverCurrentlat = pos.latitude;
      _driverCurrentLng = pos.longitude;

      print("DRIVER LAT $_driverCurrentlat");
      print("DRIVER LNG $_driverCurrentLng");
      _listofMarker.add(
        Marker(
          markerId: const MarkerId('Driver'),
          position: LatLng(_driverCurrentlat, _driverCurrentLng),
          infoWindow: const InfoWindow(title: 'Driver Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    return pos;
  }

  bool isDriverOnline = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getCurrentLocationOfDriver();
  }

  final List<Marker> _marker = [];

  final List<Marker> _listofMarker = [];

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
      body:
          _initialCameraPosition == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // 👈 show loader
              : GoogleMap(
                markers: Set<Marker>.of(_listofMarker),
                initialCameraPosition: _initialCameraPosition!,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          updateDriverLocation();
        },
      ),
    );
  }
}
