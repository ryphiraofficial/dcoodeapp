import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
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

    if (staffProvider.isLoading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: staffProvider.fetchDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryGrid(data.summary),
              const SizedBox(height: 24),
              const Text(
                'Today\'s Classes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...data.todaysClasses.map((e) => _buildClassCard(e)),
              const SizedBox(height: 24),
              const Text(
                'Recent Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...data.recentStudents.map((e) => _buildStudentTile(e)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(dynamic summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard('Colleges', summary.totalColleges.toString(), Icons.school),
        _buildSummaryCard('Courses', summary.totalCourses.toString(), Icons.book),
        _buildSummaryCard('Batches', summary.totalBatches.toString(), Icons.group),
        _buildSummaryCard('Students', summary.totalStudents.toString(), Icons.people),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildClassCard(dynamic classEntry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.class_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(classEntry.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${classEntry.startTime} - ${classEntry.endTime} | ${classEntry.classroom}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(classEntry.faculty, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStudentTile(dynamic student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            student.fullName.isNotEmpty ? student.fullName[0] : '?',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(student.studentId),
        trailing: const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }
}
