import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/linking_session.dart';

class LinkingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  LinkingSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;

  LinkingSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> generateLinkingSession({
    required String childName,
    required int childAge,
    String? deviceName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final parentId = _auth.currentUser!.uid;
      final childId = _firestore.collection('children').doc().id;
      
      final session = LinkingSession(
        id: childId,
        parentId: parentId,
        childId: childId,
        childName: childName,
        childAge: childAge,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: 10)),
        deviceName: deviceName,
      );

      await _firestore
          .collection('linkingSessions')
          .doc(childId)
          .set(session.toMap());

      _currentSession = session;
    } catch (e) {
      _errorMessage = 'Failed to generate linking session: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAndLinkChild(String sessionId, String deviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionDoc = await _firestore
          .collection('linkingSessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        _errorMessage = 'Invalid linking session';
        return false;
      }

      final session = LinkingSession.fromMap(sessionDoc.data()!, sessionId);
      
      if (session.isExpired) {
        _errorMessage = 'Linking session expired';
        return false;
      }

      if (session.isUsed) {
        _errorMessage = 'Linking session already used';
        return false;
      }

      // Get device info
      String deviceName = 'Unknown Device';
      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await _deviceInfo.androidInfo;
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          deviceName = iosInfo.name ?? 'iOS Device';
        }
      } catch (e) {
        deviceName = deviceId.substring(0, 8);
      }

      // Create child account
      final child = {
        'parentId': session.parentId,
        'name': session.childName,
        'age': session.childAge,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('children')
          .doc(session.childId)
          .set(child);

      // Mark session as used
      await _firestore
          .collection('linkingSessions')
          .doc(sessionId)
          .update({'isUsed': true});

      return true;
    } catch (e) {
      _errorMessage = 'Failed to link child: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearSession() async {
    _currentSession = null;
    _errorMessage = null;
    notifyListeners();
  }
}
