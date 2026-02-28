import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:oms/core/constants/api_constants.dart';
import 'package:oms/core/error/app_exception.dart';
import 'package:oms/core/widgets/step_indicator.dart';
import 'package:oms/features/dashboard/presentation/pages/owner_dashboard_page.dart';
import 'package:oms/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:oms/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/domain/entities/restaurant_setup.dart';
import 'package:oms/features/onboarding/domain/entities/tax_configuration.dart';
import 'package:oms/features/onboarding/domain/enum/OnboardingEnums.dart';
import 'package:oms/features/onboarding/domain/usecases/setup_restaurant_usecase.dart';
import 'package:oms/services/auth_service.dart';

class TaxAndPricingPage extends StatefulWidget {
  final OnboardingFlowData onboardingData;

  const TaxAndPricingPage({
    Key? key,
    this.onboardingData = const OnboardingFlowData(),
  }) : super(key: key);

  @override
  State<TaxAndPricingPage> createState() => _TaxAndPricingPageState();
}

class _TaxAndPricingPageState extends State<TaxAndPricingPage> {
  final _formKey = GlobalKey<FormState>();
  final _taxPercentageController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  bool _isSubmitting = false;
  late final http.Client _httpClient;
  late final SetupRestaurantUseCase _setupRestaurantUseCase;

  bool _pricesIncludeTax = true;
  String? _selectedTaxName;
  late final List<DropdownMenuItem<String>> _taxTypeItems;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    final repository = OnboardingRepositoryImpl(
      remoteDataSource: OnboardingRemoteDataSourceImpl(client: _httpClient),
    );
    _setupRestaurantUseCase = SetupRestaurantUseCase(repository);
    _taxTypeItems = _buildEnumMenuItems(TaxType.values);
    _pricesIncludeTax = widget.onboardingData.isTaxed ?? true;
    _selectedTaxName = _sanitizeSelection(
      widget.onboardingData.taxType,
      _taxTypeItems,
    );
    final existingTaxPct = widget.onboardingData.taxPercentage;
    _taxPercentageController.text = existingTaxPct != null
        ? existingTaxPct.toString()
        : '';
    final existingSvcChg = widget.onboardingData.serviceCharge;
    _serviceChargeController.text = existingSvcChg != null
        ? existingSvcChg.toString()
        : '';
  }

  @override
  void dispose() {
    _taxPercentageController.dispose();
    _serviceChargeController.dispose();
    _httpClient.close();
    super.dispose();
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedTaxName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a tax name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_taxPercentageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter tax percentage'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _completeSetup() async {
    if (_isSubmitting || !_validateForm()) {
      return;
    }

    final setupRequest = _buildRestaurantSetupRequest();
    if (setupRequest == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);
    _showSettingUpMessage();

    try {
      // Upload logo image first if we have bytes
      String? uploadedLogoUrl;
      final logoBytes = widget.onboardingData.logoBytes;
      final logoFileName = widget.onboardingData.logoFileName;
      if (logoBytes != null && logoBytes.isNotEmpty) {
        uploadedLogoUrl = await _uploadLogoImage(
          logoBytes,
          logoFileName ?? 'logo.jpg',
        );
      }

      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw const AppException('Not authenticated. Please login again.');
      }

      await _setupRestaurantUseCase(
        uploadedLogoUrl != null
            ? RestaurantSetupRequest(
                name: setupRequest.name,
                logoUrl: uploadedLogoUrl,
                restaurantType: setupRequest.restaurantType,
                cuisineTypes: setupRequest.cuisineTypes,
                addressUrl: setupRequest.addressUrl,
                openingTime: setupRequest.openingTime,
                closingTime: setupRequest.closingTime,
                openDays: setupRequest.openDays,
                orderTypes: setupRequest.orderTypes,
                totalTables: setupRequest.totalTables,
                isTaxed: setupRequest.isTaxed,
                planType: setupRequest.planType,
                taxConfigurations: setupRequest.taxConfigurations,
                
              )
            : setupRequest,
        accessToken: accessToken,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Setup complete! Welcome to your dashboard.'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OwnerDashboardPage()),
        (route) => false,
      );
    } on AppException catch (error) {
      _showError(error.message);
    } catch (error) {
      print('Error during setup: ${error.toString()}');
      _showError('Something went wrong: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  RestaurantSetupRequest? _buildRestaurantSetupRequest() {
    final data = widget.onboardingData;

    String? requireField(String? value, String label) {
      if (value == null || value.trim().isEmpty) {
        _showError('Missing $label. Please review earlier steps.');
        return null;
      }
      return value.trim();
    }

    final name = requireField(data.restaurantName, 'restaurant name');
    if (name == null) return null;

    final restaurantType = requireField(data.restaurantType, 'restaurant type');
    if (restaurantType == null) return null;

    final cuisineTypes = data.cuisineTypes;

    final address = requireField(data.addressUrl, 'address');
    if (address == null) return null;

    final opening = requireField(data.openingTime, 'opening time');
    if (opening == null) return null;

    final closing = requireField(data.closingTime, 'closing time');
    if (closing == null) return null;

    final planType = requireField(data.planType, 'plan selection');
    if (planType == null) return null;

    final openDays = data.openDays;
    if (openDays.isEmpty) {
      _showError('Please select at least one open day.');
      return null;
    }

    final orderTypes = data.orderTypes;
    if (orderTypes.isEmpty) {
      _showError('Please select at least one order type.');
      return null;
    }

    final serviceChargeText = _serviceChargeController.text.trim();
    final taxPercentageValue =
        num.tryParse(_taxPercentageController.text.trim()) ?? 0;
    final serviceChargeValue = serviceChargeText.isEmpty
        ? null
        : num.tryParse(serviceChargeText);
    final taxConfiguration = TaxConfiguration(
      taxType: _selectedTaxName!,
      taxPercentage: taxPercentageValue,
      serviceCharge: serviceChargeValue,
    );

    return RestaurantSetupRequest(
      name: name,
      logoUrl: data.logoUrl?.trim() ?? '',
      restaurantType: restaurantType,
      cuisineTypes: List<String>.from(cuisineTypes),
      addressUrl: address,
      openingTime: opening,
      closingTime: closing,
      openDays: List<String>.from(openDays),
      orderTypes: List<String>.from(orderTypes),
      totalTables: data.totalTables ?? 0,
      isTaxed: data.isTaxed ?? true,
      planType: planType,
      taxConfigurations: [taxConfiguration],
    );
  }

  Future<String?> _uploadLogoImage(Uint8List bytes, String fileName) async {
    try {
      final uri = Uri.parse(ApiConstants.uploadMedia);
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url'] as String?;
      } else {
        throw Exception('Logo upload failed (${response.statusCode})');
      }
    } catch (error) {
      _showError('Failed to upload logo: ${error.toString()}');
      return null;
    }
  }

  void _showSettingUpMessage() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Setting you up...'),
          backgroundColor: Color(0xFF2196F3),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
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
          buildStepIndicator(4),
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
                      'Tax and Pricing',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Configure your tax and pricing settings',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 32),

                    // Prices Include Tax Section
                    _buildSectionHeader('Tax Inclusion', Icons.receipt_long),
                    const SizedBox(height: 16),
                    _buildPricesIncludeTaxCard(),
                    const SizedBox(height: 32),

                    // Tax Configuration Section
                    _buildSectionHeader('Tax Configuration', Icons.calculate),
                    const SizedBox(height: 16),
                    _buildTaxConfigurationCard(),
                    const SizedBox(height: 32),

                    // Service Charge Section
                    _buildSectionHeader(
                      'Service Charge (Optional)',
                      Icons.room_service,
                    ),
                    const SizedBox(height: 16),
                    _buildServiceChargeCard(),
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
                            onPressed: _isSubmitting ? null : _completeSetup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFC5E03),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Complete Setup',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.check_circle, size: 20),
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

  Widget _buildPricesIncludeTaxCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Do your menu prices include tax?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTaxInclusionOption(
                label: 'Yes, Inclusive',
                description: 'Price includes tax',
                icon: Icons.check_circle_outline,
                isSelected: _pricesIncludeTax,
                onTap: () => setState(() => _pricesIncludeTax = true),
              ),
              const SizedBox(width: 12),
              _buildTaxInclusionOption(
                label: 'No, Exclusive',
                description: 'Tax added separately',
                icon: Icons.add_circle_outline,
                isSelected: !_pricesIncludeTax,
                onTap: () => setState(() => _pricesIncludeTax = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxInclusionOption({
    required String label,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFC5E03).withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFC5E03) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? const Color(0xFFFC5E03) : Colors.grey[500],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFFFC5E03) : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxConfigurationCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tax Name
          _buildLabel('Tax Name'),
          _buildDropdown(
            value: _selectedTaxName,
            items: _taxTypeItems,
            hintText: 'Select tax type',
            icon: Icons.label_outline,
            onChanged: (value) {
              setState(() => _selectedTaxName = value);
            },
          ),
          const SizedBox(height: 20),

          // Tax Percentage
          _buildLabel('Tax Percentage'),
          _buildPercentageField(
            controller: _taxPercentageController,
            hintText: 'e.g. 5.0',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Tax percentage is required';
              }
              final percentage = double.tryParse(value);
              if (percentage == null) {
                return 'Please enter a valid number';
              }
              if (percentage < 0 || percentage > 100) {
                return 'Tax must be between 0 and 100';
              }
              return null;
            },
          ),

          // Example calculation
          if (_taxPercentageController.text.isNotEmpty &&
              double.tryParse(_taxPercentageController.text) != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC5E03).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFC5E03).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFFC5E03),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _buildTaxExample(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFC5E03),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildTaxExample() {
    final taxRate = double.tryParse(_taxPercentageController.text) ?? 0;
    if (_pricesIncludeTax) {
      // If price is 100 and includes 5% tax, base = 100/1.05 = 95.24
      final basePrice = 100 / (1 + taxRate / 100);
      final taxAmount = 100 - basePrice;
      return 'Example: ₹100 includes ₹${taxAmount.toStringAsFixed(2)} tax';
    } else {
      // If price is 100 and tax is 5%, total = 100 + 5 = 105
      final taxAmount = 100 * taxRate / 100;
      final total = 100 + taxAmount;
      return 'Example: ₹100 + ₹${taxAmount.toStringAsFixed(2)} tax = ₹${total.toStringAsFixed(2)}';
    }
  }

  Widget _buildServiceChargeCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Service Charge',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Additional charge for service',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          _buildPercentageField(
            controller: _serviceChargeController,
            hintText: 'e.g. 10.0 (leave empty if not applicable)',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null; // Optional field
              }
              final percentage = double.tryParse(value);
              if (percentage == null) {
                return 'Please enter a valid number';
              }
              if (percentage < 0 || percentage > 100) {
                return 'Service charge must be between 0 and 100';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String hintText,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      items: items,
    );
  }

  List<DropdownMenuItem<String>> _buildEnumMenuItems<T extends Enum>(
    Iterable<T> values,
  ) {
    return values
        .map(
          (enumValue) => DropdownMenuItem<String>(
            value: enumValue.value,
            child: Text(enumValue.label, style: const TextStyle(fontSize: 14)),
          ),
        )
        .toList();
  }

  String? _sanitizeSelection(
    String? value,
    List<DropdownMenuItem<String>> items,
  ) {
    if (value == null) {
      return null;
    }
    return items.any((item) => item.value == value) ? value : null;
  }

  Widget _buildPercentageField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(Icons.percent, size: 18, color: Colors.grey[500]),
        suffixText: '%',
        suffixStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        errorStyle: const TextStyle(fontSize: 11, color: Colors.red),
      ),
      onChanged: (value) => setState(() {}), // Trigger rebuild for example
    );
  }
}
