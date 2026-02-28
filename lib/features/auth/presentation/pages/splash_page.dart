import 'package:flutter/material.dart';
import 'package:oms/core/theme/app_theme.dart';
import 'package:oms/features/auth/presentation/pages/login_page.dart';
import 'package:oms/features/dashboard/presentation/pages/owner_dashboard_page.dart';
import 'package:oms/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Brief delay for splash branding
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final isLoggedIn = await AuthService.isAuthenticated();

    if (!mounted) return;

    final destination = isLoggedIn
        ? const OwnerDashboardPage()
        : const LoginPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'OMS',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Order Management System',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
