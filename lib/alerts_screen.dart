import 'package:flutter/material.dart';
import 'constants.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alerts', style: AppTextStyles.heading1),
                    SizedBox(height: 4),
                    Text('Manage your system updates and\nproject activity.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.done_all, size: 16),
                      SizedBox(width: 8),
                      Text('Mark all\nas read', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildFilterTab('All', isActive: true),
                const SizedBox(width: 8),
                _buildFilterTab('Unread'),
                const SizedBox(width: 8),
                _buildFilterTab('Projects'),
                const SizedBox(width: 8),
                _buildFilterTab('System'),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('TODAY'),
            _buildAlertItem(
              icon: Icons.flag_outlined,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: Colors.green,
              title: 'Project Milestone Reached',
              time: '2h ago',
              description: 'Version 2.4.0-rc has passed all automated integration tests. Deployment to production is ready for approval.',
              buttonLabel: 'View Report',
            ),
            _buildAlertItem(
              avatarUrl: 'https://placeholder.com/150',
              title: 'New Message from Lead Developer',
              time: '4h ago',
              description: '"Hey, I\'ve reviewed your latest PR for the data visualization module. Great work on the memory optimization."',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('YESTERDAY'),
            _buildAlertItem(
              icon: Icons.settings_outlined,
              iconBgColor: const Color(0xFFF5F5F5),
              iconColor: Colors.grey,
              title: 'System Update Complete',
              time: '1d ago',
              description: 'The dcoode environment has been updated to build 8922. Performance improvements for large-scale Git repositories are now active.',
            ),
            _buildAlertItem(
              icon: Icons.security_outlined,
              iconBgColor: const Color(0xFFFFEBEE),
              iconColor: Colors.red,
              title: 'Security Alert',
              time: '1d ago',
              description: 'A new login was detected from a new device in San Francisco, CA. If this wasn\'t you, please secure your account immediately.',
              buttonLabel: 'Manage Devices',
            ),
            const SizedBox(height: 40),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildTeamActivityCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF33691E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildAlertItem({
    IconData? icon,
    Color? iconBgColor,
    Color? iconColor,
    String? avatarUrl,
    required String title,
    required String time,
    required String description,
    String? buttonLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (avatarUrl != null)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            )
          else if (icon != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4)),
                if (buttonLabel != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(buttonLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVE SERVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text('All systems operational', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildServiceItem('API Gateway', '99.9% uptime'),
          const SizedBox(height: 12),
          _buildServiceItem('Build Pipeline', 'Active'),
          const SizedBox(height: 12),
          _buildServiceItem('Data Store', 'Latency: 12ms'),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        Text(status, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTeamActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBE7),
        border: Border.all(color: AppColors.primary.withAlpha(76)), // 0.3 opacity approx 76/255
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TEAM ACTIVITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          const Text('12', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const Text('Active discussions in \'Portfolio-UI\'', style: TextStyle(fontSize: 12, color: Colors.black54)),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.group_outlined, color: Colors.grey[300], size: 48),
          ),
        ],
      ),
    );
  }
}
