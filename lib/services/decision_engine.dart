import 'dart:async';
import 'ai_service.dart';
import 'location_service.dart';
import 'database_service.dart';
import 'alert_service.dart';
import '../models/location_record.dart';

class DecisionEngine {
  final LocationService _locationService = LocationService();
  final AiService _aiService = AiService();
  final DatabaseService _databaseService = DatabaseService();
  final AlertService _alertService = AlertService();

  StreamSubscription? _locationSubscription;
  String? _currentUserId;

  // For state management in UI
  final _statusController = StreamController<String>.broadcast();
  Stream<String> get statusStream => _statusController.stream;

  final _riskController = StreamController<RiskLevel>.broadcast();
  Stream<RiskLevel> get riskStream => _riskController.stream;

  void startMonitoring(String userId) {
    _currentUserId = userId;
    _locationSubscription?.cancel();

    _locationSubscription = _locationService.locationStream().listen((location) {
      _processLocation(location);
    });

    _statusController.add("Monitoring started");
  }

  void stopMonitoring() {
    _locationSubscription?.cancel();
    _statusController.add("Monitoring stopped");
  }

  Future<void> _processLocation(LocationRecord location) async {
    if (_currentUserId == null) return;

    // 1. Save location to database
    await _databaseService.saveLocation(_currentUserId!, location);

    // 2. Check Safe Zones
    final safeZones = await _databaseService.streamSafeZones(_currentUserId!).first;
    final inZone = _locationService.containingZone(location, safeZones);

    if (inZone != null) {
      _statusController.add("User is safe in ${inZone.name}");
      _riskController.add(RiskLevel.low);
      return;
    }

    // 3. Not in a safe zone, perform AI Risk Analysis
    _statusController.add("Analyzing risk...");
    final history = await _databaseService.getLocationHistory(_currentUserId!, limit: 10);

    final analysis = await _aiService.analyzeRisk(
      location: location,
      safeZones: safeZones,
      history: history,
    );

    _riskController.add(analysis.riskLevel);
    _statusController.add("Risk: ${analysis.riskLevel.name.toUpperCase()} - ${analysis.reasoning}");

    // 4. Act based on risk level
    if (analysis.riskLevel == RiskLevel.medium) {
      // Provide voice guidance (should be triggered by UI or a separate voice service)
      _statusController.add("Guidance: ${analysis.advice}");
    } else if (analysis.riskLevel == RiskLevel.high) {
      // Alert guardians
      _alertGuardians(_currentUserId!, location, analysis);
    }
  }

  Future<void> _alertGuardians(
    String userId,
    LocationRecord location,
    AiRiskAnalysis analysis,
  ) async {
    final guardians = await _databaseService.getGuardians(userId);
    final user = await _databaseService.getUser(userId);

    final message = "URGENT: ${user?.name ?? 'The user'} might be wandering. "
        "Last seen at Lat: ${location.latitude}, Lng: ${location.longitude}. "
        "AI Analysis: ${analysis.reasoning}";

    for (var guardian in guardians) {
      // Attempt WhatsApp
      try {
        await _alertService.sendWhatsApp(guardian.phoneNumber, message);
      } catch (e) {
        // Fallback to SMS
        await _alertService.sendSMSFallback(guardian.phoneNumber, message);
      }
    }
  }

  void dispose() {
    _locationSubscription?.cancel();
    _statusController.close();
    _riskController.close();
  }
}
