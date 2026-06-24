import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final profile = studentProvider.profile;

    if (studentProvider.isLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return const Center(child: Text('Profile not found'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => studentProvider.fetchMyProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            const SizedBox(height: 20),
            _buildProfileHeader(profile),
            const SizedBox(height: 32),
            _buildInfoCard('Personal Information', [
              _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
              _buildInfoRow(Icons.phone_outlined, 'Phone', profile.phone ?? 'Not provided'),
              _buildInfoRow(Icons.location_on_outlined, 'Address', profile.address ?? 'Not provided'),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Academic Information', [
              _buildInfoRow(Icons.school_outlined, 'College', profile.college?.name ?? 'N/A'),
              _buildInfoRow(Icons.book_outlined, 'Course', profile.course?.name ?? 'N/A'),
              _buildInfoRow(Icons.group_outlined, 'Batch', profile.batch?.name ?? 'N/A'),
              _buildInfoRow(Icons.badge_outlined, 'Student ID', profile.studentId),
            ]),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to Edit Profile
              },
              icon: const Icon(Icons.edit),
              label: const Text('EDIT PROFILE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: profile.photo != null
                    ? CachedNetworkImage(
                        imageUrl: profile.photo,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(Icons.person, size: 60, color: Colors.grey),
                        errorWidget: (context, url, error) => const Icon(Icons.person, size: 60, color: Colors.grey),
                      )
                    : const Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          profile.studentId,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
