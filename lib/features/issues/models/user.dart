// lib/features/issues/models/user.dart
import 'issue_status.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarInitials;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarInitials,
  });

  String get initials {
    if (avatarInitials != null) return avatarInitials!;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarInitials,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarInitials: avatarInitials ?? this.avatarInitials,
    );
  }
}

// Mock users
class MockUsers {
  static const citizen = AppUser(
    id: 'user_001',
    name: 'Rahul Sharma',
    email: 'rahul@example.com',
    role: UserRole.citizen,
  );

  static const admin = AppUser(
    id: 'admin_001',
    name: 'Priya Menon',
    email: 'priya.admin@citypulse.gov',
    role: UserRole.admin,
  );
}
