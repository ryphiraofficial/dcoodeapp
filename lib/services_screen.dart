import 'package:flutter/material.dart';
import 'constants.dart';

class ServicesScreen extends StatefulWidget {
  final VoidCallback? onLogoTap;
  const ServicesScreen({super.key, this.onLogoTap});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<ServiceData> _services = [
    ServiceData(
      title: 'Mobile App Development',
      description: 'NEXT-GEN NATIVE APPLICATIONS DESIGNED FOR SEAMLESS INTERACTION AND HIGH RETENTION RATES.',
      sector: '01',
      label: 'MOBILE',
      icon: Icons.phone_android_outlined,
    ),
    ServiceData(
      title: 'Custom Software Architect',
      description: 'BUILDING SCALABLE BACKEND ECOSYSTEMS THAT HANDLE COMPLEX DATA STREAMS WITH ZERO LATENCY.',
      sector: '02',
      label: 'CUSTOM',
      icon: Icons.code_outlined,
    ),
    ServiceData(
      title: 'Cloud Migration Strategy',
      description: 'SECURE AWS AND AZURE DEPLOYMENTS OPTIMIZED FOR PERFORMANCE AND COST-EFFICIENCY.',
      sector: '03',
      label: 'CLOUD',
      icon: Icons.cloud_queue_outlined,
    ),
    ServiceData(
      title: 'UI/UX Visual Engineering',
      description: 'DATA-DRIVEN DESIGN PROCESSES FOCUSED ON CONVERSION METRICS AND BRAND IDENTITY.',
      sector: '04',
      label: 'UI/UX',
      icon: Icons.draw_outlined,
    ),
    ServiceData(
      title: 'Cyber Resilience Systems',
      description: 'ADVANCED THREAT DETECTION AND ENCRYPTION PROTOCOLS TO SAFEGUARD ENTERPRISE ASSETS.',
      sector: '05',
      label: 'CYBER',
      icon: Icons.security_outlined,
    ),
    ServiceData(
      title: 'Web Development',
      description: 'NEXT-GEN NATIVE APPLICATIONS DESIGNED FOR SEAMLESS INTERACTION AND HIGH RETENTION RATES.',
      sector: '06',
      label: 'WEB',
      icon: Icons.language_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR SERVICES',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Engineering Excellence',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                return _buildServiceBox(_services[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBox(ServiceData service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Icon(service.icon, color: Colors.black, size: 24),
              ),
              Text(
                'SECTOR ${service.sector}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            service.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
                'LEARN MORE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: Colors.black, size: 10),
            ],
          ),
        ],
      ),
    );
  }

  IconData serviceIcon(int index) {
    return _services[index].icon;
  }
}

class ServiceData {
  final String title;
  final String description;
  final String sector;
  final String label;
  final IconData icon;

  ServiceData({
    required this.title,
    required this.description,
    required this.sector,
    required this.label,
    required this.icon,
  });
}
