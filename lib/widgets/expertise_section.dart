import 'package:flutter/material.dart';
import '../constants.dart';

class ExpertiseSection extends StatelessWidget {
  const ExpertiseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text('EXPERTISE', style: AppTextStyles.heading2),
        ),
        _buildExpertiseCard(
          title: 'Software Development',
          description: 'Custom-built enterprise architectures using high-concurrency frameworks and distributed system design.',
          actionText: 'DETAILS',
        ),
        _buildExpertiseCard(
          title: 'UI/UX Design',
          description: 'Precision interfaces built on systematic design tokens and technical clarity.',
          icon: Icons.edit_note,
        ),
        _buildExpertiseCard(
          title: 'Cloud Solutions',
          description: 'Scalable infrastructure management with 99.9% uptime guarantees.',
          icon: Icons.cloud_outlined,
        ),
        _buildExpertiseCard(
          title: 'AI Integration',
          description: 'Deploying large language models and predictive analytics into existing workflows for exponential productivity gains.',
          badge: 'NEW CAPABILITY',
          showLogo: true,
        ),
      ],
    );
  }

  Widget _buildExpertiseCard({
    required String title,
    required String description,
    String? actionText,
    IconData? icon,
    String? badge,
    bool showLogo = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 28),
            const SizedBox(height: 16),
          ],
          if (showLogo) ...[
             Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: AppColors.primary,
                 borderRadius: BorderRadius.circular(8),
               ),
             ),
            const SizedBox(height: 16),
          ],
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(description, style: AppTextStyles.subheading.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          if (actionText != null)
            Row(
              children: [
                Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
        ],
      ),
    );
  }
}
