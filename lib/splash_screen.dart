import 'package:flutter/material.dart';
import 'dart:async';
import 'constants.dart';
import 'widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.02;
        if (_progress >= 0.81) { // Matching the 81% in the design
          _timer?.cancel();
          _completeLoading();
        }
      });
    });
  }

  void _completeLoading() {
    // Navigation is now handled by AuthWrapper in main.dart
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Grid Effect (Optional/Subtle)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridPaper(
                color: Colors.grey,
                divisions: 1,
                subdivisions: 1,
                interval: 100,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Area
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(51), // 0.2 opacity approx 51/255
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const AppLogo(
                      fontSize: 32,
                      capsuleWidth: 60,
                      capsuleHeight: 28,
                      borderThickness: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                const Text('PRECISION-LED INNOVATION', style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 3)),
              ],
            ),
          ),
          // Loading Bar at bottom
          Positioned(
            bottom: 100,
            left: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_scanner, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('CALIBRATING INTERFACE...', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                      ],
                    ),
                    Text('${(_progress * 100).toInt()}%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
