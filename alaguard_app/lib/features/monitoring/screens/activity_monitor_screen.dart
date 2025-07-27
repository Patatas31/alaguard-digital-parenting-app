import 'package:flutter/material.dart';

class ActivityMonitorScreen extends StatelessWidget {
  final String childId;

  const ActivityMonitorScreen({
    Key? key,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Monitor'),
      ),
      body: const Center(
        child: Text('Activity Monitor Screen - Coming Soon'),
      ),
    );
  }
}
