import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_riksha/model/driver_model.dart';
import 'package:e_riksha/view/Driver/Driver_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  final DriverService _driverService = DriverService();
  StreamSubscription<List<Driver>>? _driverSubscription;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  @override
  void dispose() {
    _driverSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Handle permission denied forever
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _addUserMarker();
        _startListeningToNearbyDrivers();
      });
      
    } catch (e) {
      print("Error getting location: $e");
    }
  }
  
  void _addUserMarker() {
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }
  
  void _startListeningToNearbyDrivers() {
    if (_currentPosition == null) return;
    
    _driverSubscription = _driverService.getNearbyDrivers(
      userLat: _currentPosition!.latitude,
      userLng: _currentPosition!.longitude,
      radiusInMeters: 5000, // 5km radius
    ).listen((drivers) {
      _updateDriverMarkers(drivers);
    });
  }
  
  void _updateDriverMarkers(List<Driver> drivers) {
    // Remove old driver markers
    _markers.removeWhere((marker) => 
        marker.markerId.value.startsWith('driver_'));
    
    // Add new driver markers
    for (Driver driver in drivers) {
      _markers.add(
        Marker(
          markerId: MarkerId('driver_${driver.driverId}'),
          position: LatLng(driver.latitude, driver.longitude),
          infoWindow: InfoWindow(
            title: driver.name,
            snippet: '${driver.vehicleType} • ${driver.rating}⭐',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          onTap: () => _showDriverDetails(driver),
        ),
      );
    }
    
    setState(() {});
  }
  
  void _showDriverDetails(Driver driver) {
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      driver.latitude,
      driver.longitude,
    );
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              driver.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('${driver.vehicleType} • ${driver.vehicleColor}'),
                Text('${driver.rating}⭐'),
                Text('${(distance / 1000).toStringAsFixed(1)} km away'),
              ],
            ),
            SizedBox(height: 10),
            Text('Plate: ${driver.plateNumber}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _requestRide(driver),
              child: Text('Request Ride'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _requestRide(Driver driver) {
    // Implement ride request logic
    print('Requesting ride from ${driver.name}');
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Drivers'),actions: [
        IconButton(
            icon: Icon(Icons.add_location),
            onPressed: () async {
              await SampleDataService().addSampleDrivers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sample drivers added!')),
              );
            },
          ),
      ],),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshNearbyDrivers,
        child: Icon(Icons.refresh),
      ),
    );
  }
  
  void _refreshNearbyDrivers() {
    _getCurrentLocation();
  }



  
}


class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🎯 Main function to add sample drivers
  Future<void> addSampleDrivers() async {
    try {
      // Get your current location first (to place drivers nearby)
      Position? currentPosition = await _getCurrentPosition();
      
      if (currentPosition == null) {
        print('❌ Cannot get current location');
        return;
      }

      print('📍 Your location: ${currentPosition.latitude}, ${currentPosition.longitude}');
      
      // Create sample drivers around your location
      List<Map<String, dynamic>> sampleDrivers = _createSampleDriversData(
        userLat: currentPosition.latitude,
        userLng: currentPosition.longitude,
      );

      // Add each driver to Firestore
      for (int i = 0; i < sampleDrivers.length; i++) {
        await _firestore
            .collection('active_drivers')
            .doc('sample_driver_$i') // Custom document ID
            .set(sampleDrivers[i]);
        
        print('✅ Added driver: ${sampleDrivers[i]['name']}');
      }

      print('🎉 Successfully added ${sampleDrivers.length} sample drivers!');
      
    } catch (e) {
      print('❌ Error adding sample data: $e');
    }
  }

  // 📍 Get current position for placing nearby drivers
  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // 🚗 Create sample driver data around user's location
  List<Map<String, dynamic>> _createSampleDriversData({
    required double userLat,
    required double userLng,
  }) {
    return [
      {
        'name': 'Ahmed Khan',
        'phone': '+92300123456',
        'location': {
          'latitude': userLat + 0.005, // ~500m north
          'longitude': userLng + 0.002, // ~200m east
        },
        'isOnline': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'vehicleInfo': {
          'type': 'sedan',
          'plateNumber': 'ABC-123',
          'color': 'white',
        },
        'rating': 4.8,
      },
      
      {
        'name': 'Ali Hassan',
        'phone': '+92301234567',
        'location': {
          'latitude': userLat - 0.003, // ~300m south
          'longitude': userLng + 0.007, // ~700m east
        },
        'isOnline': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'vehicleInfo': {
          'type': 'hatchback',
          'plateNumber': 'XYZ-789',
          'color': 'blue',
        },
        'rating': 4.5,
      },
      
      {
        'name': 'Muhammad Tariq',
        'phone': '+92302345678',
        'location': {
          'latitude': userLat + 0.008, // ~800m north
          'longitude': userLng - 0.004, // ~400m west
        },
        'isOnline': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'vehicleInfo': {
          'type': 'suv',
          'plateNumber': 'PQR-456',
          'color': 'black',
        },
        'rating': 4.9,
      },
      
      {
        'name': 'Usman Ahmed',
        'phone': '+92303456789',
        'location': {
          'latitude': userLat - 0.006, // ~600m south
          'longitude': userLng - 0.003, // ~300m west
        },
        'isOnline': false, // This driver is offline
        'lastUpdated': FieldValue.serverTimestamp(),
        'vehicleInfo': {
          'type': 'sedan',
          'plateNumber': 'LMN-321',
          'color': 'silver',
        },
        'rating': 4.3,
      },
      
      {
        'name': 'Bilal Shah',
        'phone': '+92304567890',
        'location': {
          'latitude': userLat + 0.002, // ~200m north
          'longitude': userLng + 0.009, // ~900m east
        },
        'isOnline': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'vehicleInfo': {
          'type': 'hatchback',
          'plateNumber': 'DEF-654',
          'color': 'red',
        },
        'rating': 4.7,
      },
    ];
  }

  // 🗑️ Function to remove all sample data (for cleanup)
  Future<void> removeSampleDrivers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('active_drivers')
          .where('name', whereIn: [
            'Ahmed Khan', 'Ali Hassan', 'Muhammad Tariq', 
            'Usman Ahmed', 'Bilal Shah'
          ])
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Deleted driver: ${doc.data()}');
      }
      
      print('✅ All sample drivers removed!');
    } catch (e) {
      print('❌ Error removing sample data: $e');
    }
  }
}