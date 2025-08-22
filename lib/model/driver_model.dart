import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String driverId;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final DateTime lastUpdated;
  final String vehicleType;
  final String plateNumber;
  final String vehicleColor;
  final double rating;

  Driver({
    required this.driverId,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.isOnline,
    required this.lastUpdated,
    required this.vehicleType,
    required this.plateNumber,
    required this.vehicleColor,
    required this.rating,
  });

  factory Driver.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Driver(
      driverId: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      latitude: data['location']['latitude'] ?? 0.0,
      longitude: data['location']['longitude'] ?? 0.0,
      isOnline: data['isOnline'] ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      vehicleType: data['vehicleInfo']['type'] ?? '',
      plateNumber: data['vehicleInfo']['plateNumber'] ?? '',
      vehicleColor: data['vehicleInfo']['color'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }
}
