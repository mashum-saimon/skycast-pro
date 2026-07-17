import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../database/database_helper.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(DatabaseHelper.instance);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authLocalDataSourceProvider));
});

enum AuthStatus { initial, unauthenticated, authenticated, error, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_in_username');
    final password = prefs.getString('logged_in_password');

    if (username != null && password != null) {
      await login(username, password);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(username, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        state = state.copyWith(status: AuthStatus.unauthenticated); // reset error state to unauthenticated
      },
      (user) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_username', username);
        await prefs.setString('logged_in_password', password);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      },
    );
  }

  Future<void> register(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.register(username, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
      (user) async {
        // Automatically login after registration
        await login(username, password);
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_username');
    await prefs.remove('logged_in_password');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
