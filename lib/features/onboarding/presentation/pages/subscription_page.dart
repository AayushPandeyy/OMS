import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/domain/entities/plan_feature.dart';
import 'package:oms/features/onboarding/presentation/pages/restaurant_info_page.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool isAnnual = false;
  int selectedPlan =
      -1; // -1 = none, 0 = starter, 1 = professional, 2 = enterprise

  // Monthly base prices
  final double starterPrice = 299;
  final double professionalPrice = 699;
  final double enterprisePrice = 1299;

  // Annual discount: 20% off
  double get starterFinal => isAnnual ? starterPrice * 0.8 : starterPrice;
  double get professionalFinal =>
      isAnnual ? professionalPrice * 0.8 : professionalPrice;
  double get enterpriseFinal =>
      isAnnual ? enterprisePrice * 0.8 : enterprisePrice;

  final List<PlanFeature> features = [
    PlanFeature(
      feature: 'Up to 5 Staff Members',
      starter: true,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Up to 20 Tables',
      starter: true,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Basic Order Management',
      starter: true,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Inventory Tracking',
      starter: true,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Up to 20 Staff Members',
      starter: false,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Up to 50 Tables',
      starter: false,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Advanced Analytics & Reports',
      starter: false,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Multi-role Access Control',
      starter: false,
      professional: true,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Unlimited Staff Members',
      starter: false,
      professional: false,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Unlimited Tables',
      starter: false,
      professional: false,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Priority 24/7 Support',
      starter: false,
      professional: false,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Custom Integrations',
      starter: false,
      professional: false,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Dedicated Account Manager',
      starter: false,
      professional: false,
      enterprise: true,
    ),
    PlanFeature(
      feature: 'Multi-branch Management',
      starter: false,
      professional: false,
      enterprise: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Appbar
          SliverAppBar(
            backgroundColor: const Color(0xFFFC5E03),
            elevation: 0,
            pinned: true,
            title: const Text(
              'Choose a Plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Billing Toggle
          SliverToBoxAdapter(child: _buildBillingToggle()),

          // Plan Cards
          SliverToBoxAdapter(child: _buildPlanCards()),

          // Divider + Compare heading
          SliverToBoxAdapter(child: _buildCompareHeading()),

          // Feature Comparison Table
          SliverToBoxAdapter(child: _buildFeatureComparison()),

          // FAQ
          SliverToBoxAdapter(child: _buildFAQ()),

          // Bottom spacing
          SliverToBoxAdapter(child: const SizedBox(height: 100)),
        ],
      ),

      // Sticky bottom CTA
      bottomNavigationBar: selectedPlan != -1 ? _buildBottomCTA() : null,
    );
  }

  // ─── Header ────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFC5E03).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: Color(0xFFFC5E03),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'OMS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick the perfect plan for your restaurant',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Billing Toggle ────────────────────────────
  Widget _buildBillingToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Monthly',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: !isAnnual ? Colors.black87 : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          // Custom switch track
          GestureDetector(
            onTap: () => setState(() => isAnnual = !isAnnual),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: isAnnual ? const Color(0xFFFC5E03) : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: isAnnual
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Text(
                'Annual',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isAnnual ? Colors.black87 : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 6),
              if (true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Save 20%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Plan Cards ────────────────────────────────
  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          _buildPlanCard(
            index: 0,
            title: 'Starter',
            price: starterFinal,
            description: 'Perfect for small restaurants just starting out',
            color: Colors.grey[700]!,
            icon: Icons.rocket_launch_outlined,
            highlights: ['5 Staff', '20 Tables', 'Basic Reports'],
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            index: 1,
            title: 'Professional',
            price: professionalFinal,
            description: 'Best for growing restaurants with more staff',
            color: const Color(0xFFFC5E03),
            icon: Icons.star_outlined,
            highlights: ['20 Staff', '50 Tables', 'Analytics'],
            isPopular: true,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            index: 2,
            title: 'Enterprise',
            price: enterpriseFinal,
            description: 'For large chains and multi-branch operations',
            color: Colors.indigo[700]!,
            icon: Icons.business_center_outlined,
            highlights: ['Unlimited', 'Priority Support', 'Custom'],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required double price,
    required String description,
    required Color color,
    required IconData icon,
    required List<String> highlights,
    bool isPopular = false,
  }) {
    bool isSelected = selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 24, color: color),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          isAnnual ? '/mo  (billed yearly)' : '/month',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Highlight chips
                  Wrap(
                    spacing: 8,
                    children: highlights
                        .map(
                          (h) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              h,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            // Popular badge
            if (isPopular)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC5E03),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Most Popular',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // Tick
            Positioned(
              bottom: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Compare Heading ───────────────────────────
  Widget _buildCompareHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compare Plans',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'See what each plan includes',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ─── Feature Comparison ────────────────────────
  Widget _buildFeatureComparison() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  const Expanded(child: SizedBox()),
                  ...['Starter', 'Pro', 'Enterprise'].map(
                    (label) => SizedBox(
                      width: 68,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Feature rows
          ...features.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: Colors.grey[100]),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.feature,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      ...[f.starter, f.professional, f.enterprise].map(
                        (has) => SizedBox(
                          width: 68,
                          child: Align(
                            alignment: Alignment.center,
                            child: has
                                ? const Icon(
                                    Icons.check_circle,
                                    size: 22,
                                    color: Color(0xFFFC5E03),
                                  )
                                : Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: Colors.grey[300],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── FAQ ───────────────────────────────────────
  Widget _buildFAQ() {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Can I change my plan later?',
        'a':
            'Yes, you can upgrade or downgrade your plan at any time from your account settings. Changes take effect at the end of your current billing cycle.',
      },
      {
        'q': 'Is there a free trial?',
        'a':
            'Yes! All plans come with a 14-day free trial. No credit card required to get started.',
      },
      {
        'q': 'What payment methods do you accept?',
        'a':
            'We accept all major credit cards, debit cards, UPI, and bank transfers.',
      },
      {
        'q': 'What happens if I cancel?',
        'a':
            'You can cancel anytime. Your account will remain active until the end of the paid period, after which it will be deactivated.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Frequently Asked',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ...faqs.map(
            (faq) => _FAQTile(question: faq['q']!, answer: faq['a']!),
          ),
        ],
      ),
    );
  }

  // ─── Bottom CTA ────────────────────────────────
  Widget _buildBottomCTA() {
    final titles = ['Starter', 'Professional', 'Enterprise'];
    final prices = [starterFinal, professionalFinal, enterpriseFinal];
    final colors = [
      Colors.grey[700]!,
      const Color(0xFFFC5E03),
      Colors.indigo[700]!,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titles[selectedPlan],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors[selectedPlan],
                      ),
                    ),
                    Text(
                      '₹${prices[selectedPlan].toStringAsFixed(0)}/${isAnnual ? 'mo' : 'month'}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _startTrial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5E03),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Free Trial',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTrial() {
    if (selectedPlan == -1) {
      return;
    }

    final onboardingData = OnboardingFlowData(
      planType: _planTypeFromIndex(selectedPlan),
      isAnnualBilling: isAnnual,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RestaurantInfoPage(onboardingData: onboardingData),
      ),
    );
  }

  String _planTypeFromIndex(int index) {
    switch (index) {
      case 1:
        return 'PREMIUM';
      case 2:
        return 'ENTERPRISE';
      case 0:
      default:
        return 'STARTER';
    }
  }
}

// ─── Reusable FAQ Tile ─────────────────────────────
class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => __FAQTileState();
}

class __FAQTileState extends State<_FAQTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      widget.answer,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
