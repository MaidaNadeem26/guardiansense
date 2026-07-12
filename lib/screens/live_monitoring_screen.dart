// lib/screens/live_monitoring_screen.dart
import 'package:flutter/material.dart';

class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Live Monitoring",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      body: Column(
        children: [
          // --- Enhanced Map Placeholder Area ---
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF2F5CFF).withValues(alpha: 0.3) : const Color(0xFFDBEAFE), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F5CFF).withValues(alpha: isDark ? 0.1 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.15,
                    child: Icon(Icons.grid_4x4_rounded, size: MediaQuery.of(context).size.width * 0.6, color: const Color(0xFF2F5CFF)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2F5CFF).withValues(alpha: 0.15),
                              blurRadius: 24,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(Icons.my_location_rounded, size: 36, color: Color(0xFF2F5CFF)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "GPS Tracking Active",
                        style: TextStyle(color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Google Maps integration placeholder",
                        style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Vitals & Telemetry Feed ---
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      "Telemetry & Current Status",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryTextColor),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _statusRow(context, Icons.fmd_good_rounded, "Location", "Home - Safe Zone", const Color(0xFF2F5CFF)),
                        _statusRow(context, Icons.favorite_rounded, "Heart Rate", "76 BPM", const Color(0xFFEF4444)),
                        _statusRow(context, Icons.directions_walk_rounded, "Current Activity", "Walking Mode", const Color(0xFF10B981)),
                        _statusRow(context, Icons.battery_charging_full_rounded, "Device Battery", "82% Connected", const Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(BuildContext context, IconData icon, String label, String value, Color themeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF334155);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: primaryTextColor),
          ),
        ],
      ),
    );
  }
}