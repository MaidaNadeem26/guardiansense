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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () async {
                await _authService.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
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
