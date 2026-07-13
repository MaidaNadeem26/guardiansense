// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  UserModel? _userModel;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    User? currentUser = _authService.currentUser;
    if (currentUser != null) {
      UserModel? user = await _databaseService.getUser(currentUser.uid);
      if (mounted) {
        setState(() {
          _userModel = user;
          _isLoading = false;
          if (user != null) {
            _nameController.text = user.name;
            _phoneController.text = user.phoneNumber ?? "";
            _addressController.text = user.homeAddress ?? "";
            _medicalController.text = user.medicalNotes ?? "";
          }
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndEnterEditMode() async {
    final passwordController = TextEditingController();
    bool obscureText = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Verify Password", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("To edit profile details, please enter your password for security.", 
                style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2F5CFF)),
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscureText = !obscureText),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final verified = await _authService.verifyPassword(passwordController.text);
                if (mounted) Navigator.pop(context, verified);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5CFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Verify", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() => _isEditing = true);
    } else if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect password. Access denied.")));
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_userModel == null) return;
    setState(() => _isLoading = true);

    try {
      UserModel updatedUser = UserModel(
        id: _userModel!.id,
        name: _nameController.text.trim(),
        email: _userModel!.email,
        phoneNumber: _phoneController.text.trim(),
        homeAddress: _addressController.text.trim(),
        medicalNotes: _medicalController.text.trim(),
        guardianIds: _userModel!.guardianIds,
      );

      await _databaseService.saveUser(updatedUser);
      setState(() {
        _userModel = updatedUser;
        _isEditing = false;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Member Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0), width: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userModel == null
              ? const Center(child: Text("User details not found."))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                          child: Icon(Icons.person_rounded, size: 48, color: isDark ? Colors.grey[300] : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_isEditing) ...[
                        Text(_userModel!.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor)),
                        const SizedBox(height: 4),
                        const Text("Protected Member", style: TextStyle(color: Color(0xFF2F5CFF), fontSize: 12)),
                        const SizedBox(height: 28),
                        _infoCard(Icons.phone_iphone_rounded, "Phone Number", _userModel!.phoneNumber ?? "Not set"),
                        _infoCard(Icons.mail_outline_rounded, "Email Address", _userModel!.email ?? "Not set"),
                        _infoCard(Icons.home_work_rounded, "Home Address", _userModel!.homeAddress ?? "Not set"),
                        _infoCard(Icons.medical_information_rounded, "Medical Notes", _userModel!.medicalNotes ?? "None"),
                      ] else ...[
                        _editField(_nameController, "Full Name", Icons.person_outline),
                        _editField(_phoneController, "Phone Number", Icons.phone_iphone_rounded),
                        _editField(_addressController, "Home Address", Icons.home_work_rounded),
                        _editField(_medicalController, "Medical Notes", Icons.medical_information_rounded, maxLines: 3),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isEditing ? _saveChanges : _verifyAndEnterEditMode,
                          icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_note_rounded, color: Colors.white, size: 20),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F5CFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          label: Text(_isEditing ? "Save Changes" : "Edit Profile Details", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 12),
                        TextButton(onPressed: () => setState(() => _isEditing = false), child: const Text("Cancel")),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _editField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2F5CFF)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
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
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F5CFF), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const SizedBox(height: 3),
                Text(value, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: primaryTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
