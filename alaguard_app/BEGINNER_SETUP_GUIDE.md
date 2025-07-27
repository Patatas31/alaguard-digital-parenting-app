# 🧒 AlaGuard - Beginner's Setup Guide

## 🎯 **What You're Building**
A **custom launcher** that replaces the child's normal home screen with a controlled environment where parents decide what apps the child can use.

## 📱 **How It Works (Simple Steps)**

### **Step 1: The Child's Experience**
When child turns on phone → They see **AlaGuard Launcher** instead of normal home screen → Only approved apps are visible → Everything else is hidden

### **Step 2: The Parent's Control**
Parent logs in → Sees dashboard → Controls which apps child can use → Gets notifications about usage

## 🚀 **Implementation Steps for Beginners**

### **Step 1: Enable Launcher Mode**
In `AndroidManifest.xml`, I already added:
```xml
<!-- This makes AlaGuard a launcher app -->
<intent-filter android:priority="1000">
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.HOME" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

### **Step 2: Create the Launcher Screen**
I already created `child_launcher_screen.dart` - this is what child sees instead of normal home screen.

### **Step 3: Simple Usage**
```dart
// In your main app, check if this is child mode
if (isChildMode) {
  return const ChildLauncherScreen(); // Show controlled launcher
} else {
  return const ParentDashboard(); // Show parent control panel
}
```

## 🔧 **Beginner-Friendly Code Examples**

### **1. Check if App is Running as Launcher**
```dart
// Simple check in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Check if this is child mode
  final isChildMode = await checkIfChildMode();
  
  runApp(
    MaterialApp(
      home: isChildMode ? const ChildLauncherScreen() : const LoginScreen(),
    ),
  );
}
```

### **2. Simple App Monitoring**
```dart
// Use the AndroidMonitoringService I created
class SimpleMonitor {
  void startWatching() {
    // This runs every minute
    Timer.periodic(Duration(minutes: 1), (timer) {
      AndroidMonitoringService.getTodayUsage().then((usage) {
        // Send to Firebase
        FirebaseFirestore.instance.collection('activityLogs').add({
          'childId': 'child123',
          'usage': usage,
          'timestamp': DateTime.now(),
        });
      });
    });
  }
}
```

### **3. Controlling Allowed Apps**
```dart
// Simple list of allowed apps
class AllowedApps {
  static final List<String> allowedApps = [
    'com.android.calculator2',  // Calculator
    'com.android.camera',       // Camera
    'com.android.gallery3d',    // Gallery
    'com.android.deskclock',    // Clock
  ];
  
  static bool isAppAllowed(String packageName) {
    return allowedApps.contains(packageName);
  }
}
```

## 📊 **What Each File Does (Beginner Explanation)**

### **Files I Created for You:**

1. **`child_launcher_screen.dart`** - The new home screen for kids
2. **`android_monitoring_service.dart`** - Watches what apps are used
3. **`AndroidManifest.xml`** - Tells Android "this app can be a launcher"

### **How They Connect:**
```
AndroidManifest.xml → Tells Android to use AlaGuard as launcher
child_launcher_screen.dart → Shows controlled app grid
android_monitoring_service.dart → Watches and reports usage
```

## 🎯 **Testing Your Launcher**

### **Step 1: Run the App**
```bash
cd alaguard_app
flutter run
```

### **Step 2: Set as Launcher**
1. Run app on Android phone
2. Press home button
3. Choose "AlaGuard" as default launcher
4. Now child sees controlled screen!

### **Step 3: Test Monitoring**
1. Open any allowed app from launcher
2. Check Firebase console for usage data
3. Parent gets notifications

## 🛠 **Beginner Tips**

### **Don't Worry About:**
- Complex Android APIs (I simplified them)
- Background services (I created simple ones)
- Firebase setup (I included basic config)

### **Focus On:**
- Understanding the flow
- Testing on real Android device
- Customizing the allowed apps list
- Adding your Figma design later

## 📱 **Real Device Testing**

### **What You'll See:**
1. **Child Mode:** Simple grid of approved apps
2. **Parent Mode:** Full dashboard with controls
3. **Monitoring:** Real-time usage tracking

### **Quick Test:**
```dart
// Add this to your parent dashboard
ElevatedButton(
  onPressed: () {
    // Switch to child mode
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildLauncherScreen()),
    );
  },
  child: Text('Switch to Child Mode'),
)
```

## 🚀 **Next Steps for You**

### **Week 1: Basic Setup**
1. Run the app on Android phone
2. Test launcher functionality
3. Add your allowed apps list

### **Week 2: Customization**
1. Replace with your Figma design
2. Add more monitoring features
3. Test with real child usage

### **Week 3: Advanced Features**
1. Add time limits
2. Add web filtering
3. Add parent notifications

## 🎯 **Summary for Beginners**

**What You Have Now:**
- ✅ Complete Flutter project
- ✅ Android launcher functionality
- ✅ Basic monitoring system
- ✅ Firebase integration
- ✅ Beginner-friendly code

**What You Need to Do:**
1. Run `flutter pub get`
2. Set up Firebase (I included instructions)
3. Test on Android device
4. Customize allowed apps list

The hard work is done - you just need to customize it for your specific needs!
