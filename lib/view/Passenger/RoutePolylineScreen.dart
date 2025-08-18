// Routes API Example (Enhanced Features)
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutesApiMapScreen extends StatefulWidget {
  final String apiKey;

  const RoutesApiMapScreen({super.key, required this.apiKey});

  @override
  RoutesApiMapScreenState createState() => RoutesApiMapScreenState();
}

class RoutesApiMapScreenState extends State<RoutesApiMapScreen> {
  CameraPosition? _initialCameraPosition;
  double currentLat = 0.0;
  double currentLon = 0.0;

  
  

    List<Marker> _listOfMarkers = [];
  // return Current Postion pos=  LatLng
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
   Future<void> _loadCurrentLocation() async {
    Position pos = await _setCurrentLocation();

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );
    });
  }

  late GoogleMapController mapController;
  final double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  final double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  bool isLoading = false;
  String? errorMessage;
  RoutesApiResponse? currentResponse;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    polylinePoints = PolylinePoints.enhanced(widget.apiKey);
    _addMarker(
      LatLng(_originLatitude, _originLongitude),
      "origin",
      BitmapDescriptor.defaultMarker,
    );
    _addMarker(
      LatLng(_destLatitude, _destLongitude),
      "destination",
      BitmapDescriptor.defaultMarkerWithHue(90),
    );
    _getEnhancedRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_originLatitude, _originLongitude),
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
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ),
            ),
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
                    Text(
                      'Using the new Google Routes API with traffic-aware routing, toll information, and enhanced features.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (currentResponse != null &&
                        currentResponse!.routes.isNotEmpty)
                      ..._buildRouteInfo(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _getEnhancedRoute,
                          child: const Text('Enhanced Route'),
                        ),
                        ElevatedButton(
                          onPressed: _getAlternativeRoutes,
                          child: const Text('Alternatives'),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Duration',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(route.duration?.toString() ?? 'N/A'),
            ],
          ),
          Column(
            children: [
              const Text(
                'Distance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                route.distanceMeters != null
                    ? '${(route.distanceMeters! / 1000).toStringAsFixed(1)} km'
                    : 'N/A',
              ),
            ],
          ),
        ],
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
    );
    markers[markerId] = marker;
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
    );
    polylines[polylineId] = polyline;
    setState(() {});
  }

  _getEnhancedRoute() async {
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
              origin: PointLatLng(_originLatitude, _originLongitude),
              destination: PointLatLng(_destLatitude, _destLongitude),
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
              origin: PointLatLng(_originLatitude, _originLongitude),
              destination: PointLatLng(_destLatitude, _destLongitude),
              waypoints: [
                PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria"),
              ],
              alternatives: true,
              extraComputations: [ExtraComputation.fuelConsumption],
            ),
          );

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final colors = [Colors.green, Colors.blue, Colors.orange];
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
