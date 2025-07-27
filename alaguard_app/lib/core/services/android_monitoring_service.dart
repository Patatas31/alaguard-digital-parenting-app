import 'dart:async';
import 'package:flutter/services.dart';

/// This is a SIMPLE Android monitoring service
/// It watches what apps the child uses and reports to parents
/// Think of it like a security camera for the phone

class AndroidMonitoringService {
  static const MethodChannel _channel = 
      MethodChannel('com.alaguard.app/monitoring');

  /// Starts monitoring when phone turns on
  static Future<void> startMonitoring() async {
    try {
      await _channel.invokeMethod('startMonitoring');
      print('✅ Monitoring started successfully');
    } catch (e) {
      print('❌ Error starting monitoring: $e');
    }
  }

  /// Gets list of apps child used today
  static Future<List<Map<String, dynamic>>> getTodayUsage() async {
    try {
      final result = await _channel.invokeMethod('getTodayUsage');
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('❌ Error getting usage: $e');
      return [];
    }
  }

  /// Checks if child opened a specific app
  static Future<bool> isAppRunning(String packageName) async {
    try {
      final result = await _channel.invokeMethod(
        'isAppRunning', 
        {'packageName': packageName}
      );
      return result ?? false;
    } catch (e) {
      print('❌ Error checking app: $e');
      return false;
    }
  }

  /// Gets total screen time today
  static Future<int> getTotalScreenTime() async {
    try {
      final result = await _channel.invokeMethod('getTotalScreenTime');
      return result ?? 0;
    } catch (e) {
      print('❌ Error getting screen time: $e');
      return 0;
    }
  }

  /// Simple usage data structure
  static Map<String, dynamic> createUsageData({
    required String appName,
    required String packageName,
    required int usageTimeMinutes,
    required DateTime startTime,
  }) {
    return {
      'appName': appName,
      'packageName': packageName,
      'usageTimeMinutes': usageTimeMinutes,
      'startTime': startTime.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// This is a simple timer that checks usage every minute
class SimpleUsageTimer {
  Timer? _timer;
  
  void startMonitoring() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkCurrentApp();
    });
  }
  
  void stopMonitoring() {
    _timer?.cancel();
  }
  
  Future<void> _checkCurrentApp() async {
    // This would check what app is currently open
    // For beginners, we'll use a simple approach
    print('🔍 Checking current app...');
    
    // In real implementation, this would use Android APIs
    final usage = await AndroidMonitoringService.getTodayUsage();
    print('📊 Today\'s usage: $usage');
  }
}
