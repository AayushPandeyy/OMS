import 'package:flutter/material.dart';
import 'package:oms/core/widgets/step_indicator.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/presentation/pages/restaurant_info_page.dart';

class UserInfoPage extends StatefulWidget {
  final OnboardingFlowData onboardingData;

  const UserInfoPage({
    Key? key,
    this.onboardingData = const OnboardingFlowData(),
  }) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  // Validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _prefillFormFields();
    _passwordController.addListener(_checkPasswordStrength);
    _checkPasswordStrength();
  }

  void _prefillFormFields() {
    _emailController.text = widget.onboardingData.email ?? '';
    _usernameController.text = widget.onboardingData.username ?? '';
    _phoneController.text = widget.onboardingData.phoneNumber ?? '';
    _passwordController.text = widget.onboardingData.password ?? '';
    _confirmPasswordController.text = widget.onboardingData.password ?? '';
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  int get passwordStrength {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  Color get strengthColor {
    if (passwordStrength <= 2) return Colors.red;
    if (passwordStrength <= 3) return Colors.orange;
    return Colors.green;
  }

  String get strengthLabel {
    if (passwordStrength <= 2) return 'Weak';
    if (passwordStrength <= 3) return 'Fair';
    if (passwordStrength <= 4) return 'Good';
    return 'Strong';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final updatedData = widget.onboardingData.copyWith(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantInfoPage(onboardingData: updatedData),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    });
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
          // Step Indicator
          buildStepIndicator(0),

          // Form
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
                      'Create your account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 32),

                    // Email
                    _buildLabel('Email Address'),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Username
                    _buildLabel('Username'),
                    _buildTextField(
                      controller: _usernameController,
                      hintText: 'e.g. aayush_dev',
                      icon: Icons.person_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        if (!RegExp(
                          r'^[a-zA-Z0-9_]+$',
                        ).hasMatch(value.trim())) {
                          return 'Only letters, numbers, and underscores allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Number
                    _buildLabel('Phone Number'),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'e.g. +91 9876543210',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.trim().length < 7) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    _buildLabel('Password'),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Create a strong password',
                      icon: Icons.lock_outlined,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onToggleVisibility: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),

                    // Password Strength
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPasswordStrength(),
                    ],

                    const SizedBox(height: 20),

                    // Confirm Password
                    _buildLabel('Confirm Password'),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Re-enter your password',
                      icon: Icons.lock_outlined,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onNext,
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
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step Indicator ──────────────────────────────

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

  // ─── TextField ───────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: Colors.grey[500],
                ),
                onPressed: onToggleVisibility,
              )
            : null,
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

  // ─── Password Strength ───────────────────────────
  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 4 ? 6 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index < passwordStrength
                        ? strengthColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Strength label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strength: ${strengthLabel}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Criteria checklist
        _buildCriteriaItem('At least 8 characters', _hasMinLength),
        _buildCriteriaItem('One uppercase letter', _hasUppercase),
        _buildCriteriaItem('One lowercase letter', _hasLowercase),
        _buildCriteriaItem('One number', _hasNumber),
        _buildCriteriaItem('One special character', _hasSpecialChar),
      ],
    );
  }

  Widget _buildCriteriaItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: met ? Colors.green : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: met
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
