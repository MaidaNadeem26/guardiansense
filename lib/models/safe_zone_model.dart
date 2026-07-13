class SafeZoneModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in meters

  SafeZoneModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory SafeZoneModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SafeZoneModel(
      id: documentId,
      name: data['name'] ?? 'Unknown Zone',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      radius: data['radius']?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}
