// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/citizen/screens/citizen_shell.dart';
import '../../features/citizen/screens/citizen_home_screen.dart';
import '../../features/citizen/screens/report_issue_screen.dart';
import '../../features/citizen/screens/my_issues_screen.dart';
import '../../features/citizen/screens/issue_details_screen.dart';
import '../../features/citizen/screens/notifications_screen.dart';
import '../../features/admin/screens/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_issues_screen.dart';
import '../../features/admin/screens/admin_issue_details_screen.dart';
import '../../features/admin/screens/admin_analytics_screen.dart';
import '../../features/admin/screens/admin_map_screen.dart';
import '../../features/common/screens/global_search_screen.dart';
import '../../features/common/screens/settings_screen.dart';
import '../../features/issues/models/issue_status.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = authState.isOnboarded;
      final role = authState.role;

      // Always allow splash
      if (path == '/splash') return null;

      // Not onboarded → onboarding
      if (!isOnboarded && path != '/onboarding') return '/onboarding';

      // Onboarded but not authenticated → auth
      if (!isAuthenticated && path != '/auth' && path != '/onboarding') {
        return '/auth';
      }

      // Authenticated → redirect away from auth/onboarding
      if (isAuthenticated && (path == '/auth' || path == '/onboarding')) {
        return role == UserRole.admin ? '/admin/dashboard' : '/citizen/home';
      }

      // Role guard: citizen trying to access admin
      if (isAuthenticated && role == UserRole.citizen && path.startsWith('/admin')) {
        return '/citizen/home';
      }

      // Role guard: admin trying to access citizen
      if (isAuthenticated && role == UserRole.admin && path.startsWith('/citizen')) {
        return '/admin/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Citizen Shell
      ShellRoute(
        builder: (context, state, child) => CitizenShell(child: child),
        routes: [
          GoRoute(
            path: '/citizen/home',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const CitizenHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/citizen/report',
            pageBuilder: (context, state) => _slidePage(
              state: state,
              child: const ReportIssueScreen(),
            ),
          ),
          GoRoute(
            path: '/citizen/my-issues',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const MyIssuesScreen(),
            ),
          ),
          GoRoute(
            path: '/citizen/notifications',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/citizen/issue/:id',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: IssueDetailsScreen(issueId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),

      // Admin Shell
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/issues',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const AdminIssuesScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/issue/:id',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: AdminIssueDetailsScreen(issueId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/admin/analytics',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const AdminAnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/map',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const AdminMapScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

CustomTransitionPage _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}
