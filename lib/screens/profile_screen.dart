// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Member Profile",
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          children: [
            // --- Premium Avatar with Edit Indicator ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2F5CFF).withValues(alpha: 0.2), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                      child: Icon(Icons.person_rounded, size: 48, color: isDark ? Colors.grey[300] : const Color(0xFF64748B)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F5CFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- User Identity ---
            Text(
              "Muhammad Adeel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor, letterSpacing: -0.3),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2F5CFF).withValues(alpha: isDark ? 0.18 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Protected Member",
                style: TextStyle(color: Color(0xFF2F5CFF), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 28),

            // --- Info List Section ---
            _infoCard(context, Icons.phone_iphone_rounded, "Phone Number", "+92 300 1234567"),
            _infoCard(context, Icons.mail_outline_rounded, "Email Address", "adeel@example.com"),
            _infoCard(context, Icons.home_work_rounded, "Home Address", "House 12, Street 5, Islamabad"),
            _infoCard(context, Icons.medical_information_rounded, "Medical Notes", "Mild memory concerns"),

            const SizedBox(height: 24),

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5CFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: const Text(
                  "Edit Profile Details",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF334155);
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2F5CFF).withValues(alpha: isDark ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2F5CFF), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, letterSpacing: 0.2),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}