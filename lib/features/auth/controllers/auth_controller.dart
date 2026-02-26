// lib/features/auth/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../issues/models/user.dart';
import '../../issues/models/issue_status.dart';
import '../models/auth_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_controller.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._prefs) : super(_loadState(_prefs));

  final SharedPreferences _prefs;

  /// On first launch, auto-login as Citizen so user can use the app immediately.
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

    // First launch: auto-login as citizen with empty profile
    final defaultUser = AppUser(
      id: 'user_default',
      name: '',
      email: '',
      role: UserRole.citizen,
    );
    return AuthState(
      user: defaultUser,
      isAuthenticated: true,
      isOnboarded: true,
    );
  }

  /// Switch to admin role (from Settings)
  Future<void> switchToAdmin() async {
    final current = state.user!;
    final admin = AppUser(
      id: 'admin_default',
      name: current.name,
      email: current.email,
      role: UserRole.admin,
    );
    await _persistUser(admin);
    state = state.copyWith(user: admin, isAuthenticated: true);
  }

  /// Switch to citizen role (from Settings)
  Future<void> switchToCitizen() async {
    final current = state.user!;
    final citizen = AppUser(
      id: 'user_default',
      name: current.name,
      email: current.email,
      role: UserRole.citizen,
    );
    await _persistUser(citizen);
    state = state.copyWith(user: citizen, isAuthenticated: true);
  }

  /// Update display name
  Future<void> updateName(String name) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(name: name);
    await _prefs.setString(AppConstants.keyUserName, name);
    state = state.copyWith(user: updated);
  }

  Future<void> _persistUser(AppUser user) async {
    await _prefs.setString(AppConstants.keyUserId, user.id);
    await _prefs.setString(AppConstants.keyUserRole, user.role == UserRole.admin ? 'admin' : 'citizen');
    await _prefs.setString(AppConstants.keyUserName, user.name);
    await _prefs.setString(AppConstants.keyUserEmail, user.email);
  }

  /// Reserved for future: reset to a fresh citizen session
  Future<void> resetProfile() async {
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUserRole);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserEmail);
    final defaultUser = AppUser(id: 'user_default', name: '', email: '', role: UserRole.citizen);
    state = AuthState(user: defaultUser, isAuthenticated: true, isOnboarded: true);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthController(prefs);
});
