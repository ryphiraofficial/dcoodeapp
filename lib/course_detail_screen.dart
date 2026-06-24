import 'package:flutter/material.dart';
import 'models/course.dart';
import 'constants.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          course.track.toUpperCase(),
          style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Track Overview'),
                  const SizedBox(height: 16),
                  Text(course.overview, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Key Technologies & Skills'),
                  const SizedBox(height: 16),
                  _buildTechGrid(),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Syllabus & Internship Roadmap'),
                  const SizedBox(height: 24),
                  ...course.syllabus.map((s) => _buildSyllabusItem(s)),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Who is this for?'),
                  const SizedBox(height: 16),
                  ...course.whoIsThisFor.map((w) => _buildBulletPoint(w)),
                  const SizedBox(height: 40),
                  _buildEnrollmentCard(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F7F2),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
            ),
            child: Icon(course.icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(course.title, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.1)),
          const SizedBox(height: 16),
          Text(course.description, style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBadge(Icons.timer_outlined, course.duration),
              const SizedBox(width: 12),
              _buildBadge(Icons.verified_outlined, 'Certified'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(width: 40, height: 2, color: AppColors.primary),
      ],
    );
  }

  Widget _buildTechGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: course.technologies.map((tech) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(tech, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
      )).toList(),
    );
  }

  Widget _buildSyllabusItem(SyllabusMonth s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                child: Center(child: Text(s.month.split(' ')[1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              Container(width: 2, height: 80, color: AppColors.border),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(s.description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 12),
                ...s.points.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(p, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildEnrollmentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inquire for Enrollment', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInquireItem(Icons.verified_user_outlined, 'Verified course certificate'),
          _buildInquireItem(Icons.people_outline, 'Talent network placement support'),
          _buildInquireItem(Icons.work_outline, 'Hands-on industrial projects'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CONTACT ADMISSIONS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInquireItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
