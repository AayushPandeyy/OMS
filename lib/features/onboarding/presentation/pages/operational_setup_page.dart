import 'package:flutter/material.dart';
import 'package:oms/core/widgets/step_indicator.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/presentation/pages/tax_and_pricing_page.dart';

class OperationalSetupPage extends StatefulWidget {
  final OnboardingFlowData onboardingData;

  const OperationalSetupPage({
    Key? key,
    this.onboardingData = const OnboardingFlowData(),
  }) : super(key: key);

  @override
  State<OperationalSetupPage> createState() => _OperationalSetupPageState();
}

class _OperationalSetupPageState extends State<OperationalSetupPage> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  final Set<String> _selectedDays = {};
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Set<String> _selectedOrderTypes = {};
  final List<Map<String, dynamic>> _orderTypes = [
    {
      'type': 'DINE_IN',
      'label': 'Dine In',
      'icon': Icons.restaurant_menu,
      'description': 'Customers eat at restaurant',
    },
    {
      'type': 'TAKEAWAY',
      'label': 'Takeaway',
      'icon': Icons.takeout_dining,
      'description': 'Customers pick up orders',
    },
    {
      'type': 'DELIVERY',
      'label': 'Delivery (Offline)',
      'icon': Icons.delivery_dining,
      'description': 'Restaurant delivers orders',
    },
  ];

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFC5E03),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _validateForm() {
    if (_openingTime == null || _closingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select opening and closing times'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one open day'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedOrderTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one order type'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _onContinue() {
    if (_validateForm()) {
      final updatedData = widget.onboardingData.copyWith(
        openingTime: _timeForRequest(_openingTime!),
        closingTime: _timeForRequest(_closingTime!),
        openDays: _selectedDays.toList(),
        orderTypes: _selectedOrderTypes.toList(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaxAndPricingPage(onboardingData: updatedData),
        ),
      );
    }
  }

  String _timeForRequest(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          buildStepIndicator(3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Text(
                      'Operational Setup',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Configure your restaurant operations',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 32),

                    // Operating Hours Section
                    _buildSectionHeader('Operating Hours', Icons.access_time),
                    const SizedBox(height: 16),
                    _buildOperatingHoursCard(),
                    const SizedBox(height: 32),

                    // Open Days Section
                    _buildSectionHeader('Open Days', Icons.calendar_today),
                    const SizedBox(height: 16),
                    _buildOpenDaysCard(),
                    const SizedBox(height: 32),

                    // Order Types Section
                    _buildSectionHeader('Order Types', Icons.shopping_bag),
                    const SizedBox(height: 16),
                    _buildOrderTypesCard(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFC5E03).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFFC5E03)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingHoursCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Opening Time
          _buildTimeSelector(
            label: 'Opening Time',
            icon: Icons.wb_sunny,
            time: _openingTime,
            onTap: () => _selectTime(context, true),
          ),
          const SizedBox(height: 16),
          // Divider
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 16),
          // Closing Time
          _buildTimeSelector(
            label: 'Closing Time',
            icon: Icons.nightlight_round,
            time: _closingTime,
            onTap: () => _selectTime(context, false),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required IconData icon,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: time != null
                  ? const Color(0xFFFC5E03).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: time != null ? const Color(0xFFFC5E03) : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: time != null ? Colors.black87 : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildOpenDaysCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Select All / Deselect All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDays.length} day${_selectedDays.length != 1 ? 's' : ''} selected',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedDays.length == _weekDays.length) {
                      _selectedDays.clear();
                    } else {
                      _selectedDays.addAll(_weekDays);
                    }
                  });
                },
                child: Text(
                  _selectedDays.length == _weekDays.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFC5E03),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekDays.map((day) {
              final isSelected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFC5E03)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFC5E03)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    day.substring(0, 3),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypesCard() {
    return Column(
      children: _orderTypes.map((orderType) {
        final isSelected = _selectedOrderTypes.contains(orderType['type']);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedOrderTypes.remove(orderType['type']);
                } else {
                  _selectedOrderTypes.add(orderType['type']);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFC5E03)
                      : Colors.grey[300]!,
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
                      orderType['icon'] as IconData,
                      size: 28,
                      color: isSelected
                          ? const Color(0xFFFC5E03)
                          : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderType['label'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFFFC5E03)
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderType['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
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
          ),
        );
      }).toList(),
    );
  }
}
