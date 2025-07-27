import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _warnings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get warnings => _warnings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadNotificationsCount => _notifications.where((n) => !(n['isRead'] ?? false)).length;
  int get unreadWarningsCount => _warnings.where((w) => !(w['isRead'] ?? false)).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Load notifications
        final notificationsQuery = await _firestore
            .collection('notifications')
            .where('parentId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        _notifications = notificationsQuery.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        // Load warnings
        final warningsQuery = await _firestore
            .collection('warnings')
            .where('parentId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        _warnings = warningsQuery.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });

      // Update local data
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  Future<void> markWarningAsRead(String warningId) async {
    try {
      await _firestore.collection('warnings').doc(warningId).update({
        'isRead': true,
      });

      // Update local data
      final index = _warnings.indexWhere((w) => w['id'] == warningId);
      if (index != -1) {
        _warnings[index]['isRead'] = true;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark warning as read: $e';
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        
        for (final notification in _notifications) {
          if (!(notification['isRead'] ?? false)) {
            final docRef = _firestore.collection('notifications').doc(notification['id']);
            batch.update(docRef, {'isRead': true});
          }
        }
        
        await batch.commit();
        
        // Update local data
        for (final notification in _notifications) {
          notification['isRead'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark all notifications as read: $e';
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        
        for (final notification in _notifications) {
          final docRef = _firestore.collection('notifications').doc(notification['id']);
          batch.delete(docRef);
        }
        
        await batch.commit();
        
        // Clear local data
        _notifications.clear();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to clear notifications: $e';
      notifyListeners();
    }
  }
}
