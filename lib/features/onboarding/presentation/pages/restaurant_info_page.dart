import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oms/core/widgets/step_indicator.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/domain/enum/OnboardingEnums.dart';
import 'package:oms/features/onboarding/presentation/pages/branch_count_page.dart';

class RestaurantInfoPage extends StatefulWidget {
  final OnboardingFlowData onboardingData;

  const RestaurantInfoPage({
    Key? key,
    this.onboardingData = const OnboardingFlowData(),
  }) : super(key: key);

  @override
  State<RestaurantInfoPage> createState() => _RestaurantInfoPageState();
}

class _RestaurantInfoPageState extends State<RestaurantInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _logoPath;
  String? _logoFileName;
  Uint8List? _logoBytes;
  bool _isPickingLogo = false;
  String? _selectedRestaurantType;
  final Set<String> _selectedCuisineTypes = {};
  late final List<DropdownMenuItem<String>> _restaurantTypeItems;

  @override
  void initState() {
    super.initState();
    _restaurantTypeItems = _buildEnumMenuItems(RestaurantType.values);
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.onboardingData.restaurantName ?? '';
    _selectedRestaurantType = _sanitizeSelection(
      widget.onboardingData.restaurantType,
      _restaurantTypeItems,
    );
    // Restore previously selected cuisine types
    _selectedCuisineTypes.addAll(widget.onboardingData.cuisineTypes);
    final existingLogo = widget.onboardingData.logoUrl;
    if (existingLogo != null && existingLogo.isNotEmpty) {
      _logoPath = existingLogo;
      _logoFileName = existingLogo.split(RegExp(r'[\\/]')).isNotEmpty
          ? existingLogo.split(RegExp(r'[\\/]')).last
          : existingLogo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    if (_isPickingLogo) return;
    setState(() => _isPickingLogo = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _logoPath = file.path ?? file.name;
          _logoBytes = file.bytes;
          _logoFileName = file.name;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick logo: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingLogo = false);
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoPath = null;
      _logoFileName = null;
      _logoBytes = null;
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      final updatedData = widget.onboardingData.copyWith(
        restaurantName: _nameController.text.trim(),
        restaurantType: _selectedRestaurantType,
        cuisineTypes: _selectedCuisineTypes.toList(),
        logoUrl: _logoPath,
        logoBytes: _logoBytes,
        logoFileName: _logoFileName,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BranchCountPage(onboardingData: updatedData),
        ),
      );
    }
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
          buildStepIndicator(1),
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
                      'Restaurant Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tell us about your restaurant',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 32),

                    // Logo Upload
                    _buildLabel('Restaurant Logo'),
                    _buildLogoUploader(),
                    const SizedBox(height: 24),

                    // Restaurant Name
                    _buildLabel('Restaurant Name'),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'e.g. The Golden Fork',
                      icon: Icons.store_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Restaurant name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Restaurant Type
                    _buildLabel('Restaurant Type'),
                    _buildDropdown(
                      value: _selectedRestaurantType,
                      items: _restaurantTypeItems,
                      hintText: 'Select restaurant type',
                      icon: Icons.restaurant_outlined,
                      onChanged: (value) {
                        setState(() => _selectedRestaurantType = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a restaurant type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Cuisine Types (Multi-Select Chips)
                    Row(
                      children: [
                        _buildLabel('Cuisine Types'),
                        Text(
                          ' (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CuisineType.values.map((cuisine) {
                        final value = cuisine.value;
                        final isSelected = _selectedCuisineTypes.contains(
                          value,
                        );
                        return FilterChip(
                          label: Text(cuisine.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCuisineTypes.add(value);
                              } else {
                                _selectedCuisineTypes.remove(value);
                              }
                            });
                          },
                          selectedColor: const Color(
                            0xFFFC5E03,
                          ).withOpacity(0.15),
                          checkmarkColor: const Color(0xFFFC5E03),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFFFC5E03)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFC5E03)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
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
                            onPressed: _onNext,
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

  // ─── Label ───────────────────────────────────────
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ─── Logo Uploader ──────────────────────────────
  Widget _buildLogoUploader() {
    final hasLogo = _logoPath != null;
    return GestureDetector(
      onTap: _pickLogo,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasLogo
              ? const Color(0xFFFC5E03).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasLogo ? const Color(0xFFFC5E03) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: hasLogo ? _buildLogoSelectedContent() : _buildLogoEmptyState(),
      ),
    );
  }

  Widget _buildLogoEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPickingLogo ? Icons.hourglass_top : Icons.camera_alt_outlined,
            size: 28,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isPickingLogo ? 'Selecting logo...' : 'Upload Logo',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PNG, JPG up to 2MB',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildLogoSelectedContent() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFC5E03).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _logoBytes != null
                ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                : Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: Colors.orange[700],
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _logoFileName ?? 'Logo selected',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to change or use actions',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _pickLogo,
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Colors.grey[600],
          tooltip: 'Change logo',
        ),
        IconButton(
          onPressed: _removeLogo,
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.red,
          tooltip: 'Remove logo',
        ),
      ],
    );
  }

  // ─── TextField ────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }

  // ─── Dropdown ─────────────────────────────────────
  Widget _buildDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String hintText,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
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
}
