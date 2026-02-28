import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oms/core/error/app_exception.dart';
import 'package:oms/features/auth/presentation/pages/registration_success_page.dart';
import 'package:oms/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:oms/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:oms/features/onboarding/domain/entities/register_user.dart';
import 'package:oms/features/onboarding/domain/usecases/register_user_usecase.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  // Password strength
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  late final http.Client _httpClient;
  late final RegisterUserUseCase _registerUserUseCase;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    final repository = OnboardingRepositoryImpl(
      remoteDataSource: OnboardingRemoteDataSourceImpl(client: _httpClient),
    );
    _registerUserUseCase = RegisterUserUseCase(repository);
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _httpClient.close();
    super.dispose();
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

  Future<void> _handleRegister() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final request = RegisterUserRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      await _registerUserUseCase(request);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSuccessPage()),
      );
    } on AppException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Something went wrong: ${error.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    hintText: 'e.g. john_doe',
                    icon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
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

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleRegister,
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
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFFFC5E03),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Text(
          'Strength: $strengthLabel',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: strengthColor,
          ),
        ),
        const SizedBox(height: 10),
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
