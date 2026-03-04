import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oms/features/auth/presentation/pages/login_page.dart';
import 'package:oms/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:oms/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:oms/features/dashboard/domain/entities/user_profile.dart';
import 'package:oms/features/dashboard/domain/usecases/get_user_profile_usecase.dart';
import 'package:oms/features/dashboard/presentation/pages/profile_page.dart';
import 'package:oms/features/onboarding/presentation/pages/subscription_page.dart';
import 'package:oms/services/auth_service.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  // Getting started steps state
  final List<_OnboardingStep> _steps = [
    _OnboardingStep(title: 'Create your account', isCompleted: true),
    _OnboardingStep(title: 'Add your first restaurant', isCompleted: false),
    _OnboardingStep(title: 'Set up your menu', isCompleted: false),
    _OnboardingStep(title: 'Start taking orders', isCompleted: false),
  ];

  late final http.Client _httpClient;
  late final GetUserProfileUseCase _getUserProfileUseCase;
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    final repository = DashboardRepositoryImpl(
      remoteDataSource: DashboardRemoteDataSourceImpl(client: _httpClient),
    );
    _getUserProfileUseCase = GetUserProfileUseCase(repository);
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) return;
      final profile = await _getUserProfileUseCase(accessToken: token);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.clearTokens();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'OMS Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white70,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white70,
            ),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUserProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _buildWelcomeHeader(),
                  const SizedBox(height: 20),

                  // Stats Cards
                  _buildStatsGrid(constraints),
                  const SizedBox(height: 20),

                  // Quick Actions & Getting Started
                  _buildMiddleSection(constraints),
                  const SizedBox(height: 20),

                  // Recent Activity
                  _buildRecentActivity(),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final username = _userProfile?.username ?? '';
    final planType = _userProfile?.planType ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _isLoadingProfile
                  ? const SizedBox(
                      height: 28,
                      width: 160,
                      child: LinearProgressIndicator(
                        backgroundColor: Color(0xFF2A2A2A),
                        color: Color(0xFFFC5E03),
                      ),
                    )
                  : Text(
                      'Hello, $username',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            if (!_isLoadingProfile && planType.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC5E03).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFC5E03).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  planType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFC5E03),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Here's an overview of your restaurant operations",
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BoxConstraints constraints) {
    final stats = [
      _StatData(
        label: 'RESTAURANTS',
        value: '—',
        icon: Icons.store_rounded,
        color: const Color(0xFFFC5E03),
      ),
      _StatData(
        label: 'ACTIVE ORDERS',
        value: '—',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFFC5E03),
      ),
      _StatData(
        label: 'MENU ITEMS',
        value: '—',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFFC5E03),
      ),
      _StatData(
        label: 'REVENUE TODAY',
        value: '—',
        icon: Icons.monetization_on_rounded,
        color: const Color(0xFFFC5E03),
      ),
    ];

    // Responsive: 2 columns on small screens, 4 on wider
    final isWide = constraints.maxWidth > 600;
    final crossAxisCount = isWide ? 4 : 2;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 1.8 : 1.6,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(_StatData stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat.icon, size: 18, color: stat.color),
              ),
            ],
          ),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleSection(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: _buildQuickActions())],
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jump to common tasks',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionChip(
                icon: Icons.add,
                label: 'Add Restaurant',
                isPrimary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
              ),
              _buildActionChip(
                icon: null,
                label: 'View Restaurants',
                isPrimary: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    IconData? icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFC5E03) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFFFC5E03)
                : const Color(0xFF4A4A4A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isPrimary ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your recent orders and updates will appear here once you start receiving orders.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          // Empty state
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3A3A3A),
                  style: BorderStyle.solid,
                ),
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 36,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No activity yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _OnboardingStep {
  final String title;
  final bool isCompleted;

  const _OnboardingStep({required this.title, required this.isCompleted});
}
