import 'package:flutter/material.dart';
import '../constants.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FEATURED PROJECTS', style: AppTextStyles.heading2),
              Row(
                children: [
                  _buildNavButton(Icons.arrow_back),
                  const SizedBox(width: 8),
                  _buildNavButton(Icons.arrow_forward),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: Icon(Icons.analytics_outlined, color: Colors.white, size: 64),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FINTECH', style: TextStyle(fontSize: 12, color: Colors.grey[600], letterSpacing: 1.2)),
                  Text('2024', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Nova Trading Platform', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.black54),
    );
  }
}
