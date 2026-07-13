import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GemmaApiService {
  
  // This function is what the frontend team will call when a user clicks a button
  Future<String> getSafetyAdvice(String userContext) async {
    
    // 1. Load your secure API key from the .env file
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('API Key not found. Check your .env file.');
    }

    // 2. The Gemma API Endpoint 
    // Notice the key is passed directly in the URL as a query parameter
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemma-2-9b-it:generateContent?key=$apiKey');

    // 3. --- PROMPT ENGINEERING HAPPENS HERE ---
    // You don't just send raw user data to the AI. You wrap it in instructions.
    // You tell the AI who it is, what rules to follow, and what format to return.
    // 3. --- PROMPT ENGINEERING HAPPENS HERE ---
    final String prompt = '''
    You are GuardianSense, an AI safety assistant speaking directly to a user who may have Alzheimer's, dementia, or a visual impairment. 
    The user might be disoriented, lost, or anxious.
    
    CRITICAL RULES:
    1. Tone: Be extremely calm, reassuring, and gentle. Never sound robotic or urgent.
    2. Simplicity: Use short, basic words. Avoid complex sentences or multi-step directions.
    3. Actionable: Give exactly ONE safe instruction (e.g., "Please stay exactly where you are," or "I am calling your caregiver now.")
    4. Length: Strictly keep your response under 3 sentences.
    
    CURRENT CONTEXT & USER INPUT: 
    $userContext
    
    YOUR SPOKEN RESPONSE:
    ''';

    // 4. Make the HTTP POST Request
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        // The API requires the body to be formatted in this specific JSON structure
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": prompt}]
          }]
        }),
      );

      // 5. Parse the Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Digging through the JSON response to extract just the AI's text string
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Error: Unable to generate advice right now. Please try again.';
      }
    } catch (e) {
      return 'Network Error: Check your connection.';
    }
  }
}