import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'constants.dart';
import 'providers/auth_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/student_provider.dart';
import 'features/certificate/certificate_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/staff/staff_main_screen.dart';
import 'screens/student/student_main_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => CertificateProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'Dcoode',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    await context.read<AuthProvider>().checkAuth();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SplashScreen();
    }

    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    if (authProvider.role == 'staff') {
      return const StaffMainScreen();
    } else {
      return const StudentMainScreen();
    }
  }
}
