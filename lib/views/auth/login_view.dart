import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (_formKey.currentState?.validate() ?? false) {
      final success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      if (!success && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(auth.errorMessage!, style: const TextStyle(fontSize: 12.5))),
              ],
            ),
            backgroundColor: AppColors.riskHigh,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    final auth = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the email address registered with your farm account. We will send you instructions to reset your password via Firebase Auth.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: resetController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final email = resetController.text.trim();
                if (email.isNotEmpty && email.contains('@')) {
                  Navigator.pop(ctx);
                  final sent = await auth.resetPassword(email);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sent
                          ? 'Password reset instructions sent to $email'
                          : (auth.errorMessage ?? 'Failed to send reset email.')),
                      backgroundColor: sent ? AppColors.resilientGreen : AppColors.riskHigh,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 850;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? size.width * 0.28 : 24,
              vertical: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Header & Logo
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),

                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'Roboto', color: AppColors.textDark),
                    children: [
                      TextSpan(text: 'FIELD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -0.5)),
                      TextSpan(text: 'SHIFT ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF2D6A4F))),
                      TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFE65100))),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'NASA EARTH OBSERVATION ADVISORY SYSTEM',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: AppColors.textSubtle),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Login Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back, Farmer',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to access your farm parcels, NASA Earth data, and climate rotation models.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35),
                        ),
                        const SizedBox(height: 22),

                        // Error Banner
                        if (auth.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.riskHigh.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.riskHigh, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    auth.errorMessage!,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.riskHigh, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        const Text('Email Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'farmer@resilientfarm.com',
                            prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address.';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            InkWell(
                              onTap: _showForgotPasswordDialog,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textSubtle),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, size: 18, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign In to Farm Workspace',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Divider with OR
                        const Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.borderLight)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                            ),
                            Expanded(child: Divider(color: AppColors.borderLight)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Quick Demo / Guest Mode Button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    auth.clearError();
                                    await auth.loginAsGuest();
                                  },
                            icon: const Icon(Icons.travel_explore, size: 18, color: AppColors.secondary),
                            label: const Text(
                              'Explore Demo in Field Guest Mode',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.secondary, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Link to Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have a farm account? ", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            InkWell(
                              onTap: () {
                                auth.clearError();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignUpView()),
                                );
                              },
                              child: const Text(
                                'Sign Up Now',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Human In The Loop Trust Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 15, color: AppColors.primary),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Decision-Support Tool · Designed to Support, Not Replace, Farmer Expertise',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
