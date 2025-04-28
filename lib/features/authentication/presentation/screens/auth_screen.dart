import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:pureflow/features/authentication/providers/auth_provider.dart';
import 'package:pureflow/shared/constants/colors.dart';
import 'package:pureflow/shared/widgets/error_text.dart';

class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    final authState = ref.watch(authNotifierProvider);
    
    ref.listen(authNotifierProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        // Authentication successful, navigate based on role
        final user = next.value!;
        switch (user.role) {
          case UserRole.customer:
            context.go(Routes.dashboard);
            break;
          case UserRole.technician:
            context.go(Routes.techSchedule);
            break;
          case UserRole.admin:
            context.go(Routes.adminDashboard);
            break;
        }
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & welcome text
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            gradient: AppColors.brandGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to PureFlow',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to manage your water filter subscription',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Email input
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Error display
                if (authState is AsyncError)
                  ErrorText(error: authState.error.toString()),
                
                // OTP button
                ElevatedButton(
                  onPressed: authState is AsyncLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            ref.read(authNotifierProvider.notifier).signInWithOTP(
                                  emailController.text.trim(),
                                );
                          }
                        },
                  child: authState is AsyncLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue with Email'),
                ),
                const SizedBox(height: 16),
                
                // Apple sign-in
                OutlinedButton.icon(
                  onPressed: authState is AsyncLoading
                      ? null
                      : () {
                          ref
                              .read(authNotifierProvider.notifier)
                              .signInWithApple();
                        },
                  icon: const Icon(Icons.apple),
                  label: const Text('Continue with Apple'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 