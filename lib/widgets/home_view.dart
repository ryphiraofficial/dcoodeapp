import 'package:flutter/material.dart';
import 'hero_section.dart';
import 'expertise_section.dart';
import 'projects_section.dart';
import 'stats_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          ExpertiseSection(),
          ProjectsSection(),
          SizedBox(height: 40),
          StatsSection(),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
