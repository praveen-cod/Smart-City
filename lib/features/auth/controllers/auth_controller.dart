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

  static AuthState _loadState(SharedPreferences prefs) {
    final isOnboarded = prefs.getBool(AppConstants.keyIsOnboarded) ?? false;
    final userId = prefs.getString(AppConstants.keyUserId);
    final roleStr = prefs.getString(AppConstants.keyUserRole);
    final name = prefs.getString(AppConstants.keyUserName);
    final email = prefs.getString(AppConstants.keyUserEmail);

    if (userId != null && roleStr != null && name != null && email != null) {
      final role = roleStr == 'admin' ? UserRole.admin : UserRole.citizen;
      return AuthState(
        user: AppUser(id: userId, name: name, email: email, role: role),
        isAuthenticated: true,
        isOnboarded: isOnboarded,
      );
    }

    return AuthState(isOnboarded: isOnboarded);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.keyIsOnboarded, true);
    state = state.copyWith(isOnboarded: true);
  }

  Future<void> loginAsCitizen({String? name, String? email}) async {
    final user = AppUser(
      id: MockUsers.citizen.id,
      name: name?.isNotEmpty == true ? name! : MockUsers.citizen.name,
      email: email?.isNotEmpty == true ? email! : MockUsers.citizen.email,
      role: UserRole.citizen,
    );
    await _persistUser(user);
    state = state.copyWith(user: user, isAuthenticated: true);
  }

  Future<void> loginAsAdmin({String? name, String? email}) async {
    final user = AppUser(
      id: MockUsers.admin.id,
      name: name?.isNotEmpty == true ? name! : MockUsers.admin.name,
      email: email?.isNotEmpty == true ? email! : MockUsers.admin.email,
      role: UserRole.admin,
    );
    await _persistUser(user);
    state = state.copyWith(user: user, isAuthenticated: true);
  }

  Future<void> _persistUser(AppUser user) async {
    await _prefs.setString(AppConstants.keyUserId, user.id);
    await _prefs.setString(AppConstants.keyUserRole, user.role == UserRole.admin ? 'admin' : 'citizen');
    await _prefs.setString(AppConstants.keyUserName, user.name);
    await _prefs.setString(AppConstants.keyUserEmail, user.email);
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUserRole);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserEmail);
    state = AuthState(isOnboarded: true);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthController(prefs);
});
