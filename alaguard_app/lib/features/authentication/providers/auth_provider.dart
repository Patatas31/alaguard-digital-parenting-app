import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        _user = result.user;
        
        // Update FCM token
        await NotificationService.updateFCMToken(result.user!.uid);
        
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document in Firestore
        await _createUserDocument(result.user!, name, phone);
        
        // Update display name
        await result.user!.updateDisplayName(name);
        
        _user = result.user;
        
        // Update FCM token
        await NotificationService.updateFCMToken(result.user!.uid);
        
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name, String phone) async {
    try {
      String? fcmToken = await NotificationService.getFCMToken();
      
      await _firestore.collection('parents').doc(user.uid).set({
        'email': user.email,
        'name': name,
        'phone': phone,
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError('Error signing out. Please try again.');
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_user != null) {
        // Update display name
        await _user!.updateDisplayName(name);
        
        // Update Firestore document
        await _firestore.collection('parents').doc(_user!.uid).update({
          'name': name,
          'phone': phone,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError('Error updating profile. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('parents')
            .doc(_user!.uid)
            .get();
        
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      if (_user != null) {
        // Delete user document from Firestore
        await _firestore.collection('parents').doc(_user!.uid).delete();
        
        // Delete user account
        await _user!.delete();
        
        _user = null;
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Error deleting account. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'Please log out and log back in to perform this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
