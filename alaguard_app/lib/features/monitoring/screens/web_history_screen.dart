import 'package:flutter/material.dart';

class WebHistoryScreen extends StatelessWidget {
  final String childId;

  const WebHistoryScreen({
    Key? key,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web History'),
      ),
      body: const Center(
        child: Text('Web History Screen - Coming Soon'),
      ),
    );
  }
}
