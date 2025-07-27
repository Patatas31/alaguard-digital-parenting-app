# AlaGuard - Digital Parenting Mobile App Development Guide

## Project Overview
**AlaGuard** is a digital parenting mobile application with activity monitoring and notification system designed to strengthen parent-child relationships in online safety.

## Technology Stack

### Frontend
- **Flutter** (Cross-platform mobile development)
- **Dart** (Programming language)

### Backend & Database
- **Firebase Authentication** (User management)
- **Cloud Firestore** (NoSQL database)
- **Firebase Cloud Messaging** (Push notifications)
- **Firebase Storage** (File storage)
- **Firebase Functions** (Server-side logic)

### Development Environment
- **Android Studio** or **Visual Studio Code**
- **Flutter SDK**
- **Firebase CLI**
- **Git** for version control
- **GitHub** for repository hosting

## Database Schema (Based on Capstone Paper)

### Collections Structure:

#### 1. Parents Collection
```
parents/
├── {parentId}/
    ├── email: string
    ├── name: string
    ├── phone: string
    ├── createdAt: timestamp
    ├── updatedAt: timestamp
    └── profileImage: string (optional)
```

#### 2. Children Collection
```
children/
├── {childId}/
    ├── name: string
    ├── age: number
    ├── parentId: string (reference)
    ├── deviceId: string
    ├── createdAt: timestamp
    ├── updatedAt: timestamp
    └── profileImage: string (optional)
```

#### 3. ParentChildLink Collection
```
parentChildLinks/
├── {linkId}/
    ├── parentId: string
    ├── childId: string
    ├── linkStatus: string (active/inactive)
    ├── createdAt: timestamp
    └── permissions: map
```

#### 4. Activity_Log Collection
```
activityLogs/
├── {logId}/
    ├── childId: string
    ├── activityType: string
    ├── appName: string
    ├── websiteUrl: string (optional)
    ├── duration: number
    ├── timestamp: timestamp
    ├── screenTime: number
    └── location: geopoint (optional)
```

#### 5. Warnings Collection
```
warnings/
├── {warningId}/
    ├── childId: string
    ├── parentId: string
    ├── warningType: string
    ├── message: string
    ├── severity: string (low/medium/high)
    ├── isRead: boolean
    ├── createdAt: timestamp
    └── resolvedAt: timestamp (optional)
```

#### 6. Notifications Collection
```
notifications/
├── {notificationId}/
    ├── parentId: string
    ├── childId: string
    ├── title: string
    ├── message: string
    ├── type: string
    ├── isRead: boolean
    ├── createdAt: timestamp
    └── data: map (additional data)
```

#### 7. Devices Collection
```
devices/
├── {deviceId}/
    ├── childId: string
    ├── deviceName: string
    ├── deviceType: string (android/ios)
    ├── osVersion: string
    ├── lastSeen: timestamp
    ├── isActive: boolean
    └── fcmToken: string
```

## Project Structure

```
alaguard_app/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── colors.dart
│   │   │   └── strings.dart
│   │   ├── services/
│   │   │   ├── firebase_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   ├── notification_service.dart
│   │   │   └── storage_service.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── helpers.dart
│   │   │   └── date_utils.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── custom_text_field.dart
│   │       ├── loading_widget.dart
│   │       └── error_widget.dart
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   └── widgets/
│   │   │       └── auth_form.dart
│   │   ├── dashboard/
│   │   │   ├── models/
│   │   │   │   └── dashboard_model.dart
│   │   │   ├── providers/
│   │   │   │   └── dashboard_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── parent_dashboard.dart
│   │   │   │   └── child_dashboard.dart
│   │   │   └── widgets/
│   │   │       ├── activity_card.dart
│   │   │       └── stats_widget.dart
│   │   ├── monitoring/
│   │   │   ├── models/
│   │   │   │   ├── activity_model.dart
│   │   │   │   └── monitoring_model.dart
│   │   │   ├── providers/
│   │   │   │   └── monitoring_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── activity_monitor_screen.dart
│   │   │   │   ├── app_usage_screen.dart
│   │   │   │   └── web_history_screen.dart
│   │   │   └── widgets/
│   │   │       ├── activity_list.dart
│   │   │       └── usage_chart.dart
│   │   ├── notifications/
│   │   │   ├── models/
│   │   │   │   ├── notification_model.dart
│   │   │   │   └── warning_model.dart
│   │   │   ├── providers/
│   │   │   │   └── notification_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── notifications_screen.dart
│   │   │   │   └── warnings_screen.dart
│   │   │   └── widgets/
│   │   │       ├── notification_tile.dart
│   │   │       └── warning_card.dart
│   │   ├── profile/
│   │   │   ├── models/
│   │   │   │   ├── parent_model.dart
│   │   │   │   └── child_model.dart
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── parent_profile_screen.dart
│   │   │   │   ├── child_profile_screen.dart
│   │   │   │   └── add_child_screen.dart
│   │   │   └── widgets/
│   │   │       ├── profile_card.dart
│   │   │       └── child_card.dart
│   │   └── settings/
│   │       ├── models/
│   │       │   └── settings_model.dart
│   │       ├── providers/
│   │       │   └── settings_provider.dart
│   │       ├── screens/
│   │       │   ├── settings_screen.dart
│   │       │   ├── privacy_settings_screen.dart
│   │       │   └── notification_settings_screen.dart
│   │       └── widgets/
│   │           └── settings_tile.dart
│   └── routes/
│       ├── app_routes.dart
│       └── route_generator.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── firebase.json
```

## Required Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_messaging: ^14.7.10
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  
  # State Management
  provider: ^6.1.1
  
  # UI Components
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Utilities
  shared_preferences: ^2.2.2
  connectivity_plus: ^5.0.2
  permission_handler: ^11.1.0
  device_info_plus: ^9.1.1
  package_info_plus: ^4.2.0
  
  # Charts and Analytics
  fl_chart: ^0.65.0
  
  # Date and Time
  intl: ^0.19.0
  
  # Image Handling
  image_picker: ^1.0.4
  
  # HTTP Requests
  http: ^1.1.2
  
  # Local Notifications
  flutter_local_notifications: ^16.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Development Setup Steps

### 1. Environment Setup
```bash
# Install Flutter SDK
# Download from https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor

# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login
```

### 2. Project Creation
```bash
# Create Flutter project
flutter create alaguard_app
cd alaguard_app

# Initialize Firebase
firebase init

# Add Firebase configuration
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_messaging
```

### 3. Firebase Configuration
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

### 4. Android Configuration
- Add internet permission in `android/app/src/main/AndroidManifest.xml`
- Configure Firebase in `android/app/build.gradle`
- Add multidex support

### 5. iOS Configuration
- Configure Firebase in `ios/Runner/Info.plist`
- Add necessary permissions for camera, location, etc.

## Key Features Implementation

### 1. Authentication System
- Parent registration and login
- Child account linking
- Password reset functionality
- Biometric authentication (optional)

### 2. Activity Monitoring
- App usage tracking
- Website visit monitoring
- Screen time analysis
- Real-time activity logging

### 3. Notification System
- Push notifications for warnings
- In-app notifications
- Customizable notification settings
- Emergency alerts

### 4. Dashboard & Analytics
- Parent dashboard with child activities
- Usage statistics and charts
- Weekly/monthly reports
- Activity trends analysis

### 5. Parental Controls
- App blocking/allowing
- Time restrictions
- Content filtering
- Location tracking

## Security Considerations

1. **Data Encryption**: All sensitive data encrypted in transit and at rest
2. **Authentication**: Multi-factor authentication for parents
3. **Privacy**: Compliance with child privacy laws (COPPA)
4. **Permissions**: Minimal required permissions
5. **Secure Communication**: HTTPS/TLS for all communications

## Testing Strategy

### Unit Tests
- Model validation
- Service layer testing
- Utility function testing

### Integration Tests
- Firebase integration
- Authentication flow
- Data synchronization

### Widget Tests
- UI component testing
- User interaction testing
- Screen navigation testing

## Deployment Process

### Android
1. Build release APK/AAB
2. Sign with release keystore
3. Upload to Google Play Console
4. Configure app signing and security

### iOS
1. Build for iOS release
2. Archive and upload to App Store Connect
3. Configure app metadata
4. Submit for review

## Development Timeline Estimate

- **Week 1-2**: Project setup, Firebase configuration, basic authentication
- **Week 3-4**: Core UI development, navigation setup
- **Week 5-6**: Activity monitoring implementation
- **Week 7-8**: Notification system development
- **Week 9-10**: Dashboard and analytics
- **Week 11-12**: Testing, bug fixes, and deployment preparation

## Tools and IDEs

### Recommended: Android Studio
- Better Android development support
- Built-in emulator
- Excellent debugging tools
- Firebase integration

### Alternative: Visual Studio Code
- Lightweight and fast
- Excellent Flutter extensions
- Good for cross-platform development
- Great Git integration

## Version Control with GitHub

```bash
# Initialize Git repository
git init

# Add remote repository
git remote add origin https://github.com/yourusername/alaguard-app.git

# Create .gitignore for Flutter
# (Flutter automatically generates this)

# Commit and push
git add .
git commit -m "Initial commit"
git push -u origin main
```

## Additional Considerations

1. **Scalability**: Design for multiple children per parent
2. **Offline Support**: Cache critical data locally
3. **Performance**: Optimize for low-end devices
4. **Accessibility**: Support for users with disabilities
5. **Internationalization**: Multi-language support
6. **Analytics**: Track app usage and user behavior

This comprehensive guide provides the foundation for building your AlaGuard digital parenting app. The modular structure allows for incremental development and easy maintenance.
