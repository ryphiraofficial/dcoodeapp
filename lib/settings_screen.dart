import 'package:flutter/material.dart';
import 'constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              const Text('SYSTEM CONFIG', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              const Text('Settings', style: AppTextStyles.heading1),
              const SizedBox(height: 32),
              _buildSettingsGroup('GENERAL', [
                _buildSettingsTile(Icons.language_outlined, 'Language', 'English (US)'),
                _buildSettingsTile(Icons.dark_mode_outlined, 'Dark Mode', 'System Default', hasToggle: true),
                _buildSettingsTile(Icons.storage_outlined, 'Storage & Data', '34% used'),
              ]),
              const SizedBox(height: 32),
              _buildSettingsGroup('SECURITY', [
                _buildSettingsTile(Icons.fingerprint, 'Biometric Lock', 'Enabled', hasToggle: true),
                _buildSettingsTile(Icons.vpn_key_outlined, 'Session Management', '2 active devices'),
                _buildSettingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', ''),
              ]),
              const SizedBox(height: 32),
              _buildSettingsGroup('NOTIFICATIONS', [
                _buildSettingsTile(Icons.mail_outline, 'Email Reports', 'Weekly', hasToggle: true),
                _buildSettingsTile(Icons.notifications_active_outlined, 'Critical Alerts', 'Enabled', hasToggle: true),
              ]),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'DCOODE SYSTEMS v1.0.42\nBuild 8922-A',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 10, height: 1.5),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String value, {bool hasToggle = false}) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(width: 8),
          if (hasToggle)
            Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withAlpha(76),
            )
          else
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
