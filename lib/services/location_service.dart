import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

import '../models/location_record.dart';
import '../models/safe_zone_model.dart';

class LocationService {
  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw PermissionDeniedException('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }
  }

  Future<LocationRecord> currentLocation() async {
    await ensurePermission();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return _record(position);
  }

  Stream<LocationRecord> locationStream() async* {
    await ensurePermission();
    final LocationSettings settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
            intervalDuration: const Duration(seconds: 10),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'GuardianSense location monitoring',
              notificationText: 'Location sharing is active.',
              enableWakeLock: true,
            ),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
          );
    yield* Geolocator.getPositionStream(locationSettings: settings).map(_record);
  }

  LocationRecord _record(Position position) => LocationRecord(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        speed: position.speed,
      );

  double distanceToZone(LocationRecord location, SafeZoneModel zone) =>
      Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        zone.latitude,
        zone.longitude,
      );

  SafeZoneModel? containingZone(
    LocationRecord location,
    Iterable<SafeZoneModel> zones,
  ) {
    for (final zone in zones) {
      if (distanceToZone(location, zone) <= zone.radius) return zone;
    }
    return null;
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
