import 'dart:async';

import 'package:e_riksha/res/GlassmorphicContainer.dart';
import 'package:e_riksha/res/TransparentTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Passengerscreenmap extends StatefulWidget {
  const Passengerscreenmap({super.key});

  @override
  State<Passengerscreenmap> createState() => _PassengerscreenmapState();
}

class _PassengerscreenmapState extends State<Passengerscreenmap> {
  @override
  void initState() {
    super.initState(); // always call super.initState()
    _listOfMarkers.addAll(_Makers);

    _getCurrentLocation().then((v) {
      var currentlat = v.latitude;
      var currentlon = v.longitude;
    });

    mycurrentLocation();
  }

  mycurrentLocation() {
    _getCurrentLocation().then((v) {
      var currentlat = v.latitude;
      var currentlon = v.longitude;
      setState(() {
        _iCamera = CameraPosition(
          zoom: 14,
          target: LatLng(currentlat, currentlon),
        );
      });
    });
  }

  CameraPosition _iCamera = CameraPosition(
    zoom: 14,
    target: LatLng(34.0151, 71.5249),
  );

  Future<Position> _getCurrentLocation() async {
    await Geolocator.requestPermission().then((v) {}).onError((e, s) {});

    return Geolocator.getCurrentPosition();
  }

  Completer<GoogleMapController> _controller = Completer();

  TextEditingController _SearchPlaceController = TextEditingController();

  List<Marker> _Makers = [
    // Marker(markerId: MarkerId('1'), position: LatLng(34.01056, 71.79889)),
    // Marker(markerId: MarkerId('2'), position: LatLng(34.0105556, 71.7963889)),
    // Marker(markerId: MarkerId('3'), position: LatLng(34.011, 71.796)),
    // Marker(markerId: MarkerId('4'), position: LatLng(34.00968, 71.79445)),
    // Marker(markerId: MarkerId('5'), position: LatLng(34.0095421, 71.8037638)),
    // Marker(markerId: MarkerId('6'), position: LatLng(34.0113944, 71.7941607)),
    // Marker(markerId: MarkerId('7'), position: LatLng(34.0106, 71.7975)),
    // Marker(markerId: MarkerId('8'), position: LatLng(34.0098, 71.7952)),
    // Marker(markerId: MarkerId('9'), position: LatLng(34.0102, 71.7991)),
    // Marker(markerId: MarkerId('10'), position: LatLng(34.0111, 71.7980)),
  ];

  List<Marker> _listOfMarkers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: Set<Marker>.of(_listOfMarkers),
              initialCameraPosition: _iCamera,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: UpdatableGlassTextFormField(
                prefixIcon: Icon(Icons.search),
                borderColor: Colors.grey,
                hintText: 'Search Location',
                controller: _SearchPlaceController,
                onChanged: (String) {},
              ),
            ),
            // Positioned(
            //   // top: 300,
            //   left: 10,
            //   right: 10,
            //   bottom: 10,
            //   child: UpdatableContainer(
            //     child: Column(
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: UpdatableGlassTextFormField(
            //             prefixIcon: Icon(Icons.mail),
            //             borderColor: Colors.Black,
            //             hintText: 'Seach Distination',
            //             controller: _SearchPlaceController,
            //             onChanged: (String) {},
            //           ),
            //         ),
            //       ],
            //     ),
            //     height: 200.0,
            //     width: double.infinity,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
