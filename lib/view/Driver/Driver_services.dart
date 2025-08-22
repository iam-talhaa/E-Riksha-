import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_riksha/model/driver_model.dart';
import 'package:geolocator/geolocator.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get nearby drivers within radius (in meters)
  Stream<List<Driver>> getNearbyDrivers({
    required double userLat,
    required double userLng,
    double radiusInMeters = 5000, // 5km default
  }) {
    return _firestore
        .collection('active_drivers')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      List<Driver> drivers = snapshot.docs
          .map((doc) => Driver.fromFirestore(doc))
          .where((driver) {
        // Calculate distance between user and driver
        double distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          driver.latitude,
          driver.longitude,
        );
        return distance <= radiusInMeters;
      }).toList();
      
      // Sort by distance (closest first)
      drivers.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          userLat, userLng, a.latitude, a.longitude);
        double distanceB = Geolocator.distanceBetween(
          userLat, userLng, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });
      
      return drivers;
    });
  }
  
  // Add/Update driver location (for driver app)
  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> driverData,
  }) async {
    await _firestore.collection('active_drivers').doc(driverId).set({
      ...driverData,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'lastUpdated': FieldValue.serverTimestamp(),
      'isOnline': true,
    }, SetOptions(merge: true));
  }
}