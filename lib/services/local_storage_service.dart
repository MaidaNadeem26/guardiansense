import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _boxName = 'guardiansense_box';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // Save string data
  Future<void> saveString(String key, String value) async {
    await _box.put(key, value);
  }

  // Read string data
  String? getString(String key) {
    return _box.get(key);
  }

  // Save map data
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  // Read map data
  Map<dynamic, dynamic>? getMap(String key) {
    return _box.get(key);
  }

  // Remove key
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  // Clear all
  Future<void> clearAll() async {
    await _box.clear();
  }
}
