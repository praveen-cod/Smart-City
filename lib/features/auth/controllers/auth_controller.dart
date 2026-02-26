// lib/features/auth/controllers/auth_controller.dart
// Instagram-style auth: register once → auto-login every time
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../issues/models/user.dart';
import '../../issues/models/issue_status.dart';
import '../models/auth_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_controller.dart';

String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  return sha256.convert(bytes).toString();
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._prefs) : super(_loadState(_prefs));

  final SharedPreferences _prefs;

  static AuthState _loadState(SharedPreferences prefs) {
    final userId = prefs.getString(AppConstants.keyUserId);
    final roleStr = prefs.getString(AppConstants.keyUserRole);
    final name = prefs.getString(AppConstants.keyUserName) ?? '';
    final email = prefs.getString(AppConstants.keyUserEmail) ?? '';

    if (userId != null && roleStr != null) {
      final role = roleStr == 'admin' ? UserRole.admin : UserRole.citizen;
      return AuthState(
        user: AppUser(id: userId, name: name, email: email, role: role),
        isAuthenticated: true,
        isOnboarded: true,
      );
    }

    // Not logged in — show welcome screen
    return const AuthState(isAuthenticated: false, isOnboarded: false);
  }

  /// Register a new user. Returns null on success, error string on failure.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Check if email already registered
    final existingEmail = _prefs.getString('reg_email_${email.toLowerCase()}');
    if (existingEmail != null) {
      return 'An account with this email already exists.';
    }

    final userId = '${role.name}_${email.hashCode.abs()}';
    final passwordHash = _hashPassword(password);

    // Save registration record
    await _prefs.setString('reg_email_${email.toLowerCase()}', userId);
    await _prefs.setString('reg_password_$userId', passwordHash);
    await _prefs.setString('reg_role_$userId', role.name);
    await _prefs.setString('reg_name_$userId', name);

    // Auto-login after registration
    final user = AppUser(id: userId, name: name, email: email, role: role);
    await _persistSession(user);
    state = AuthState(user: user, isAuthenticated: true, isOnboarded: true);
    return null;
  }

  /// Login an existing user. Returns null on success, error string on failure.
  Future<String?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final userId = _prefs.getString('reg_email_${email.toLowerCase()}');
    if (userId == null) {
      return 'No account found with this email. Please register first.';
    }

    final storedHash = _prefs.getString('reg_password_$userId');
    if (storedHash != _hashPassword(password)) {
      return 'Incorrect password. Please try again.';
    }

    final storedRole = _prefs.getString('reg_role_$userId');
    if (storedRole != role.name) {
      return 'This account is registered as a ${storedRole == 'admin' ? 'Admin' : 'Citizen'}, not ${role == UserRole.admin ? 'Admin' : 'Citizen'}.';
    }

    final name = _prefs.getString('reg_name_$userId') ?? '';
    final user = AppUser(id: userId, name: name, email: email.toLowerCase(), role: role);
    await _persistSession(user);
    state = AuthState(user: user, isAuthenticated: true, isOnboarded: true);
    return null;
  }

  Future<void> _persistSession(AppUser user) async {
    await _prefs.setString(AppConstants.keyUserId, user.id);
    await _prefs.setString(AppConstants.keyUserRole, user.role.name);
    await _prefs.setString(AppConstants.keyUserName, user.name);
    await _prefs.setString(AppConstants.keyUserEmail, user.email);
  }

  /// Switch role (for admin-granted role switching)
  Future<void> switchToAdmin() async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(role: UserRole.admin);
    await _prefs.setString(AppConstants.keyUserRole, 'admin');
    state = state.copyWith(user: updated);
  }

  Future<void> switchToCitizen() async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(role: UserRole.citizen);
    await _prefs.setString(AppConstants.keyUserRole, 'citizen');
    state = state.copyWith(user: updated);
  }

  Future<void> updateName(String name) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(name: name);
    await _prefs.setString(AppConstants.keyUserName, name);
    // Also update registration record
    await _prefs.setString('reg_name_${state.user!.id}', name);
    state = state.copyWith(user: updated);
  }

  /// Logout: clear session but keep registration data
  Future<void> logout() async {
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUserRole);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserEmail);
    state = const AuthState(isAuthenticated: false, isOnboarded: false);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthController(prefs);
});
