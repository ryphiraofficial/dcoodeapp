import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../constants.dart';
import '../../widgets/app_logo.dart';
import '../../settings_screen.dart';

import 'profile_screen.dart';
import 'my_college_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'certifications_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchMyProfile();
    });
  }

  final List<Widget> _screens = [
    const StudentProfileScreen(),
    const StudentMyCollegeScreen(),
    const StudentTimetableScreen(),
    const StudentAttendanceScreen(),
    const StudentCertificationsScreen(), // Index 4
    const SettingsScreen(), // Index 5
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.menu_outlined),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'DCOODE STUDENT',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
        ),
        actions: [
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            color: Colors.white,
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Text(
                authProvider.user?.name[0] ?? 'S',
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            onSelected: (value) {
              if (value == 0) setState(() => _currentIndex = 0); // Profile
              if (value == 1) setState(() => _currentIndex = 5); // Settings
              if (value == 2) authProvider.logout(); // Logout
            },
            itemBuilder: (context) => [
              _buildPopupItem(0, Icons.person_outline, 'My Profile'),
              _buildPopupItem(1, Icons.settings_outlined, 'Settings'),
              const PopupMenuDivider(height: 1),
              _buildPopupItem(2, Icons.logout, 'Logout', isDestructive: true),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildStudentSidebar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.account_circle_outlined, 0),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.school_outlined, 1),
            label: 'College',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.calendar_today_outlined, 2),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.assignment_turned_in_outlined, 3),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSidebar() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLogo(),
                const SizedBox(height: 8),
                const Text(
                  'STUDENT PORTAL',
                  style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(Icons.person_outline, 'My Profile', 0),
                _buildDrawerItem(Icons.school_outlined, 'My College', 1),
                _buildDrawerItem(Icons.calendar_month_outlined, 'My Timetable', 2),
                _buildDrawerItem(Icons.assignment_turned_in_outlined, 'My Attendance', 3),
                _buildDrawerItem(Icons.verified_outlined, 'My Certifications', 4),
                const Divider(height: 32),
                _buildDrawerItem(Icons.settings_outlined, 'App Settings', 5),
                _buildDrawerItem(Icons.help_outline, 'Help & Support', -1),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextButton.icon(
              onPressed: () => context.read<AuthProvider>().logout(),
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
              label: const Text('LOGOUT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.black : Colors.black54, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.black87,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        if (index != -1) {
          setState(() => _currentIndex = index);
        }
        Navigator.pop(context); // Close drawer
      },
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
    );
  }
}
