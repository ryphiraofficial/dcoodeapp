import 'package:flutter/material.dart';
import 'constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 32),
            _buildAccountSecurityCard(),
            const SizedBox(height: 16),
            _buildBillingCard(),
            const SizedBox(height: 16),
            _buildNotificationPreferencesCard(),
            const SizedBox(height: 32),
            _buildSupportCenterCard(),
            const SizedBox(height: 40),
            _buildActivityLog(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.black,
                child: const Icon(Icons.person, color: AppColors.primary, size: 40),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('TECHNICAL LEAD', style: TextStyle(fontSize: 10, color: Color(0xFF33691E), fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('Alex River', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Product Manager at dcoode systems', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildAccountSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.grey),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(4)),
                child: const Text('Secure', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Account Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Manage your authentication methods, two-factor settings, and active session monitoring for maximum account protection.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Update Password', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('2FA Settings', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BILLING', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          const Text('Enterprise Tier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Next renewal: Oct 12, 2024', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 44),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Manage Subscription', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildToggleItem('Email Alerts', true),
          const Divider(height: 24),
          _buildToggleItem('Push Notifications', false),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Switch(
          value: value,
          onChanged: (v) {},
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withAlpha(76),
        ),
      ],
    );
  }

  Widget _buildSupportCenterCard() {
    return Column(
      children: [
        const Text('Support Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Need technical assistance with your deployment? Our engineers are available 24/7 for Enterprise customers.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Open Ticket', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Documentation', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLog() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECENT ACTIVITY LOG', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1)),
            Icon(Icons.history, size: 16, color: Colors.grey[500]),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          icon: Icons.login_outlined,
          title: 'Security Login',
          subtitle: 'Chrome on MacOS • SF, USA',
          time: '2 hours ago',
        ),
        const Divider(height: 1),
        _buildActivityItem(
          icon: Icons.receipt_long_outlined,
          title: 'Billing Updated',
          subtitle: 'Card ending in 4242',
          time: 'Yesterday',
        ),
      ],
    );
  }

  Widget _buildActivityItem({required IconData icon, required String title, required String subtitle, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}
