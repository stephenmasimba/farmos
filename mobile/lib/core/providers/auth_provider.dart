import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'service_providers.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required AuthService authService,
    required StorageService storage,
  })  : _auth = authService,
        _storage = storage,
        super(const AuthState(status: AuthStatus.loading)) {
    _init();
  }

  final AuthService _auth;
  final StorageService _storage;

  Future<void> _init() async {
    final hasSession = await _storage.hasValidSession();
    if (!hasSession) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _auth.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await _auth.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('ApiException', '').trim(),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await _auth.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('ApiException', '').trim(),
      );
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
    storage: ref.read(storageServiceProvider),
  );
});
