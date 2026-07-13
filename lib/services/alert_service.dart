import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertService {
  Future<void> sendSMSFallback(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        debugPrint('Could not launch SMS');
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        debugPrint('Could not launch Phone Call');
      }
    } catch (e) {
      debugPrint('Error launching Phone Call: $e');
    }
  }
}
