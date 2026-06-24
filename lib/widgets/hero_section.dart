import 'package:flutter/material.dart';
import '../constants.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'EST. 2024',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: AppTextStyles.heading1,
              children: [
                const TextSpan(text: 'Transforming Ideas into '),
                TextSpan(
                  text: 'Digital Reality',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.green[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We engineer high-performance solutions for the modern technical landscape. Precision-driven, laboratory-tested, and developer-first.',
            style: AppTextStyles.subheading,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Row(
                  children: [
                    Text('Start a Project', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('View Dossier'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
