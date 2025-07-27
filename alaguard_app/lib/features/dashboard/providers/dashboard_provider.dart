import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic> _parentData = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get children => _children;
  Map<String, dynamic> get parentData => _parentData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get parentName => _parentData['name'] ?? 'Parent';

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Load parent data
        final parentDoc = await _firestore.collection('parents').doc(user.uid).get();
        if (parentDoc.exists) {
          _parentData = parentDoc.data() ?? {};
        }

        // Load children data
        final childrenQuery = await _firestore
            .collection('children')
            .where('parentId', isEqualTo: user.uid)
            .get();

        _children = childrenQuery.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChild({
    required String name,
    required int age,
    String? deviceId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('children').add({
          'name': name,
          'age': age,
          'parentId': user.uid,
          'deviceId': deviceId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Reload dashboard data
        await loadDashboardData();
      }
    } catch (e) {
      _errorMessage = 'Failed to add child: $e';
      notifyListeners();
    }
  }

  Future<void> removeChild(String childId) async {
    try {
      await _firestore.collection('children').doc(childId).delete();
      
      // Remove from local list
      _children.removeWhere((child) => child['id'] == childId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove child: $e';
      notifyListeners();
    }
  }
}
