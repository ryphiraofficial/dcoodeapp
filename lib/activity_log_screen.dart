import 'package:flutter/material.dart';
import 'constants.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ACTIVITY LOG', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              const Text('System Audit Trail', style: AppTextStyles.heading1),
              const SizedBox(height: 24),
              _buildLogSection('TODAY'),
              _buildActivityItem(
                icon: Icons.login_outlined,
                title: 'Security Login',
                subtitle: 'Chrome on MacOS • SF, USA',
                time: '2 hours ago',
                status: 'Authorized',
              ),
              _buildActivityItem(
                icon: Icons.upload_file_outlined,
                title: 'Production Deployment',
                subtitle: 'V2.4.1-stable • Cluster B',
                time: '5 hours ago',
                status: 'Success',
              ),
              const SizedBox(height: 32),
              _buildLogSection('YESTERDAY'),
              _buildActivityItem(
                icon: Icons.receipt_long_outlined,
                title: 'Billing Updated',
                subtitle: 'Card ending in 4242',
                time: 'Yesterday',
              ),
              _buildActivityItem(
                icon: Icons.person_add_outlined,
                title: 'Team Member Invited',
                subtitle: 'sarah.c@dcoode.sys',
                time: 'Yesterday',
              ),
              _buildActivityItem(
                icon: Icons.lock_reset_outlined,
                title: 'Password Changed',
                subtitle: 'Manual reset initiated',
                time: '2 days ago',
                status: 'Verified',
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    String? status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                if (status != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(4)),
                    child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
