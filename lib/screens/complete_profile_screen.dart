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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Almost there!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please provide a few more details to help us protect you better.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildLabel("Phone Number"),
            _buildTextField(
              controller: _phoneController,
              hint: "e.g. +92 300 1234567",
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildLabel("Home Address"),
            _buildTextField(
              controller: _addressController,
              hint: "Enter your full address",
              icon: Icons.home_rounded,
            ),
            const SizedBox(height: 16),
            _buildLabel("Medical Notes"),
            _buildTextField(
              controller: _medicalNotesController,
              hint: "Any allergies or conditions?",
              icon: Icons.medical_information_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Complete Setup",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2F5CFF), width: 1.5),
        ),
      ),
    );
  }
}
