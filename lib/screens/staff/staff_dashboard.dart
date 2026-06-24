import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final data = staffProvider.dashboardData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => staffProvider.fetchDashboard(),
        child: staffProvider.isLoading && data == null
            ? const Center(child: CircularProgressIndicator())
            : data == null
                ? const Center(child: Text('Failed to load dashboard data'))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 24),
                        _buildStatsGrid(data.summary),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Today\'s Classes', Icons.calendar_today),
                        const SizedBox(height: 16),
                        _buildClassesList(data.todaysClasses),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Recent Students', Icons.people_outline),
                        const SizedBox(height: 16),
                        _buildRecentStudents(data.recentStudents),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back,',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const Text(
          'Administrator',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(dynamic summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Colleges', summary.totalColleges.toString(), Icons.school, Colors.blue),
        _buildStatCard('Courses', summary.totalCourses.toString(), Icons.book, Colors.orange),
        _buildStatCard('Batches', summary.totalBatches.toString(), Icons.group, Colors.purple),
        _buildStatCard('Students', summary.totalStudents.toString(), Icons.people, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildClassesList(List<dynamic> classes) {
    if (classes.isEmpty) {
      return _buildEmptyState('No classes scheduled for today');
    }
    return Column(
      children: classes.map((c) => _buildClassTile(c)).toList(),
    );
  }

  Widget _buildClassTile(dynamic classEntry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                classEntry.startTime,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Icon(Icons.arrow_downward, size: 12, color: Colors.grey),
              Text(
                classEntry.endTime,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Container(width: 1, height: 40, color: AppColors.border),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classEntry.subject,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${classEntry.faculty} | ${classEntry.classroom}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentStudents(List<dynamic> students) {
    if (students.isEmpty) {
      return _buildEmptyState('No recent students found');
    }
    return Column(
      children: students.map((s) => _buildStudentItem(s)).toList(),
    );
  }

  Widget _buildStudentItem(dynamic student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            student.fullName.isNotEmpty ? student.fullName[0] : '?',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(student.studentId, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
