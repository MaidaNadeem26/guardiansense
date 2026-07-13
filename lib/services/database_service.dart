import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/guardian_model.dart';
import '../models/safe_zone_model.dart';

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

  Stream<List<SafeZoneModel>> streamSafeZones(String userId) {
    return _db.collection('users').doc(userId).collection('safe_zones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SafeZoneModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
