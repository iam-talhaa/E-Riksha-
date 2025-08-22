import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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