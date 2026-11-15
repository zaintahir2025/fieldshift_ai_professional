import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'login_view.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontFamily: 'Roboto', color: AppColors.textDark),
                  children: [
                    TextSpan(text: 'FIELD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                    TextSpan(text: 'SHIFT ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF2D6A4F))),
                    TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFE65100))),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Initializing NASA Earth Advisory Workspace…',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSubtle),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return child;
    }

    return const LoginView();
  }
}
