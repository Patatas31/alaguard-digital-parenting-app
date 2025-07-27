import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ChildProfileScreen extends StatelessWidget {
  final String childId;

  const ChildProfileScreen({
    Key? key,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profile'),
      ),
      body: const Center(
        child: Text('Child Profile Screen - Coming Soon'),
      ),
    );
  }
}
