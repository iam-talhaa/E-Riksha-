import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class PassengerTestScreen extends StatefulWidget {
  const PassengerTestScreen({super.key});

  @override
  State<PassengerTestScreen> createState() => _PassengerTestScreenState();
}

class _PassengerTestScreenState extends State<PassengerTestScreen> {
  LatLng? passengerLocation; // Passenger current location

  @override
  void initState() {
    super.initState();
    _getPassengerLocation();
  }

  // Get passenger's current location
  Future<void> _getPassengerLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied.");
    }

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      passengerLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Passenger Panel")),
      body: passengerLocation == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('drivers_locations')
                  .where('isOnline', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Convert driver documents into markers
                List<Marker> driverMarkers =
                    snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(data['lat'], data['lng']),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    infoWindow: const InfoWindow(title: "Driver"),
                  );
                }).toList();

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: passengerLocation!,
                    zoom: 14,
                  ),
                  markers: {
                    ...driverMarkers,
                    Marker(
                      markerId: const MarkerId('passenger'),
                      position: passengerLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                      infoWindow: const InfoWindow(title: "You"),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                );
              },
            ),
    );
  }
}
