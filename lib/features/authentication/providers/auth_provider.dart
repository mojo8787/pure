import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/user.dart' as app;
import 'package:pureflow/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<app.User?> build() {
    debugPrint('AuthNotifier: Building provider');
    final authService = ref.watch(authServiceProvider);
    final initialUser = authService.currentUser;
    debugPrint('AuthNotifier: Initial user state: $initialUser');
    
    // Listen to auth state changes
    ref.listen(authStateChangesProvider, (previous, next) {
      debugPrint('AuthNotifier: Auth state changed. Previous: $previous, Next: $next');
      state = AsyncData(next.valueOrNull);
    });
    
    return initialUser;
  }

  Future<void> signInWithOTP(String email) async {
    debugPrint('AuthNotifier: Signing in with OTP');
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithOTP(email);
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      debugPrint('AuthNotifier: Error signing in with OTP: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    debugPrint('AuthNotifier: Signing in with email and password');
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithEmailPassword(email, password);
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      debugPrint('AuthNotifier: Error signing in with email and password: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithApple() async {
    debugPrint('AuthNotifier: Signing in with Apple');
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithApple();
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      debugPrint('AuthNotifier: Error signing in with Apple: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    debugPrint('AuthNotifier: Signing out');
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('AuthNotifier: Error signing out: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    debugPrint('AuthNotifier: Registering new user');
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).registerWithEmailPassword(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
          );
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      debugPrint('AuthNotifier: Error registering user: $e');
      state = AsyncError(e, st);
    }
  }
} 