import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/safe_zone_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class SafeZonesScreen extends StatelessWidget {
  const SafeZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Sign in to manage safe zones.')));
    }
    final database = DatabaseService();
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Zones')),
      body: StreamBuilder<List<SafeZoneModel>>(
        stream: database.streamSafeZones(userId),
        builder: (context, snapshot) {
          final zones = snapshot.data ?? const <SafeZoneModel>[];
          if (zones.isEmpty) {
            return const Center(child: Text('No safe zones yet. Add your current location.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: zones.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final zone = zones[index];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: Colors.green.withValues(alpha: 0.08),
                leading: const Icon(Icons.shield_outlined, color: Colors.green),
                title: Text(zone.name),
                subtitle: Text('${zone.radius.toStringAsFixed(0)} m radius'),
                trailing: IconButton(
                  tooltip: 'Remove safe zone',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => database.deleteSafeZone(userId, zone.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCurrentLocationZone(context, userId, database),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add current location'),
      ),
    );
  }

  Future<void> _addCurrentLocationZone(
    BuildContext context,
    String userId,
    DatabaseService database,
  ) async {
    try {
      final location = await LocationService().currentLocation();
      if (!context.mounted) return;
      final name = await _zoneName(context);
      if (name == null || name.trim().isEmpty) return;
      final zone = SafeZoneModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        radius: 150,
      );
      await database.addSafeZone(userId, zone);
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<String?> _zoneName(BuildContext context) {
    final controller = TextEditingController(text: 'Home');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safe zone name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }
}
