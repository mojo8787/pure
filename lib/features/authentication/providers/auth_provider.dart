import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/user.dart';
import 'package:pureflow/core/services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() {
    return ref.watch(authStateChangesProvider).valueOrNull;
  }

  Future<void> signInWithOTP(String email) async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithOTP(email);
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithEmailPassword(email, password);
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithApple();
      // The auth state changes stream will update the state when authenticated
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
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
      state = AsyncError(e, st);
    }
  }
} 