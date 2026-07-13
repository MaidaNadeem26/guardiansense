// lib/screens/ai_analysis_screen.dart
import 'package:flutter/material.dart';

class AiAnalysisScreen extends StatelessWidget {
  const AiAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final heights = [60.0, 90.0, 40.0, 110.0, 70.0, 100.0, 50.0];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "AI Insights & Analysis",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2F5CFF), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F5CFF).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "System Status Optimal",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "No unusual patterns detected in the last 7 days.",
                          style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              "Weekly Activity Trends",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: heights[i],
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF2F5CFF),
                                        const Color(0xFF2F5CFF).withValues(alpha: 0.4),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(7, (i) {
                      return Expanded(
                        child: Text(
                          days[i],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              "Behavioral Insights",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 14),
            _insightTile(context, Icons.bedtime_rounded, "Sleep Analysis", "Sleep pattern remains highly consistent this week.", const Color(0xFF8B5CF6)),
            _insightTile(context, Icons.restaurant_rounded, "Dietary Routine", "Meal times were slightly delayed on Tuesday afternoon.", const Color(0xFFF59E0B)),
            _insightTile(context, Icons.directions_walk_rounded, "Mobility Check", "Overall physical activity levels are within normal baseline.", const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }

  Widget _insightTile(BuildContext context, IconData icon, String title, String description, Color themeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.5, color: secondaryTextColor, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
