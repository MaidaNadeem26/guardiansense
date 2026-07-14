import 'package:cloud_firestore/cloud_firestore.dart';

class LocationRecord {
  const LocationRecord({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;
  final double? speed;

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': Timestamp.fromDate(timestamp),
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null) 'speed': speed,
      };

  factory LocationRecord.fromMap(Map<String, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    return LocationRecord(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      timestamp: rawTimestamp is Timestamp ? rawTimestamp.toDate() : DateTime.now(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
    );
  }
}
