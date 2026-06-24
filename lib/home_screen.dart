import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'widgets/home_view.dart';
import 'courses_screen.dart';
import 'alerts_screen.dart';
import 'services_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'activity_log_screen.dart';
import 'widgets/app_logo.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      const HomeView(),
      const CoursesScreen(),
      ServicesScreen(onLogoTap: () => setState(() => _currentIndex = 0)),
      const AlertsScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
      const ActivityLogScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: _currentIndex < 4 
          ? const AppLogo(
              fontSize: 18,
              capsuleWidth: 32,
              capsuleHeight: 16,
              borderThickness: 3,
            )
          : Text(
              _currentIndex == 4 ? 'PROFILE' : (_currentIndex == 5 ? 'SETTINGS' : 'ACTIVITY LOG'),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
            ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            color: Colors.white,
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
            onSelected: (value) {
              if (value == 0) setState(() => _currentIndex = 4);
              if (value == 1) setState(() => _currentIndex = 5);
              if (value == 2) setState(() => _currentIndex = 6);
              if (value == 3) {
                if (isAuthenticated) {
                  authProvider.logout();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              _buildPopupItem(0, Icons.person_outline, 'Profile'),
              _buildPopupItem(1, Icons.settings_outlined, 'Settings'),
              _buildPopupItem(2, Icons.history, 'Activity Log'),
              const PopupMenuDivider(height: 1),
              if (isAuthenticated)
                _buildPopupItem(3, Icons.logout, 'Logout', isDestructive: true)
              else
                _buildPopupItem(3, Icons.login, 'Login'),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildSidebar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex < 4 ? _currentIndex : 0,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.home_outlined, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.school_outlined, 1),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.design_services_outlined, 2),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.notifications_outlined, 3),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLogo(),
                SizedBox(height: 8),
                Text(
                  'PRECISION INTERFACE v1.0',
                  style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home_outlined, 'Dashboard', 0),
                _buildDrawerItem(Icons.school_outlined, 'Courses', 1),
                _buildDrawerItem(Icons.design_services_outlined, 'Our Services', 2),
                _buildDrawerItem(Icons.notifications_outlined, 'Alerts', 3),
                _buildDrawerItem(Icons.person_outline, 'Profile', 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Divider(color: AppColors.border),
                ),
                _buildDrawerItem(Icons.description_outlined, 'Documentation', -1),
                _buildDrawerItem(Icons.support_agent_outlined, 'Technical Support', -1),
                _buildDrawerItem(Icons.settings_outlined, 'System Settings', -1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.black87, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.black87,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (index != -1) {
          setState(() => _currentIndex = index);
          Navigator.pop(context); // Close drawer
        }
      },
      selected: isSelected,
      selectedTileColor: AppColors.primary.withAlpha(51),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  PopupMenuItem<int> _buildPopupItem(int value, IconData icon, String title, {bool isDestructive = false}) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDestructive ? Colors.redAccent : Colors.black87),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDestructive ? Colors.redAccent : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
