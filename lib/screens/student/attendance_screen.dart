import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchMyAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final attendance = studentProvider.myAttendance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: studentProvider.isLoading && attendance.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : attendance.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildSummaryCard(attendance),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => studentProvider.fetchMyAttendance(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: attendance.length,
                          itemBuilder: (context, index) {
                            final record = attendance[index];
                            return _buildAttendanceCard(record);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard(List<dynamic> records) {
    int present = records.where((r) => r.status == 'Present').length;
    int absent = records.where((r) => r.status == 'Absent').length;
    int total = records.length;
    double percentage = total > 0 ? (present / total) * 100 : 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Present', present.toString(), Colors.greenAccent),
          _buildSummaryItem('Absent', absent.toString(), Colors.redAccent),
          _buildSummaryItem('Attendance', '${percentage.toStringAsFixed(1)}%', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No attendance records found', style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic record) {
    final df = DateFormat('EEEE, MMM dd, yyyy');
    Color statusColor;
    switch (record.status) {
      case 'Present':
        statusColor = Colors.green;
        break;
      case 'Absent':
        statusColor = Colors.red;
        break;
      case 'Late':
        statusColor = Colors.orange;
        break;
      case 'Leave':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(df.format(record.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Marked by: ${record.markedBy}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record.status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
