import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:pureflow/core/models/user.dart';

part 'auth_service.g.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Get the current authenticated user
  User? get currentUser {
    final userData = _client.auth.currentUser;
    if (userData == null) return null;

    final role = userData.appMetadata['role'] as String? ?? 'customer';
    return User(
      id: userData.id,
      email: userData.email ?? '',
      role: _parseRole(role),
      fullName: userData.userMetadata?['full_name'] as String?,
      phone: userData.userMetadata?['phone'] as String?,
      avatarUrl: userData.userMetadata?['avatar_url'] as String?,
    );
  }

  /// Sign in with email and password
  Future<void> signInWithEmailPassword(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email OTP
  Future<void> signInWithOTP(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.pureflow.app://login-callback/',
    );
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.pureflow.app://login-callback/',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Register with email and password
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': 'customer',
      },
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get the user role from metadata
  UserRole _parseRole(String role) {
    switch (role) {
      case 'technician':
        return UserRole.technician;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(Supabase.instance.client);
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) async* {
  final authService = ref.watch(authServiceProvider);
  
  yield authService.currentUser;
  
  await for (final _ in Supabase.instance.client.auth.onAuthStateChange) {
    yield authService.currentUser;
  }
} 