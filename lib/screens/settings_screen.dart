// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../main.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _locationSharing = true;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Preferences"),
          _switchTile("Notifications", _notifications, (v) => setState(() => _notifications = v)),
          _switchTile("Location Sharing", _locationSharing, (v) => setState(() => _locationSharing = v)),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return _switchTile(
                "Dark Mode",
                currentMode == ThemeMode.dark,
                    (value) {
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
          const SizedBox(height: 20),
          _sectionTitle("Account & Security"),
          _navTile(Icons.person_outline, "Edit Profile", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
          _navTile(Icons.security_rounded, "Security (Change Password)", () => _showChangePasswordDialog()),
          _navTile(Icons.help_outline, "Help & Support", () {}),
          const SizedBox(height: 20),

          // --- Updated Professional Logout Button ---
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _showLogoutConfirmation,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              label: const Text(
                "Log Out",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.06),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              "Log Out",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
        ),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _authService.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(currentPassController, "Current Password", obscureCurrent, () {
                  setDialogState(() => obscureCurrent = !obscureCurrent);
                }, obscureCurrent),
                const SizedBox(height: 12),
                _dialogTextField(newPassController, "New Password", obscureNew, () {
                  setDialogState(() => obscureNew = !obscureNew);
                }, obscureNew),
                const SizedBox(height: 12),
                _dialogTextField(confirmPassController, "Confirm New Password", obscureNew, null, obscureNew),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (newPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New passwords do not match")));
                  return;
                }
                if (newPassController.text.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be at least 8 characters")));
                  return;
                }

                final success = await _authService.changePassword(currentPassController.text, newPassController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? "Password updated successfully" : "Update failed. Check current password.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5CFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(TextEditingController controller, String label, bool obscureText, VoidCallback? toggleObscure, bool isObscure) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2F5CFF)),
        suffixIcon: toggleObscure != null
            ? IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility), onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
    );
  }

  Widget _switchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        activeTrackColor: const Color(0xFF2F5CFF),
        onChanged: onChanged,
      ),
    );
  }

  Widget _navTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2F5CFF)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}