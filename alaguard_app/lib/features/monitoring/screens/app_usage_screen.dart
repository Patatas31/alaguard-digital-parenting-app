import 'package:flutter/material.dart';

class AppUsageScreen extends StatelessWidget {
  final String childId;

  const AppUsageScreen({
    Key? key,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Usage'),
      ),
      body: const Center(
        child: Text('App Usage Screen - Coming Soon'),
      ),
    );
  }
}
