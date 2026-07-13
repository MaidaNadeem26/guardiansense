import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Re-authenticate user for sensitive operations
  Future<bool> verifyPassword(String password) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) return false;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint("Re-authentication failed: $e");
      return false;
    }
  }

  // Change password facility
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    bool isVerified = await verifyPassword(currentPassword);
    if (!isVerified) return false;

    try {
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint("Password update failed: $e");
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
