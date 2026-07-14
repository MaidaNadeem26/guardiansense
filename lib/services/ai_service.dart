import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/location_record.dart';
import '../models/safe_zone_model.dart';

enum RiskLevel { low, medium, high }

class AiRiskAnalysis {
  final RiskLevel riskLevel;
  final String reasoning;
  final String advice;

  AiRiskAnalysis({
    required this.riskLevel,
    required this.reasoning,
    required this.advice,
  });
}

class AiService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<AiRiskAnalysis> analyzeRisk({
    required LocationRecord location,
    required List<SafeZoneModel> safeZones,
    required List<LocationRecord> history,
  }) async {
    if (_apiKey == null) {
      throw Exception('API Key not found. Check your .env file.');
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey');

    final String context = _buildContext(location, safeZones, history);

    final String prompt = '''
    You are GuardianSense, an AI safety assistant for people with cognitive impairments.
    Analyze the following user context and determine the risk level (LOW, MEDIUM, or HIGH).

    CONTEXT:
    $context

    RULES:
    1. Risk Level:
       - LOW: User is within a safe zone or moving normally between them.
       - MEDIUM: User is slightly outside a safe zone or moving in an unusual pattern.
       - HIGH: User is far from safe zones, moving rapidly away, or in a known dangerous area.
    2. Respond strictly in JSON format:
    {
      "risk_level": "LOW/MEDIUM/HIGH",
      "reasoning": "Brief explanation of the risk",
      "advice": "Reassuring advice for the user (in English, max 2 sentences)"
    }
    ''';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": prompt}]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON from response (sometimes Gemini wraps it in markdown blocks)
        final jsonString = _extractJson(text);
        final result = jsonDecode(jsonString);

        return AiRiskAnalysis(
          riskLevel: _parseRiskLevel(result['risk_level']),
          reasoning: result['reasoning'] ?? '',
          advice: result['advice'] ?? '',
        );
      } else {
        throw Exception('Failed to analyze risk: ${response.body}');
      }
    } catch (e) {
      // Fallback logic if AI fails
      return AiRiskAnalysis(
        riskLevel: RiskLevel.low,
        reasoning: 'AI analysis unavailable. Using default safety check.',
        advice: 'Please stay safe and wait for instructions.',
      );
    }
  }

  String _buildContext(
    LocationRecord location,
    List<SafeZoneModel> safeZones,
    List<LocationRecord> history,
  ) {
    String zonesStr = safeZones.map((z) => '${z.name} (Radius: ${z.radius}m)').join(', ');
    return '''
    Current Location: Lat ${location.latitude}, Lng ${location.longitude}
    Timestamp: ${location.timestamp}
    Safe Zones: $zonesStr
    Recent History: ${history.length} points recorded.
    ''';
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1) {
      return text.substring(start, end + 1);
    }
    return text;
  }

  RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toUpperCase()) {
      case 'HIGH':
        return RiskLevel.high;
      case 'MEDIUM':
        return RiskLevel.medium;
      case 'LOW':
      default:
        return RiskLevel.low;
    }
  }

  Future<String> getUrduAdvice(String englishAdvice) async {
    if (_apiKey == null) return "براہ کرم احتیاط کریں۔";

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey');

    final String prompt = "Translate the following reassuring advice into simple, easy-to-understand Urdu for a person who might be confused: '$englishAdvice'";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": prompt}]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (_) {}
    return "براہ کرم وہیں رہیں جہاں آپ ہیں۔";
  }
}
