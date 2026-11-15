import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToAdvisoryTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _farmNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitSignUp() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (!_agreedToAdvisoryTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the Decision-Support Advisory terms before proceeding.'),
          backgroundColor: AppColors.riskHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final success = await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        farmName: _farmNameController.text.trim().isEmpty ? 'My Resilient Farm' : _farmNameController.text.trim(),
      );

      if (!mounted) return;
      if (success) {
        Navigator.pop(context); // Pops back to AuthWrapper which will show home
      } else if (auth.errorMessage != null) {
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

  Widget _buildPasswordStrength() {
    final pwd = _passwordController.text;
    int strength = 0;
    if (pwd.length >= 6) strength++;
    if (pwd.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) strength++;
    if (RegExp(r'[!@#\$&*~A-Z]').hasMatch(pwd)) strength++;

    Color color;
    String label;
    if (pwd.isEmpty) {
      return const SizedBox.shrink();
    } else if (strength <= 1) {
      color = AppColors.riskHigh;
      label = 'Weak';
    } else if (strength <= 3) {
      color = AppColors.riskMedium;
      label = 'Moderate';
    } else {
      color = AppColors.resilientGreen;
      label = 'Strong';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: strength / 4,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 850;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Farmer Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? size.width * 0.28 : 24,
              vertical: 16,
            ),
            child: Column(
              children: [
                // Brand Logo Header
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Container
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
                        const Row(
                          children: [
                            Icon(Icons.person_add_alt_1, color: AppColors.primary, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Register Farm & Profile',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Join FieldShift AI to save field parcels, track multi-year soil health, and synchronize NASA Earth observations across devices.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35),
                        ),
                        const SizedBox(height: 20),

                        // Error Alert
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

                        // Full Name
                        const Text('Farmer / Agronomist Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Maria Gonzalez / Dr. Bilal Ahmad',
                            prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your name.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Farm / Organization Name
                        const Text('Farm or Basin Name (Optional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _farmNameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Delta Valley Farmland / Parcel 7',
                            prefixIcon: const Icon(Icons.agriculture_outlined, size: 18, color: AppColors.primary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Email
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
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter an email address.';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password
                        const Text('Create Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Minimum 6 characters',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textSubtle),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter a password.';
                            if (val.length < 6) return 'Password must be at least 6 characters.';
                            return null;
                          },
                        ),
                        _buildPasswordStrength(),
                        const SizedBox(height: 14),

                        // Confirm Password
                        const Text('Confirm Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textSubtle),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Human-in-the-loop Terms Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToAdvisoryTerms,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _agreedToAdvisoryTerms = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'I understand that FieldShift AI provides decision-support based on NASA Earth observations designed to support—not replace—local farmer judgment and traditional agricultural expertise.',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submitSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Create Account & Open Workspace',
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Back to Log In
                        Center(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  children: [
                                    TextSpan(
                                      text: 'Log In Here',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
