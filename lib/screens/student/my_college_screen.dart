import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class StudentMyCollegeScreen extends StatelessWidget {
  const StudentMyCollegeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<StudentProvider>().profile;

    if (profile == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<StudentProvider>().fetchMyProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildCollegeHeader(profile.college),
            const SizedBox(height: 32),
            _buildInfoSection('Course Information', [
              _buildDetailRow(Icons.book_outlined, 'Course Name', profile.course?.name ?? 'N/A'),
              _buildDetailRow(Icons.code, 'Course Code', profile.course?.code ?? 'N/A'),
            ]),
            const SizedBox(height: 24),
            _buildInfoSection('Batch Details', [
              _buildDetailRow(Icons.groups_outlined, 'Batch Name', profile.batch?.name ?? 'N/A'),
              _buildDetailRow(Icons.timer_outlined, 'Batch Duration', profile.batch?.duration ?? 'N/A'),
              if (profile.batch?.startDate != null)
                _buildDetailRow(Icons.event_available, 'Start Date', DateFormat('MMM dd, yyyy').format(profile.batch!.startDate!)),
              if (profile.batch?.endDate != null)
                _buildDetailRow(Icons.event_busy, 'End Date', DateFormat('MMM dd, yyyy').format(profile.batch!.endDate!)),
            ]),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCollegeHeader(dynamic college) {
    if (college == null) return const Text('College info not found');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: college.logo != null
                ? CachedNetworkImage(imageUrl: college.logo!, fit: BoxFit.cover)
                : const Icon(Icons.school, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(college.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(college.code, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          if (college.address != null) ...[
            const SizedBox(height: 12),
            Text(college.address!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
