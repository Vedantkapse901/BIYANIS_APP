import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/screens/super_admin_dashboard.dart';
import 'features/student/presentation/screens/student_dashboard_screen.dart';
import 'features/logbook/presentation/screens/teacher_dashboard_screen.dart';
import 'features/logbook/data/datasources/local_datasource.dart';
import 'core/utils/admin_utils.dart';
import 'core/widgets/biyani_logo.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    print('🔄 Initializing Supabase...');
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully!');

    // Verify Supabase is actually accessible
    final testClient = Supabase.instance.client;
    print('✅ Supabase client accessible: $testClient');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
    print('❌ Stack trace: ${StackTrace.current}');
  }

  runApp(const ProviderScope(child: StudentLogbookApp()));
}

class StudentLogbookApp extends StatelessWidget {
  const StudentLogbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Logbook',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/student': (context) => const StudentDashboardScreen(),
        '/teacher': (context) => const TeacherDashboardScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingStatus = 'Starting...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _loadingStatus = 'Initializing Database...');
      final localDataSource = LocalDataSource();
      await localDataSource.initialize();
      
      setState(() => _loadingStatus = 'Setting up data...');
      await localDataSource.seedMockData();

      setState(() => _loadingStatus = 'Syncing Approved Students...');
      await AdminUtils.syncFromGoogleSheets();

      setState(() => _loadingStatus = 'Checking user...');
      await _checkUserRole();
    } catch (e) {
      debugPrint('Initialization Error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _checkUserRole() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');

    if (role != null) {
      if (role == 'super_admin') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SuperAdminDashboard()),
          (route) => false,
        );
        return;
      }

      // User is already logged in
      final route = role == 'teacher' ? '/teacher' : '/student';
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (route) => false,
      );
    } else {
      // No session found, go to role selection
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/role-selection',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _loadingStatus = 'Retrying...';
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: const BiyaniLogo(size: 150),
            ),
            const SizedBox(height: 24),
            Text(
              'Student Logbook',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              _loadingStatus,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
