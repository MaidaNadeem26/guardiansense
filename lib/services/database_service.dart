import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/guardian_model.dart';
import '../models/safe_zone_model.dart';
import '../models/location_record.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Methods
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Guardian Methods
  Future<void> addGuardian(String userId, GuardianModel guardian) async {
    await _db.collection('users').doc(userId).collection('guardians').doc(guardian.id).set(guardian.toMap());
  }

  Stream<List<GuardianModel>> streamGuardians(String userId) {
    return _db.collection('users').doc(userId).collection('guardians').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => GuardianModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<List<GuardianModel>> getGuardians(String userId) async {
    var snapshot = await _db.collection('users').doc(userId).collection('guardians').get();
    return snapshot.docs.map((doc) => GuardianModel.fromMap(doc.data(), doc.id)).toList();
  }

  // Safe Zone Methods
  Future<void> addSafeZone(String userId, SafeZoneModel safeZone) async {
    await _db.collection('users').doc(userId).collection('safe_zones').doc(safeZone.id).set(safeZone.toMap());
  }

  Future<void> deleteSafeZone(String userId, String zoneId) async {
    await _db.collection('users').doc(userId).collection('safe_zones').doc(zoneId).delete();
  }

  Stream<List<SafeZoneModel>> streamSafeZones(String userId) {
    return _db.collection('users').doc(userId).collection('safe_zones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SafeZoneModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Location history is kept in a subcollection so a user's profile document
  // stays small while guardians can subscribe to the latest point.
  Future<void> saveLocation(String userId, LocationRecord location) async {
    final user = _db.collection('users').doc(userId);
    final batch = _db.batch();
    batch.set(user.collection('location_history').doc(), location.toMap());
    batch.set(user, {'lastLocation': location.toMap()}, SetOptions(merge: true));
    await batch.commit();
  }

  Stream<LocationRecord?> streamLastLocation(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      final lastLocation = data?['lastLocation'];
      if (lastLocation is Map<String, dynamic>) {
        return LocationRecord.fromMap(lastLocation);
      }
      return null;
    });
  }

  Future<List<LocationRecord>> getLocationHistory(
    String userId, {
    int limit = 100,
  }) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('location_history')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => LocationRecord.fromMap(doc.data())).toList();
  }
}
