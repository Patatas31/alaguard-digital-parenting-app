import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonitoringProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadActivities(String childId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('activityLogs')
          .where('childId', isEqualTo: childId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      _activities = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to load activities: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Map<String, int> getScreenTimeStats(String childId) {
    final today = DateTime.now();
    final todayActivities = _activities.where((activity) {
      final timestamp = (activity['timestamp'] as Timestamp?)?.toDate();
      return activity['childId'] == childId &&
          timestamp != null &&
          timestamp.day == today.day &&
          timestamp.month == today.month &&
          timestamp.year == today.year;
    }).toList();

    int totalScreenTime = 0;
    Map<String, int> appUsage = {};

    for (final activity in todayActivities) {
      final screenTime = activity['screenTime'] as int? ?? 0;
      final appName = activity['appName'] as String? ?? 'Unknown';
      
      totalScreenTime += screenTime;
      appUsage[appName] = (appUsage[appName] ?? 0) + screenTime;
    }

    return {
      'totalScreenTime': totalScreenTime,
      ...appUsage,
    };
  }
}
