import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({Key? key}) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _deviceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addChild),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Child',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your child\'s information to start monitoring their digital activities.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Child Name
              CustomTextField(
                controller: _nameController,
                label: AppStrings.childName,
                hint: 'Enter child\'s name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Child Age
              CustomTextField(
                controller: _ageController,
                label: AppStrings.childAge,
                hint: 'Enter child\'s age',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.cake_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child\'s age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 18) {
                    return 'Please enter a valid age (1-18)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Device Name (Optional)
              CustomTextField(
                controller: _deviceController,
                label: '${AppStrings.deviceName} (Optional)',
                hint: 'Enter device name',
                prefixIcon: const Icon(Icons.phone_android_outlined),
              ),
              const SizedBox(height: 32),

              // Add Child Button
              Consumer<DashboardProvider>(
                builder: (context, dashboardProvider, child) {
                  return PrimaryButton(
                    text: AppStrings.addChild,
                    isLoading: dashboardProvider.isLoading,
                    onPressed: _handleAddChild,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddChild() async {
    if (!_formKey.currentState!.validate()) return;

    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    
    await dashboardProvider.addChild(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      deviceId: _deviceController.text.trim().isEmpty ? null : _deviceController.text.trim(),
    );

    if (dashboardProvider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.childAdded),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dashboardProvider.errorMessage!),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _deviceController.dispose();
    super.dispose();
  }
}
