// Routes API Example (Enhanced Features with Current Location & Destination Input)
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RoutesApiMapScreen extends StatefulWidget {
  final String apiKey;

  const RoutesApiMapScreen({super.key, required this.apiKey});

  @override
  RoutesApiMapScreenState createState() => RoutesApiMapScreenState();
}

class RoutesApiMapScreenState extends State<RoutesApiMapScreen> {
  late GoogleMapController mapController;
  double? _originLatitude, _originLongitude;
  double? _destLatitude, _destLongitude;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  bool isLoading = false;
  bool isLoadingLocation = false;
  String? errorMessage;
  RoutesApiResponse? currentResponse;

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  bool _showDestinationInput = false;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints.enhanced(widget.apiKey);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _originController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
      errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage =
              'Location services are disabled. Please enable location services.';
          isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Location permissions are denied';
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage =
              'Location permissions are permanently denied, we cannot request permissions.';
          isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _originLatitude = position.latitude;
        _originLongitude = position.longitude;
        isLoadingLocation = false;
      });

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _originController.text =
              '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        }
      } catch (e) {
        _originController.text = 'Current Location';
      }

      // Add origin marker
      _addMarker(
        LatLng(position.latitude, position.longitude),
        "origin",
        BitmapDescriptor.defaultMarker,
      );

      // Move camera to current location
      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get current location: ${e.toString()}';
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _searchDestination(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _destLatitude = location.latitude;
          _destLongitude = location.longitude;
        });

        // Remove existing destination marker
        markers.removeWhere((key, value) => key.value == "destination");

        // Add destination marker
        _addMarker(
          LatLng(location.latitude, location.longitude),
          "destination",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );

        // Draw route if both origin and destination are available
        if (_originLatitude != null && _originLongitude != null) {
          await _getEnhancedRoute();
        }

        // Adjust camera to show both markers
        _adjustCameraToShowBothMarkers();

        setState(() {
          _showDestinationInput = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Destination not found. Please try a different location.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error searching destination: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _adjustCameraToShowBothMarkers() {
    if (_originLatitude != null &&
        _originLongitude != null &&
        _destLatitude != null &&
        _destLongitude != null) {
      double minLat =
          (_originLatitude! < _destLatitude!)
              ? _originLatitude!
              : _destLatitude!;
      double maxLat =
          (_originLatitude! > _destLatitude!)
              ? _originLatitude!
              : _destLatitude!;
      double minLng =
          (_originLongitude! < _destLongitude!)
              ? _originLongitude!
              : _destLongitude!;
      double maxLng =
          (_originLongitude! > _destLongitude!)
              ? _originLongitude!
              : _destLongitude!;

      mapController.animateCamera(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes with Current Location'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _originLatitude != null && _originLongitude != null
                      ? LatLng(_originLatitude!, _originLongitude!)
                      : const LatLng(6.5212402, 3.3679965), // Default to Lagos
              zoom: 12,
            ),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),

          // Loading overlay
          if (isLoading || isLoadingLocation)
            Container(
              color: Colors.black26,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      isLoadingLocation
                          ? 'Getting current location...'
                          : 'Loading route...',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Error message
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => errorMessage = null),
                        icon: Icon(Icons.close, color: Colors.red[800]),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Origin and Destination Input Card
          Positioned(
            top: errorMessage != null ? 100 : 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Origin Input (Read-only)
                    TextFormField(
                      controller: _originController,
                      decoration: InputDecoration(
                        labelText: 'From (Current Location)',
                        prefixIcon: const Icon(
                          Icons.my_location,
                          color: Colors.green,
                        ),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),

                    // Destination Input
                    if (!_showDestinationInput)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              () =>
                                  setState(() => _showDestinationInput = true),
                          icon: const Icon(Icons.location_on),
                          label: const Text('Select Destination'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                    if (_showDestinationInput) ...[
                      TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'To (Destination)',
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed:
                                    () => _searchDestination(
                                      _destinationController.text,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _showDestinationInput = false;
                                    _destinationController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        onFieldSubmitted: _searchDestination,
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter destination address (e.g., "Victoria Island, Lagos" or "Abuja, Nigeria")',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Route Information and Controls
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enhanced Routes API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    if (currentResponse != null &&
                        currentResponse!.routes.isNotEmpty)
                      ..._buildRouteInfo()
                    else
                      Text(
                        'Select a destination to view route information',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              (_originLatitude != null && _destLatitude != null)
                                  ? _getEnhancedRoute
                                  : null,
                          icon: const Icon(Icons.route),
                          label: const Text('Best Route'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              (_originLatitude != null && _destLatitude != null)
                                  ? _getAlternativeRoutes
                                  : null,
                          icon: const Icon(Icons.alt_route),
                          label: const Text('Alternatives'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRouteInfo() {
    final route = currentResponse!.routes.first;
    return [
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(Icons.access_time, color: Colors.blue[700]),
                const Text(
                  'Duration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  route.duration?.toString() ?? 'N/A',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
            Column(
              children: [
                Icon(Icons.straighten, color: Colors.green[700]),
                const Text(
                  'Distance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  route.distanceMeters != null
                      ? '${(route.distanceMeters! / 1000).toStringAsFixed(1)} km'
                      : 'N/A',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: id == "origin" ? "Current Location" : "Destination",
        snippet: id == "origin" ? "Your location" : "Selected destination",
      ),
    );
    markers[markerId] = marker;
    setState(() {});
  }

  _addPolyLine(
    List<LatLng> coordinates, {
    Color color = Colors.green,
    String id = "poly",
  }) {
    PolylineId polylineId = PolylineId(id);
    Polyline polyline = Polyline(
      polylineId: polylineId,
      color: color,
      points: coordinates,
      width: 5,
      patterns: [],
    );
    polylines[polylineId] = polyline;
    setState(() {});
  }

  _getEnhancedRoute() async {
    if (_originLatitude == null ||
        _originLongitude == null ||
        _destLatitude == null ||
        _destLongitude == null) {
      setState(() {
        errorMessage = 'Origin or destination not available';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      polylineCoordinates.clear();
      polylines.clear();
      currentResponse = null;
    });

    try {
      RoutesApiResponse response = await polylinePoints
          .getRouteBetweenCoordinatesV2(
            request: RequestConverter.createEnhancedRequest(
              origin: PointLatLng(_originLatitude!, _originLongitude!),
              destination: PointLatLng(_destLatitude!, _destLongitude!),
            ),
          );

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          final points = polylinePoints.convertToLegacyResult(response).points;
          final coordinates =
              points
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList();
          _addPolyLine(coordinates, color: Colors.green);
        }
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No route found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _getAlternativeRoutes() async {
    if (_originLatitude == null ||
        _originLongitude == null ||
        _destLatitude == null ||
        _destLongitude == null) {
      setState(() {
        errorMessage = 'Origin or destination not available';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      polylines.clear();
      currentResponse = null;
    });

    try {
      RoutesApiResponse response = await polylinePoints
          .getRouteBetweenCoordinatesV2(
            request: RequestConverter.createEnhancedRequest(
              origin: PointLatLng(_originLatitude!, _originLongitude!),
              destination: PointLatLng(_destLatitude!, _destLongitude!),
              alternatives: true,
              extraComputations: [ExtraComputation.fuelConsumption],
            ),
          );

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final colors = [
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
        ];
        for (int i = 0; i < response.routes.length && i < colors.length; i++) {
          final route = response.routes[i];
          if (route.polylinePoints != null) {
            final coordinates =
                route.polylinePoints!
                    .map((point) => LatLng(point.latitude, point.longitude))
                    .toList();
            _addPolyLine(coordinates, color: colors[i], id: "poly_$i");
          }
        }
        _adjustCameraToShowBothMarkers();
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No routes found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
