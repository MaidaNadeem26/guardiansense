// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'complete_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final pass = _passwordController.text;
    setState(() {
      _hasMinLength = pass.length >= 8;
      _hasUppercase = pass.contains(RegExp(r'[A-Z]'));
      _hasNumber = pass.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordStrong() => _hasMinLength && _hasUppercase && _hasNumber && _hasSpecialChar;

  String? _sanitize(String? value) {
    if (value == null) return null;
    return value.trim().replaceAll(RegExp(r'[<>/]'), ''); // Basic XSS mitigation
  }

  Future<void> _submit() async {
    final email = _sanitize(_emailController.text);
    final password = _passwordController.text; // Don't sanitize passwords
    final name = _sanitize(_nameController.text);

    if (email == null || email.isEmpty || password.isEmpty || (!_isLogin && (name == null || name.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }

    if (!_isLogin && !_isPasswordStrong()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please use a stronger password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        UserCredential? result = await _authService.signInWithEmailAndPassword(email, password);
        if (result != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login failed. Check your credentials.")),
            );
          }
        }
      } else {
        UserCredential? result = await _authService.registerWithEmailAndPassword(email, password);
        if (result != null && result.user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CompleteProfileScreen(
                  uid: result.user!.uid,
                  name: name!,
                  email: email,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration failed.")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF3FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: SizedBox(
                height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    Spacer(flex: isSmallScreen ? 1 : 2),
                    Container(
                      height: isSmallScreen ? 65 : 75,
                      width: isSmallScreen ? 65 : 75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B8CFF).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        size: isSmallScreen ? 32 : 38,
                        color: const Color(0xFF5B8CFF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isLogin ? "Welcome Back" : "Create Account",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin
                          ? "Sign in to continue to GuardianSense"
                          : "Sign up to protect your workspace",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Spacer(flex: isSmallScreen ? 1 : 2),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _buildTab("Login", true),
                                _buildTab("Sign Up", false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!_isLogin) ...[
                            _buildLabel("Full Name"),
                            _buildTextField(
                              controller: _nameController,
                              hint: "Enter your name",
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _buildLabel("Email Address"),
                          _buildTextField(
                            controller: _emailController,
                            hint: "Enter your email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildLabel("Password"),
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Enter your password",
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 8),
                            _buildPasswordRequirements(),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B8CFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _isLogin ? "Log In" : "Create Account",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                    Spacer(flex: isSmallScreen ? 1 : 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requirementText("At least 8 characters", _hasMinLength),
        _requirementText("At least one uppercase letter", _hasUppercase),
        _requirementText("At least one number", _hasNumber),
        _requirementText("At least one special character", _hasSpecialChar),
      ],
    );
  }

  Widget _requirementText(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined, 
               size: 12, color: met ? Colors.lightGreen : Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 10, color: met ? Colors.lightGreen : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool loginTab) {
    bool selected = _isLogin == loginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLogin = loginTab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF5B8CFF) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5B8CFF), width: 1.5),
        ),
      ),
    );
  }
}
