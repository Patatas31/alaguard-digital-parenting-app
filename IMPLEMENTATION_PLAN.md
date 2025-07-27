# AlaGuard Implementation Plan & Code Examples

## Phase 1: Project Setup and Basic Structure

### Step 1: Create Flutter Project
```bash
# Create the project
flutter create alaguard_app
cd alaguard_app

# Add required dependencies
flutter pub add firebase_core firebase_auth cloud_firestore firebase_messaging
flutter pub add provider google_fonts shared_preferences connectivity_plus
flutter pub add permission_handler device_info_plus fl_chart intl
flutter pub add image_picker cached_network_image flutter_local_notifications
```

### Step 2: Firebase Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=alaguard-app
```

### Step 3: Main App Structure
Create the main app entry point:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AlaGuardApp());
}
```

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/colors.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/monitoring/providers/monitoring_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'routes/route_generator.dart';

class AlaGuardApp extends StatelessWidget {
  const AlaGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'AlaGuard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

## Phase 2: Core Services Implementation

### Firebase Service
```dart
// lib/core/services/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Auth instance
  static FirebaseAuth get auth => _auth;
  
  // Firestore instance
  static FirebaseFirestore get firestore => _firestore;
  
  // Messaging instance
  static FirebaseMessaging get messaging => _messaging;

  // Initialize Firebase services
  static Future<void> initialize() async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
  }
}
```

### Authentication Service
```dart
// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
    String email, 
    String password,
    String name,
    String phone,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(result.user!, name, phone);
      
      return result;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Create user document
  Future<void> _createUserDocument(User user, String name, String phone) async {
    await _firestore.collection('parents').doc(user.uid).set({
      'email': user.email,
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
```

## Phase 3: Data Models

### User Models
```dart
// lib/features/authentication/models/user_model.dart
class ParentModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImage;

  ParentModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
  });

  factory ParentModel.fromMap(Map<String, dynamic> map, String id) {
    return ParentModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImage': profileImage,
    };
  }
}

class ChildModel {
  final String id;
  final String name;
  final int age;
  final String parentId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImage;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.parentId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map, String id) {
    return ChildModel(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      parentId: map['parentId'] ?? '',
      deviceId: map['deviceId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'parentId': parentId,
      'deviceId': deviceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImage': profileImage,
    };
  }
}
```

### Activity Models
```dart
// lib/features/monitoring/models/activity_model.dart
class ActivityModel {
  final String id;
  final String childId;
  final String activityType;
  final String appName;
  final String? websiteUrl;
  final int duration; // in minutes
  final DateTime timestamp;
  final int screenTime; // in minutes
  final String? location;

  ActivityModel({
    required this.id,
    required this.childId,
    required this.activityType,
    required this.appName,
    this.websiteUrl,
    required this.duration,
    required this.timestamp,
    required this.screenTime,
    this.location,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      childId: map['childId'] ?? '',
      activityType: map['activityType'] ?? '',
      appName: map['appName'] ?? '',
      websiteUrl: map['websiteUrl'],
      duration: map['duration'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      screenTime: map['screenTime'] ?? 0,
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'activityType': activityType,
      'appName': appName,
      'websiteUrl': websiteUrl,
      'duration': duration,
      'timestamp': Timestamp.fromDate(timestamp),
      'screenTime': screenTime,
      'location': location,
    };
  }
}
```

## Phase 4: Authentication UI

### Login Screen
```dart
// lib/features/authentication/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'AlaGuard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Digital Parenting Made Simple',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                CustomButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),

                // Register link
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),

                // Forgot password link
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## Phase 5: Dashboard Implementation

### Parent Dashboard
```dart
// lib/features/dashboard/screens/parent_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/stats_widget.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({Key? key}) : super(key: key);

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: dashboardProvider.loadDashboardData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome back, ${dashboardProvider.parentName}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Stats overview
                  const StatsWidget(),
                  const SizedBox(height: 24),

                  // Children list
                  Text(
                    'Your Children',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  if (dashboardProvider.children.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.child_care,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No children added yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text('Add your first child to start monitoring'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/add-child');
                              },
                              child: const Text('Add Child'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardProvider.children.length,
                      itemBuilder: (context, index) {
                        final child = dashboardProvider.children[index];
                        return ActivityCard(child: child);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-child');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Phase 6: Monitoring System

### Activity Monitoring Provider
```dart
// lib/features/monitoring/providers/monitoring_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class MonitoringProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load activities for a specific child
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

      _activities = querySnapshot.docs
          .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load activities: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new activity log
  Future<void> addActivity(ActivityModel activity) async {
    try {
      await _firestore.collection('activityLogs').add(activity.toMap());
      _activities.insert(0, activity);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add activity: $e';
      notifyListeners();
    }
  }

  // Get screen time statistics
  Map<String, int> getScreenTimeStats(String childId) {
    final today = DateTime.now();
    final todayActivities = _activities.where((activity) =>
        activity.childId == childId &&
        activity.timestamp.day == today.day &&
        activity.timestamp.month == today.month &&
        activity.timestamp.year == today.year).toList();

    int totalScreenTime = 0;
    Map<String, int> appUsage = {};

    for (final activity in todayActivities) {
      totalScreenTime += activity.screenTime;
      appUsage[activity.appName] = (appUsage[activity.appName] ?? 0) + activity.screenTime;
    }

    return {
      'totalScreenTime': totalScreenTime,
      ...appUsage,
    };
  }
}
```

## Phase 7: Notification System

### Notification Service
```dart
// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');
    
    // Show local notification
    _showLocalNotification(
      message.notification?.title ?? 'AlaGuard',
      message.notification?.body ?? 'New notification',
    );
  }

  static Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'alaguard_channel',
      'AlaGuard Notifications',
      channelDescription: 'Notifications from AlaGuard app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  // Send notification to parent
  static Future<void> sendWarningToParent({
    required String parentId,
    required String childId,
    required String title,
    required String message,
    required String warningType,
  }) async {
    try {
      // Save notification to Firestore
      await _firestore.collection('notifications').add({
        'parentId': parentId,
        'childId': childId,
        'title': title,
        'message': message,
        'type': warningType,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save warning to warnings collection
      await _firestore.collection('warnings').add({
        'parentId': parentId,
        'childId': childId,
        'warningType': warningType,
        'message': message,
        'severity': _getSeverityLevel(warningType),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static String _getSeverityLevel(String warningType) {
    switch (warningType.toLowerCase()) {
      case 'inappropriate_content':
      case 'suspicious_activity':
        return 'high';
      case 'excessive_screen_time':
        return 'medium';
      default:
        return 'low';
    }
  }
}
```

This implementation plan provides a solid foundation for building the AlaGuard app. Each phase builds upon the previous one, allowing for incremental development and testing.
