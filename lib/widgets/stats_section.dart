import 'package:flutter/material.dart';
import '../constants.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.darkBackground,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          _buildStatItem('124+', 'SYSTEMS DEPLOYED'),
          const Divider(color: Colors.white10, height: 40),
          _buildStatItem('99.9%', 'UPTIME STABILITY'),
          const Divider(color: Colors.white10, height: 40),
          _buildStatItem('14ms', 'AVG. LATENCY'),
          const Divider(color: Colors.white10, height: 40),
          _buildStatItem('24/7', 'ACTIVE MONITORING'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statValue),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }
}
