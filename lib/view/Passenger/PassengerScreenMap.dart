import 'dart:async';
import 'package:e_riksha/res/GlassmorphicContainer.dart';
import 'package:e_riksha/res/MapApiKey.dart';
import 'package:e_riksha/res/TransparentTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'dart:ui';

import 'package:google_places_flutter/model/prediction.dart';

class Passengerscreenmap extends StatefulWidget {
  const Passengerscreenmap({super.key});

  @override
  State<Passengerscreenmap> createState() => _PassengerscreenmapState();
}

class _PassengerscreenmapState extends State<Passengerscreenmap> {
  TextEditingController _searchController = TextEditingController();

  double currentLat = 0.0;
  double currentLon = 0.0;

  String? _searchedLat;
  String? _searchedLon;

  CameraPosition? _initialCameraPosition; // nullable at start
  Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _makers = [
    Marker(markerId: MarkerId('2'), position: LatLng(34.0105556, 71.7963889)),
    Marker(markerId: MarkerId('3'), position: LatLng(34.011, 71.796)),
    Marker(markerId: MarkerId('4'), position: LatLng(34.00968, 71.79445)),
    Marker(markerId: MarkerId('5'), position: LatLng(34.0095421, 71.8037638)),
    Marker(markerId: MarkerId('6'), position: LatLng(34.0113944, 71.7941607)),
    Marker(markerId: MarkerId('7'), position: LatLng(34.0106, 71.7975)),
    Marker(markerId: MarkerId('8'), position: LatLng(34.0098, 71.7952)),
    Marker(markerId: MarkerId('9'), position: LatLng(34.0102, 71.7991)),
    Marker(markerId: MarkerId('10'), position: LatLng(34.0111, 71.7980)),
  ];

  List<Marker> _listOfMarkers = [];

  @override
  void initState() {
    super.initState();
    _listOfMarkers.addAll(_makers);
    _loadCurrentLocation(); // fetch location once on startup
  }

  Future<void> _loadCurrentLocation() async {
    Position pos = await _setCurrentLocation();

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );
    });
  }

  Future<Position> _setCurrentLocation() async {
    // Step 1: request permission
    LocationPermission permission = await Geolocator.requestPermission();

    // Step 2: get position
    Position pos = await Geolocator.getCurrentPosition();

    // Step 3: update state
    setState(() {
      currentLat = pos.latitude;
      currentLon = pos.longitude;

      _listOfMarkers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: LatLng(pos.latitude, pos.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );
    });

    return pos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SafeArea(
              child:
                  _initialCameraPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                        markers: Set<Marker>.of(_listOfMarkers),
                        initialCameraPosition: _initialCameraPosition!,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  placesAutoCompleteTextField(context),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showCustomBottomSheet(context);
                        print(
                          'Seacrh Places Location: $_searchedLat, $_searchedLon',
                        );
                      },
                      child: UpdatableContainer(
                        height: 65.0,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.route,
                              color: Colors.blueGrey.withOpacity(0.7),
                            ),
                            Text(
                              'Travel Route',
                              style: TextStyle(
                                color: Colors.blueGrey.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void ModeCameraToCurrentLocation() {
    if (_initialCameraPosition != null) {
      _controller.future.then((GoogleMapController controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(currentLat, currentLon), zoom: 14),
          ),
        );
      });
    }
  }

  Widget placesAutoCompleteTextField(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 👈 Glass blur
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25), // glass highlight
                Colors.white.withOpacity(0.05), // deeper transparent
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3), // subtle border
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2), // glowing shadow
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: _searchController,
            googleAPIKey: "AIzaSyD3UoJ0vpEEcn8jQ4R9yHEzqHVye9oRr3E",
            debounceTime: 400,
            countries: ["pk"], // restrict to Pakistan 🇵🇰
            isLatLngRequired: true,

            inputDecoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
              fillColor: Colors.transparent,
              filled: true,
              hintText: "Search your location...",
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),

            getPlaceDetailWithLatLng: (Prediction prediction) {
              print("Lat: ${prediction.lat}, Lng: ${prediction.lng}");
              setState(() {
                _searchedLat = prediction.lat;
                _searchedLon = prediction.lng;
                ModeCameraToCurrentLocation();
              });
            },

            itemClick: (Prediction prediction) {
              _searchController.text = prediction.description ?? "";
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
            },

            seperatedBuilder: Divider(color: Colors.white24),
            containerHorizontalPadding: 10,

            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // 👈 soft transparent
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.3), // subtle border
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prediction.description ?? "",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis, // prevent long overflow
                      ),
                    ),
                  ],
                ),
              );
            },

            isCrossBtnShown: true,
          ),
        ),
      ),
    );
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent, // 👈 makes sheet itself transparent
      barrierColor: Colors.black.withOpacity(0.2), // dim background
      isScrollControlled: true, // so we can play with height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 👈 glass blur
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25), // frosted base
                    Colors.white.withOpacity(0.05), // soft fade
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UpdatableGlassTextFormField(
                      enabled: false,
                      hintText: 'Origin [Current Location]',
                      prefixIcon: Image(
                        height: 1,
                        image: AssetImage('assets/icons/marker2.png'),
                      ),
                      borderColor: Colors.blueGrey,
                      controller: null,
                      onChanged: (String) {},
                    ),
                    SizedBox(height: 5),
                    UpdatableGlassTextFormField(
                      hintText: 'DIstination',
                      prefixIcon: Icon(
                        Icons.search_sharp,
                        color: Colors.blueGrey.withOpacity(0.7),
                      ),
                      borderColor: Colors.blueGrey,
                      controller: null,
                      onChanged: (String) {},
                    ),

                    const SizedBox(height: 16),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.white.withOpacity(0.2),
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(15),
                    //     ),
                    //   ),
                    //   onPressed: () => Navigator.pop(context),
                    //   child: const Text("Close"),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
