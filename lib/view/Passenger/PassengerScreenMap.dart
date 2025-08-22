import 'dart:async';
import 'dart:math' as math;
import 'package:e_riksha/res/GlassmorphicContainer.dart';
import 'package:e_riksha/res/MapApiKey.dart';
import 'package:e_riksha/res/TransparentTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:google_places_flutter/model/prediction.dart';

class Passengerscreenmap extends StatefulWidget {
  const Passengerscreenmap({super.key});

  @override
  State<Passengerscreenmap> createState() => _PassengerscreenmapState();
}

class _PassengerscreenmapState extends State<Passengerscreenmap> {
  //
  TextEditingController _searchController = TextEditingController();
  TextEditingController _originController = TextEditingController();

  //  Current Location
  double currentLat = 0.0;
  double currentLon = 0.0;

  // Search Location
  double _searchedLat = 0.0;
  double _searchedLon = 0.0;

  //
  List<LatLng> _latlng = [];

  //Polyline
  final Set<Polyline> _polyline = {};

  //initial Camera Position
  CameraPosition? _initialCameraPosition; // nullable at start
  Completer<GoogleMapController> _controller = Completer();

  //Marker That will be shown on map
  final List<Marker> _makers = [];

  // Marker will be add in this List
  List<Marker> _listOfMarkers = [];

  // Distance calculation
  double _calculatedDistance = 0.0;
  String _distanceText = '';

  // Google API Key (replace with your actual key)
  final String _googleApiKey = 'AIzaSyD3UoJ0vpEEcn8jQ4R9yHEzqHVye9oRr3E';

  @override
  void initState() {
    super.initState();
    _listOfMarkers.addAll(_makers); //
    _loadCurrentLocation(); // When app Start Current location Access

    print('SET STATE CHECK :$currentLat And $currentLon');
  }

  // Load Current Location
  Future<void> _loadCurrentLocation() async {
    Position pos = await _setCurrentLocation();

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );
    });
  }

  // return Current Position pos= LatLng
  Future<Position> _setCurrentLocation() async {
    // Step 1: request permission
    LocationPermission permission = await Geolocator.requestPermission();

    // Step 2: get position
    Position pos = await Geolocator.getCurrentPosition();

    // Step 3: update state
    setState(() {
      currentLat = pos.latitude;
      currentLon = pos.longitude;

      _originController.text =
          "Current Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})";

      _listOfMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(pos.latitude, pos.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    return pos;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  // Get directions from Google Directions API
  Future<void> _getDirections() async {
    if (currentLat == 0.0 ||
        currentLon == 0.0 ||
        _searchedLat == 0.0 ||
        _searchedLon == 0.0) {
      return;
    }

    String origin = '$currentLat,$currentLon';
    String destination = '$_searchedLat,$_searchedLon';
    print('POlyline Current Origin = $currentLat and $currentLon');
    print('POlyline Search Origin = $_searchedLat and $_searchedLon');

    String url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin'
        '&destination=$destination'
        '&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final leg = route['legs'][0];

          // Get distance from Google API
          _distanceText = leg['distance']['text'];
          _calculatedDistance =
              leg['distance']['value'] / 1000.0; // Convert to km

          List<LatLng> points = _decodePolyline(polylinePoints);

          setState(() {
            _latlng = points;
            _polyline.clear();
            _polyline.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: Colors.blue,
                width: 5,
                patterns: [], // Solid line
              ),
            );
          });

          // Fit map to show both markers
          _fitMapToRoute();
        }
      }
    } catch (e) {
      print('Error getting directions: $e');
      // Fallback: create straight line and calculate distance manually
      _createStraightLineRoute();
    }
  }

  // Decode polyline from Google Directions API
  List<LatLng> _decodePolyline(String polylineStr) {
    List<LatLng> points = [];
    int index = 0, len = polylineStr.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polylineStr.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polylineStr.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Create a straight line route as fallback
  void _createStraightLineRoute() {
    if (currentLat != 0.0 &&
        currentLon != 0.0 &&
        _searchedLat != 0.0 &&
        _searchedLon != 0.0) {
      _calculatedDistance = _calculateDistance(
        currentLat,
        currentLon,
        _searchedLat,
        _searchedLon,
      );
      _distanceText = '${_calculatedDistance.toStringAsFixed(2)} km';

      setState(() {
        _latlng = [
          LatLng(currentLat, currentLon),
          LatLng(_searchedLat, _searchedLon),
        ];
        _polyline.clear();
        _polyline.add(
          Polyline(
            polylineId: const PolylineId('straight_route'),
            points: _latlng,
            color: Colors.red,
            width: 3,
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10),
            ], // Dashed line
          ),
        );
      });

      _fitMapToRoute();
    }
  }

  // Fit map to show the route
  void _fitMapToRoute() async {
    if (_latlng.isNotEmpty) {
      final GoogleMapController controller = await _controller.future;

      double minLat = _latlng.map((e) => e.latitude).reduce(math.min);
      double maxLat = _latlng.map((e) => e.latitude).reduce(math.max);
      double minLng = _latlng.map((e) => e.longitude).reduce(math.min);
      double maxLng = _latlng.map((e) => e.longitude).reduce(math.max);

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0, // padding
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD CHECKING  :$currentLat And $currentLon');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SafeArea(
              child:
                  _initialCameraPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                        polylines: _polyline,
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: placesAutoCompleteTextField(context),
                  ),

                  // Distance display
                  if (_distanceText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.route, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Distance: $_distanceText',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showCustomBottomSheet(context);
                        print(
                          'Search Places Location: $_searchedLat, $_searchedLon',
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

            Positioned(
              right: 10,
              top: 80,
              child: Column(
                children: [
                  // Navigate to searched location button
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    // backgroundColor: Colors.white,
                    onPressed: () async {
                      if (_searchedLat != 0.0 && _searchedLon != 0.0) {
                        final GoogleMapController controller =
                            await _controller.future;

                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(_searchedLat, _searchedLon),
                              zoom: 15,
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 10),

                  // Current location button
                  IconButton(
                    icon: Icon(Icons.my_location, color: Colors.green),
                    // backgroundColor: Colors.white,
                    onPressed: () {
                      MoveCameraToCurrentLocation();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void MoveCameraToCurrentLocation() {
    if (_initialCameraPosition != null) {
      _controller.future.then((GoogleMapController controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(currentLat, currentLon), zoom: 15),
          ),
        );
      });
    }
  }

  Widget placesAutoCompleteTextField(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 👈 Glass blur
        child: Container(
          height: 65,
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
          padding: EdgeInsets.symmetric(vertical: 7),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: _searchController,
            googleAPIKey: _googleApiKey,
            debounceTime: 400,
            countries: ["pk"], // restrict to Pakistan 🇵🇰
            isLatLngRequired: true,

            inputDecoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
              fillColor: Colors.transparent,
              filled: true,
              hintText: "Search your destination...",
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            getPlaceDetailWithLatLng: (Prediction prediction) {
              print(
                "Destination - Lat: ${prediction.lat}, Lng: ${prediction.lng}",
              );
              setState(() {
                _searchedLat = double.parse(prediction.lat.toString());
                _searchedLon = double.parse(prediction.lng.toString());

                // Clear existing destination markers
                _listOfMarkers.removeWhere(
                  (marker) => marker.markerId.value == 'destination',
                );

                // Add destination marker
                _listOfMarkers.add(
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: LatLng(_searchedLat, _searchedLon),
                    infoWindow: InfoWindow(
                      title: 'Destination',
                      snippet: prediction.description ?? '',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                );

                // Get directions and show polyline
                _getDirections();
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
              height: 300,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Origin field (Current Location)
                    UpdatableGlassTextFormField(
                      enabled: false,
                      hintText: 'Origin [Current Location]',
                      prefixIcon: Image(
                        height: 20,
                        width: 20,
                        image: AssetImage('assets/icons/marker2.png'),
                      ),
                      borderColor: Colors.blueGrey,
                      controller: _originController,
                      onChanged: (String value) {},
                    ),

                    SizedBox(height: 15),

                    // Destination field
                    placesAutoCompleteTextField(context),

                    SizedBox(height: 20),

                    // Distance information
                    if (_distanceText.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.straighten, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              'Distance: $_distanceText',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (_searchedLat != 0.0 && _searchedLon != 0.0) {
                              _getDirections();
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(Icons.route),
                          label: Text("Show Route"),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        ),
                      ],
                    ),
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
