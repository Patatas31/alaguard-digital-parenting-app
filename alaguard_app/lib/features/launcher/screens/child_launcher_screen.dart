import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

class ChildLauncherScreen extends StatefulWidget {
  const ChildLauncherScreen({Key? key}) : super(key: key);

  @override
  State<ChildLauncherScreen> createState() => _ChildLauncherScreenState();
}

class _ChildLauncherScreenState extends State<ChildLauncherScreen> {
  // List of allowed apps for the child
  final List<Map<String, dynamic>> allowedApps = [
    {
      'name': 'Calculator',
      'icon': Icons.calculate,
      'package': 'com.android.calculator2',
      'color': AppColors.primaryColor,
    },
    {
      'name': 'Camera',
      'icon': Icons.camera_alt,
      'package': 'com.android.camera',
      'color': AppColors.secondaryColor,
    },
    {
      'name': 'Gallery',
      'icon': Icons.photo_library,
      'package': 'com.android.gallery3d',
      'color': AppColors.accentColor,
    },
    {
      'name': 'Clock',
      'icon': Icons.access_time,
      'package': 'com.android.deskclock',
      'color': AppColors.successColor,
    },
    {
      'name': 'Settings',
      'icon': Icons.settings,
      'package': 'com.android.settings',
      'color': AppColors.textSecondary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with time and battery
            _buildTopBar(),
            
            // Welcome message
            _buildWelcomeMessage(),
            
            // Allowed apps grid
            Expanded(
              child: _buildAppsGrid(),
            ),
            
            // Bottom bar with emergency button
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time display
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          
          // Battery and signal icons
          Row(
            children: [
              Icon(Icons.wifi, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Icon(Icons.battery_full, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Welcome, Child!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can only use approved apps',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: allowedApps.length,
      itemBuilder: (context, index) {
        final app = allowedApps[index];
        return _buildAppIcon(app);
      },
    );
  }

  Widget _buildAppIcon(Map<String, dynamic> app) {
    return GestureDetector(
      onTap: () => _launchApp(app['package']),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: app['color'],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              app['icon'],
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app['name'],
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Emergency button
          ElevatedButton.icon(
            onPressed: _showEmergencyDialog,
            icon: const Icon(Icons.emergency),
            label: const Text('Emergency'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
            ),
          ),
          
          // Settings button (for parents)
          ElevatedButton.icon(
            onPressed: _showParentAccess,
            icon: const Icon(Icons.settings),
            label: const Text('Parent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _launchApp(String packageName) {
    // This would launch the actual app
    // For now, we'll show a simple message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${packageName.split('.').last}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency'),
        content: const Text('Call parent or emergency services?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // This would actually call emergency
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency contact initiated')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showParentAccess() {
    // This would require parent password to exit launcher mode
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parent Access'),
        content: const Text('Enter parent password to exit launcher mode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // This would verify parent password
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/parent-dashboard');
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }
}
