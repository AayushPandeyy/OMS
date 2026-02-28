import 'package:flutter/material.dart';
import 'package:oms/core/widgets/step_indicator.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/presentation/pages/branch_management_page.dart';

class BranchCountPage extends StatefulWidget {
  final OnboardingFlowData onboardingData;

  const BranchCountPage({
    Key? key,
    this.onboardingData = const OnboardingFlowData(),
  }) : super(key: key);

  @override
  State<BranchCountPage> createState() => _BranchCountPageState();
}

class _BranchCountPageState extends State<BranchCountPage> {
  bool? _hasMultipleBranches;
  late final bool _isStarterPlan;

  @override
  void initState() {
    super.initState();
    _isStarterPlan =
        (widget.onboardingData.planType ?? '').toUpperCase() == 'STARTER';
    _hasMultipleBranches =
        widget.onboardingData.hasMultipleBranches ??
        (_isStarterPlan ? false : null);
  }

  void _onContinue() {
    final bool? choice = _isStarterPlan ? false : _hasMultipleBranches;
    if (choice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedData = widget.onboardingData.copyWith(
      hasMultipleBranches: choice,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BranchManagementPage(
          hasMultipleBranches: choice,
          onboardingData: updatedData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          buildStepIndicator(2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  const Text(
                    'Branch Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Do you have multiple branches?',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  if (_isStarterPlan) ...[
                    const SizedBox(height: 16),
                    _buildPlanRestrictionBanner(),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 40),
                  ],

                  // Options
                  _buildOptionCard(
                    title: 'Single Branch',
                    description: 'I operate from one location',
                    icon: Icons.store,
                    isSelected: _hasMultipleBranches == false || _isStarterPlan,
                    enabled: true,
                    onTap: () => setState(() => _hasMultipleBranches = false),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    title: 'Multiple Branches',
                    description: 'I have a head office and multiple branches',
                    icon: Icons.business,
                    isSelected: _hasMultipleBranches == true,
                    enabled: !_isStarterPlan,
                    helperText: _isStarterPlan
                        ? 'Upgrade your plan to unlock multi-branch support'
                        : null,
                    onTap: () => setState(() => _hasMultipleBranches = true),
                  ),
                  const SizedBox(height: 40),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFC5E03),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRestrictionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFC5E03)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Starter plan includes support for a single branch. Upgrade to add more locations.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required bool enabled,
    String? helperText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled
          ? onTap
          : () {
              _showPlanLimitMessage(
                helperText ?? 'This action is unavailable for your plan',
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFC5E03) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFC5E03).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFC5E03).withOpacity(0.15)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                enabled ? icon : Icons.lock_outline,
                size: 28,
                color: enabled
                    ? isSelected
                          ? const Color(0xFFFC5E03)
                          : Colors.grey[500]
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: enabled
                          ? (isSelected
                                ? const Color(0xFFFC5E03)
                                : Colors.black87)
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: enabled ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                  if (helperText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      helperText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFC5E03),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showPlanLimitMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
  }
}
