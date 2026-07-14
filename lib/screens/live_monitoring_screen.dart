import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/location_record.dart';
import '../models/safe_zone_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/decision_engine.dart';
import '../services/ai_service.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  final _locationService = LocationService();
  final _database = DatabaseService();
  final _decisionEngine = DecisionEngine();
  final _mapController = MapController();
  final _flutterTts = FlutterTts();
  final _aiService = AiService();

  StreamSubscription<LocationRecord>? _locationSubscription;
  LocationRecord? _location;
  String _status = "Waiting to start...";
  RiskLevel _riskLevel = RiskLevel.low;
  bool _tracking = false;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("ur-PK");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _decisionEngine.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _startTracking() {
    final userId = _userId;
    if (userId == null) return;

    _decisionEngine.startMonitoring(userId);

    _locationSubscription = _locationService.locationStream().listen((loc) {
      if (mounted) {
        setState(() {
          _location = loc;
          _mapController.move(LatLng(loc.latitude, loc.longitude), 16);
        });
      }
    });

    _decisionEngine.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
      if (status.startsWith("Guidance: ")) {
        _speakGuidance(status.replaceFirst("Guidance: ", ""));
      }
    });

    _decisionEngine.riskStream.listen((risk) {
      if (mounted) setState(() => _riskLevel = risk);
    });

    setState(() => _tracking = true);
  }

  Future<void> _speakGuidance(String englishAdvice) async {
    final urduAdvice = await _aiService.getUrduAdvice(englishAdvice);
    await _flutterTts.speak(urduAdvice);
  }

  void _stopTracking() {
    _decisionEngine.stopMonitoring();
    _locationSubscription?.cancel();
    setState(() => _tracking = false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Sign in to use monitoring.')));
    }

    return StreamBuilder<List<SafeZoneModel>>(
      stream: _database.streamSafeZones(userId),
      builder: (context, snapshot) {
        final zones = snapshot.data ?? [];
        final center = _location == null
            ? const LatLng(33.6844, 73.0479)
            : LatLng(_location!.latitude, _location!.longitude);

        return Scaffold(
          appBar: AppBar(title: const Text('Live Monitoring'), centerTitle: true),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(initialCenter: center, initialZoom: _location == null ? 12 : 16),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        CircleLayer(
                          circles: zones
                              .map((zone) => CircleMarker(
                                    point: LatLng(zone.latitude, zone.longitude),
                                    radius: zone.radius,
                                    useRadiusInMeter: true,
                                    color: Colors.green.withValues(alpha: 0.16),
                                    borderColor: Colors.green,
                                    borderStrokeWidth: 2,
                                  ))
                              .toList(),
                        ),
                        if (_location != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_location!.latitude, _location!.longitude),
                                width: 48,
                                height: 48,
                                child: const Icon(Icons.my_location, color: Color(0xFF2F5CFF), size: 42),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _statusCard(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _tracking ? _stopTracking : _startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _tracking ? Colors.red : const Color(0xFF2F5CFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(_tracking ? Icons.stop_circle_outlined : Icons.play_arrow_rounded),
                        label: Text(_tracking ? 'Stop Monitoring' : 'Start GuardianSense AI'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusCard() {
    Color riskColor;
    switch (_riskLevel) {
      case RiskLevel.high: riskColor = Colors.red; break;
      case RiskLevel.medium: riskColor = Colors.orange; break;
      case RiskLevel.low:
      default: riskColor = Colors.green; break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: riskColor),
              const SizedBox(width: 12),
              Text(
                "Risk Level: ${_riskLevel.name.toUpperCase()}",
                style: TextStyle(fontWeight: FontWeight.bold, color: riskColor),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
