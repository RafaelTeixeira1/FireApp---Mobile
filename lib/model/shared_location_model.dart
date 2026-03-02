import 'package:latlong2/latlong.dart';

class SharedLocation {
  final String id;
  final double lat;
  final double lng;
  final String name;
  final String description;
  final String createdBy;
  final String type;

  SharedLocation({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.type,
  });

  factory SharedLocation.fromMap(String id, Map<String, dynamic> map) {
    return SharedLocation(
      id: id,
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['created_by'] ?? '',
      type: map['type'] ?? 'point',
    );
  }

  LatLng toLatLng() {
    return LatLng(lat, lng);
  }
}