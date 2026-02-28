import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oms/core/error/app_exception.dart';
import 'package:oms/features/auth/presentation/pages/register_page.dart';
import 'package:oms/features/dashboard/presentation/pages/owner_dashboard_page.dart';
import 'package:oms/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:oms/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:oms/features/onboarding/domain/entities/login.dart';
import 'package:oms/features/onboarding/domain/usecases/login_user_usecase.dart';
import 'package:oms/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late final http.Client _httpClient;
  late final LoginUserUseCase _loginUserUseCase;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    final repository = OnboardingRepositoryImpl(
      remoteDataSource: OnboardingRemoteDataSourceImpl(client: _httpClient),
    );
    _loginUserUseCase = LoginUserUseCase(repository);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _httpClient.close();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final request = LoginRequest(
      role: 'admin',
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = true);

    try {
      final response = await _loginUserUseCase(request);

      if (response.accessToken.isEmpty) {
        throw const AppException('Login failed: No access token received');
      }

      await _persistAuthTokens(response);

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OwnerDashboardPage()),
      );
    } on AppException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Something went wrong: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _persistAuthTokens(LoginResponse response) async {
    await AuthService.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OMS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order Management System',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          "Register",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
