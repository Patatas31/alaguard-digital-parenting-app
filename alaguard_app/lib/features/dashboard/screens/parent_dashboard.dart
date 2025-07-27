import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

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
        title: const Text(AppStrings.dashboard),
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
                    '${AppStrings.welcomeBack}, ${dashboardProvider.parentName}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 24),

                  // Children list
                  Text(
                    AppStrings.yourChildren,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  if (dashboardProvider.children.isEmpty)
                    _buildEmptyState()
                  else
                    _buildChildrenList(dashboardProvider.children),
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

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Children',
            value: '0',
            icon: Icons.child_care,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Active Alerts',
            value: '0',
            icon: Icons.warning,
            color: AppColors.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
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
              AppStrings.noChildrenAdded,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(AppStrings.addFirstChild),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-child');
              },
              child: const Text(AppStrings.addChild),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenList(List<Map<String, dynamic>> children) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return _buildChildCard(child);
      },
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            (child['name'] as String? ?? 'C')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(child['name'] ?? 'Unknown'),
        subtitle: Text('Age: ${child['age'] ?? 'Unknown'}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: const Text('View Profile'),
            ),
            PopupMenuItem(
              value: 'monitor',
              child: const Text('Activity Monitor'),
            ),
            PopupMenuItem(
              value: 'remove',
              child: const Text('Remove'),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                Navigator.pushNamed(
                  context,
                  '/child-profile',
                  arguments: {'childId': child['id']},
                );
                break;
              case 'monitor':
                Navigator.pushNamed(
                  context,
                  '/activity-monitor',
                  arguments: {'childId': child['id']},
                );
                break;
              case 'remove':
                _showRemoveChildDialog(child);
                break;
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/child-profile',
            arguments: {'childId': child['id']},
          );
        },
      ),
    );
  }

  void _showRemoveChildDialog(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Child'),
        content: Text('Are you sure you want to remove ${child['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<DashboardProvider>(context, listen: false)
                  .removeChild(child['id']);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
