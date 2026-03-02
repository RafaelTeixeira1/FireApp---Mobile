import 'package:firebase_database/firebase_database.dart';
import 'package:fire_app/model/shared_location_model.dart';

class FirebaseLocationService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Buscar todos os pontos compartilhados
  Stream<List<SharedLocation>> getSharedLocations() {
    return _databaseRef
        .child('shared_locations')
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      
      if (data == null) return [];
      
      final List<SharedLocation> locations = [];
      
      data.forEach((key, value) {
        final location = SharedLocation.fromMap(key.toString(), Map<String, dynamic>.from(value));
        locations.add(location);
      });
      
      return locations;
    });
  }

  // Adicionar novo ponto (opcional - para testes)
  Future<void> addSharedLocation(SharedLocation location) async {
    await _databaseRef.child('shared_locations').push().set({
      'lat': location.lat,
      'lng': location.lng,
      'name': location.name,
      'description': location.description,
      'created_by': location.createdBy,
      'type': location.type,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}