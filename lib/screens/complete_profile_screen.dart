// lib/screens/complete_profile_screen.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'dashboard_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;

  const CompleteProfileScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      UserModel user = UserModel(
        id: widget.uid,
        name: widget.name,
        email: widget.email,
        phoneNumber: _phoneController.text.trim(),
        homeAddress: _addressController.text.trim(),
        medicalNotes: _medicalNotesController.text.trim(),
      );

      await _databaseService.saveUser(user);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Complete Your Profile",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Icon + Heading ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5CFF).withValues(alpha: isDark ? 0.15 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_moon_rounded, color: Color(0xFF2F5CFF), size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                "Almost there!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor, letterSpacing: -0.4),
              ),
              const SizedBox(height: 8),
              Text(
                "Please provide a few more details to help us protect you better.",
                style: TextStyle(color: secondaryTextColor, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 32),

              _buildLabel("Phone Number", primaryTextColor),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: "e.g. +92 300 1234567",
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              _buildLabel("Home Address", primaryTextColor),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressController,
                hint: "Enter your full address",
                icon: Icons.home_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              _buildLabel("Medical Notes", primaryTextColor),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _medicalNotesController,
                hint: "Any allergies or conditions?",
                icon: Icons.medical_information_rounded,
                maxLines: 3,
                isDark: isDark,
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5CFF),
                    disabledBackgroundColor: const Color(0xFF2F5CFF).withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text(
                    "Complete Setup",
                    style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: color),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey[isDark ? 500 : 400]),
        // Multiline fields ke liye icon ko top pe align kiya, taake overlap na ho
        prefixIcon: maxLines > 1
            ? Padding(
          padding: const EdgeInsets.only(bottom: 44),
          child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        )
            : Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        alignLabelWithHint: true,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2F5CFF), width: 1.5),
        ),
      ),
    );
  }
}