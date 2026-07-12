// lib/screens/safe_zones_screen.dart
import 'package:flutter/material.dart';

class SafeZonesScreen extends StatefulWidget {
  const SafeZonesScreen({super.key});

  @override
  State<SafeZonesScreen> createState() => _SafeZonesScreenState();
}

class _SafeZonesScreenState extends State<SafeZonesScreen> {
  final List<Map<String, dynamic>> _zones = [
    {"name": "Home", "radius": "200m", "icon": Icons.home_outlined, "active": true},
    {"name": "Park", "radius": "150m", "icon": Icons.park_outlined, "active": true},
    {"name": "Clinic", "radius": "100m", "icon": Icons.local_hospital_outlined, "active": false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Safe Zones"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _zones.length,
                itemBuilder: (context, index) {
                  final zone = _zones[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: zone["active"]
                                ? Colors.green.withValues(alpha: isDark ? 0.2 : 0.1)
                                : Colors.grey.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            zone["icon"] as IconData,
                            color: zone["active"] ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zone["name"] as String,
                                style: TextStyle(fontWeight: FontWeight.w600, color: primaryTextColor),
                              ),
                              Text(
                                "Radius: ${zone["radius"]}",
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: zone["active"] as bool,
                          activeColor: const Color(0xFF2F5CFF),
                          onChanged: (value) {
                            setState(() {
                              _zones[index]["active"] = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${zone["name"]} zone ${value ? "activated" : "deactivated"}",
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _zones.add({
                      "name": "New Zone",
                      "radius": "100m",
                      "icon": Icons.location_on_outlined,
                      "active": true,
                    });
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add Safe Zone", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}