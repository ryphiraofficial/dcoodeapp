import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Appearance'),
            _buildSettingCard(
              children: [
                SwitchListTile(
                  value: isDark,
                  onChanged: (val) => themeProvider.toggleTheme(),
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: const Text('Enable dark theme for the interface', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.dark_mode_outlined, color: Colors.black, size: 20),
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Account'),
            _buildSettingCard(
              children: [
                _buildListTile(
                  title: 'Notification Settings',
                  icon: Icons.notifications_outlined,
                  onTap: () {},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildListTile(
                  title: 'Privacy & Security',
                  icon: Icons.security_outlined,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('System'),
            _buildSettingCard(
              children: [
                _buildListTile(
                  title: 'About Dcoode',
                  icon: Icons.info_outline,
                  onTap: () {},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildListTile(
                  title: 'Check for Updates',
                  icon: Icons.system_update_outlined,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildLogoutButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.read<AuthProvider>().logout(),
      icon: const Icon(Icons.logout_outlined, size: 20),
      label: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF5252), // Red Accent
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
