import 'package:flutter/material.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/authentication/screens/forgot_password_screen.dart';
import '../features/dashboard/screens/parent_dashboard.dart';
import '../features/profile/screens/add_child_screen.dart';
import '../features/profile/screens/child_profile_screen.dart';
import '../features/profile/screens/parent_profile_screen.dart';
import '../features/monitoring/screens/activity_monitor_screen.dart';
import '../features/monitoring/screens/app_usage_screen.dart';
import '../features/monitoring/screens/web_history_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/notifications/screens/warnings_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/privacy_settings_screen.dart';
import '../features/settings/screens/notification_settings_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const ParentDashboard());
      
      case '/add-child':
        return MaterialPageRoute(builder: (_) => const AddChildScreen());
      
      case '/child-profile':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChildProfileScreen(
            childId: args?['childId'] ?? '',
          ),
        );
      
      case '/parent-profile':
        return MaterialPageRoute(builder: (_) => const ParentProfileScreen());
      
      case '/activity-monitor':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ActivityMonitorScreen(
            childId: args?['childId'] ?? '',
          ),
        );
      
      case '/app-usage':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AppUsageScreen(
            childId: args?['childId'] ?? '',
          ),
        );
      
      case '/web-history':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WebHistoryScreen(
            childId: args?['childId'] ?? '',
          ),
        );
      
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      
      case '/warnings':
        return MaterialPageRoute(builder: (_) => const WarningsScreen());
      
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case '/privacy-settings':
        return MaterialPageRoute(builder: (_) => const PrivacySettingsScreen());
      
      case '/notification-settings':
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text(
            'Page not found!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
