// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// import 'package:geocoding/geocoding.dart';
// import 'dart:async';
// import 'package:e_riksha/res/GlassmorphicContainer.dart';
// import 'package:e_riksha/res/TransparentTextFormField.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';
// import 'dart:ui';



// // Routes API Example (Enhanced Features with Current Location and Destination Input)
// class RoutesApiMapScreen extends StatefulWidget {
//   final String apiKey;

//   const RoutesApiMapScreen({super.key, required this.apiKey});

//   @override
//   RoutesApiMapScreenState createState() => RoutesApiMapScreenState();
// }

// class RoutesApiMapScreenState extends State<RoutesApiMapScreen> {
//   late gmaps.GoogleMapController mapController;
  
//   // Current location variables
//   double? _currentLatitude;
//   double? _currentLongitude;
  
//   // Destination variables
//   double? _destLatitude;
//   double? _destLongitude;
  
//   Map<gmaps.MarkerId, gmaps.Marker> markers = {};
//   Map<gmaps.PolylineId, gmaps.Polyline> polylines = {};
//   List<gmaps.LatLng> polylineCoordinates = [];
//   late PolylinePoints polylinePoints;
  
//   bool isLoading = false;
//   bool isLoadingLocation = false;
//   String? errorMessage;
//   RoutesApiResponse? currentResponse;
  
//   // Controllers and form
//   final TextEditingController _destinationController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   Location location = Location();

//   @override
//   void initState() {
//     super.initState();
//     polylinePoints = PolylinePoints.enhanced(widget.apiKey);
//     _getCurrentLocation();
//   }

//   @override
//   void dispose() {
//     _destinationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Routes with Current Location'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           // Google Map
//           _currentLatitude != null && _currentLongitude != null
//               ? gmaps.GoogleMap(
//                   initialCameraPosition: gmaps.CameraPosition(
//                     target: gmaps.LatLng(_currentLatitude!, _currentLongitude!),
//                     zoom: 12,
//                   ),
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                   tiltGesturesEnabled: true,
//                   compassEnabled: true,
//                   scrollGesturesEnabled: true,
//                   zoomGesturesEnabled: true,
//                   onMapCreated: _onMapCreated,
//                   markers: Set<gmaps.Marker>.of(markers.values),
//                   polylines: Set<gmaps.Polyline>.of(polylines.values),
//                 )
//               : Container(
//                   color: Colors.grey[300],
//                   child: const Center(
//                     child: Text('Loading map...'),
//                   ),
//                 ),

//           // Loading overlay
//           if (isLoading || isLoadingLocation)
//             Container(
//               color: Colors.black26,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),

//           // Error message
//           if (errorMessage != null)
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Card(
//                 color: Colors.red[100],
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Icon(Icons.error, color: Colors.red[800]),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Error: $errorMessage',
//                           style: TextStyle(color: Colors.red[800]),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             errorMessage = null;
//                           });
//                         },
//                         icon: Icon(Icons.close, color: Colors.red[800]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Destination input form
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextFormField(
//                         controller: _destinationController,
//                         decoration: const InputDecoration(
//                           labelText: 'Enter Destination',
//                           hintText: 'e.g., Lagos Island, Lagos, Nigeria',
//                           prefixIcon: Icon(Icons.location_on),
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a destination';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: _searchAndDrawRoute,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 foregroundColor: Colors.white,
//                               ),
//                               child: const Text('Find Route'),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: _clearRoute,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Clear'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Route information card
//           if (currentResponse != null && currentResponse!.routes.isNotEmpty)
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Route Information',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       const SizedBox(height: 8),
//                       ..._buildRouteInfo(),
//                       const SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: _getAlternativeRoutes,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('Show Alternative Routes'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getCurrentLocation,
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }

//   List<Widget> _buildRouteInfo() {
//     final route = currentResponse!.routes.first;
//     return [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
//               Text(route.duration?.toString() ?? 'N/A'),
//             ],
//           ),
//           Column(
//             children: [
//               const Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
//               Text(route.distanceMeters != null
//                   ? '${(route.distanceMeters! / 1000).toStringAsFixed(1)} km'
//                   : 'N/A'),
//             ],
//           ),
//         ],
//       ),
//     ];
//   }

//   void _onMapCreated(gmaps.GoogleMapController controller) async {
//     mapController = controller;
//     if (_currentLatitude != null && _currentLongitude != null) {
//       _addMarker(
//         gmaps.LatLng(_currentLatitude!, _currentLongitude!),
//         "origin",
//         gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
//       );
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       isLoadingLocation = true;
//       errorMessage = null;
//     });

//     try {
//       bool serviceEnabled;
//       PermissionStatus permissionGranted;
//       LocationData locationData;

//       serviceEnabled = await location.serviceEnabled();
//       if (!serviceEnabled) {
//         serviceEnabled = await location.requestService();
//         if (!serviceEnabled) {
//           throw Exception('Location services are disabled');
//         }
//       }

//       permissionGranted = await location.hasPermission();
//       if (permissionGranted == PermissionStatus.denied) {
//         permissionGranted = await location.requestPermission();
//         if (permissionGranted != PermissionStatus.granted) {
//           throw Exception('Location permissions are denied');
//         }
//       }

//       locationData = await location.getLocation();

//       setState(() {
//         _currentLatitude = locationData.latitude;
//         _currentLongitude = locationData.longitude;
//       });

//       if (mapController != null && _currentLatitude != null && _currentLongitude != null) {
//         await mapController.animateCamera(
//           gmaps.CameraUpdate.newLatLng(
//             gmaps.LatLng(_currentLatitude!, _currentLongitude!),
//           ),
//         );
        
//         _addMarker(
//           gmaps.LatLng(_currentLatitude!, _currentLongitude!),
//           "origin",
//           gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
//         );
//       }

//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to get current location: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         isLoadingLocation = false;
//       });
//     }
//   }

//   Future<void> _searchAndDrawRoute() async {
//     if (!_formKey.currentState!.validate()) return;
    
//     if (_currentLatitude == null || _currentLongitude == null) {
//       setState(() {
//         errorMessage = 'Current location not available. Please try again.';
//       });
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       polylines.clear();
//       currentResponse = null;
//       // Remove existing destination marker
//       markers.removeWhere((key, value) => key.value == "destination");
//     });

//     try {
//       // Geocode the destination
//       List<Location> locations = await locationFromAddress(_destinationController.text);
      
//       if (locations.isEmpty) {
//         throw Exception('Destination not found');
//       }

//       Location destinationLocation = locations.first;
//       _destLatitude = destinationLocation.latitude;
//       _destLongitude = destinationLocation.longitude;

//       // Add destination marker
//       _addMarker(
//         gmaps.LatLng(_destLatitude!, _destLongitude!),
//         "destination",
//         gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
//       );

//       // Get route
//       await _getEnhancedRoute();

//       // Animate camera to show both markers
//       if (mapController != null) {
//         gmaps.LatLngBounds bounds = gmaps.LatLngBounds(
//           southwest: gmaps.LatLng(
//             _currentLatitude! < _destLatitude! ? _currentLatitude! : _destLatitude!,
//             _currentLongitude! < _destLongitude! ? _currentLongitude! : _destLongitude!,
//           ),
//           northeast: gmaps.LatLng(
//             _currentLatitude! > _destLatitude! ? _currentLatitude! : _destLatitude!,
//             _currentLongitude! > _destLongitude! ? _currentLongitude! : _destLongitude!,
//           ),
//         );

//         await mapController.animateCamera(
//           gmaps.CameraUpdate.newLatLngBounds(bounds, 100.0),
//         );
//       }

//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to find route: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _clearRoute() {
//     setState(() {
//       polylines.clear();
//       currentResponse = null;
//       errorMessage = null;
//       _destinationController.clear();
//       // Remove destination marker, keep origin
//       markers.removeWhere((key, value) => key.value == "destination");
//     });
//   }

//   void _addMarker(gmaps.LatLng position, String id, gmaps.BitmapDescriptor descriptor) {
//     gmaps.MarkerId markerId = gmaps.MarkerId(id);
//     gmaps.Marker marker = gmaps.Marker(
//       markerId: markerId,
//       icon: descriptor,
//       position: position,
//       infoWindow: gmaps.InfoWindow(
//         title: id == "origin" ? "Current Location" : "Destination",
//       ),
//     );
//     markers[markerId] = marker;
//     setState(() {});
//   }

//   void _addPolyLine(List<gmaps.LatLng> coordinates, {Color color = Colors.blue, String id = "poly"}) {
//     gmaps.PolylineId polylineId = gmaps.PolylineId(id);
//     gmaps.Polyline polyline = gmaps.Polyline(
//       polylineId: polylineId,
//       color: color,
//       points: coordinates,
//       width: 5,
//     );
//     polylines[polylineId] = polyline;
//     setState(() {});
//   }

//   Future<void> _getEnhancedRoute() async {
//     if (_currentLatitude == null || _currentLongitude == null || 
//         _destLatitude == null || _destLongitude == null) {
//       return;
//     }

//     try {
//       RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
//         request: RequestConverter.createEnhancedRequest(
//           origin: PointLatLng(_currentLatitude!, _currentLongitude!),
//           destination: PointLatLng(_destLatitude!, _destLongitude!),
//         ),
//       );

//       setState(() {
//         currentResponse = response;
//       });

//       if (response.routes.isNotEmpty) {
//         final route = response.routes.first;
//         if (route.polylinePoints != null) {
//           final points = polylinePoints.convertToLegacyResult(response).points;
//           final coordinates = points
//               .map((point) => gmaps.LatLng(point.latitude, point.longitude))
//               .toList();
//           _addPolyLine(coordinates, color: Colors.blue);
//         }
//       } else {
//         setState(() {
//           errorMessage = response.errorMessage ?? 'No route found';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//       });
//     }
//   }

//   Future<void> _getAlternativeRoutes() async {
//     if (_currentLatitude == null || _currentLongitude == null || 
//         _destLatitude == null || _destLongitude == null) {
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       polylines.clear();
//       currentResponse = null;
//     });

//     try {
//       RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
//         request: RequestConverter.createEnhancedRequest(
//           origin: PointLatLng(_currentLatitude!, _currentLongitude!),
//           destination: PointLatLng(_destLatitude!, _destLongitude!),
//           alternatives: true,
//           extraComputations: [ExtraComputation.fuelConsumption],
//         ),
//       );

//       setState(() {
//         currentResponse = response;
//       });

//       if (response.routes.isNotEmpty) {
//         final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
//         for (int i = 0; i < response.routes.length && i < colors.length; i++) {
//           final route = response.routes[i];
//           if (route.polylinePoints != null) {
//             final coordinates = route.polylinePoints!
//                 .map((point) => gmaps.LatLng(point.latitude, point.longitude))
//                 .toList();
//             _addPolyLine(coordinates, color: colors[i], id: "poly_$i");
//           }
//         }
//       } else {
//         setState(() {
//           errorMessage = response.errorMessage ?? 'No routes found';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//     });
//     }
//   }
// }