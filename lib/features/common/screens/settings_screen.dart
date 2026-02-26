// lib/features/common/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // User section
          if (user != null) ...[
            _SectionHeader('Account'),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  user.initials,
                  style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary),
                ),
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(user.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: user.role.name == 'admin' ? Colors.purple.withOpacity(0.1) : scheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  user.role.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: user.role.name == 'admin' ? Colors.purple : scheme.primary,
                  ),
                ),
              ),
            ),
          ],

          _SectionHeader('Appearance'),

          // Theme mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Theme selector',
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_android_rounded, size: 16),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 16),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 16),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (v) {
                      ref.read(themeControllerProvider.notifier).setTheme(v.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          _SectionHeader('About'),

          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.location_city_rounded, color: scheme.primary, size: 20),
            ),
            title: const Text('CityPulse'),
            subtitle: const Text('Citizen Issue Portal'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('App Version'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(100)),
              child: Text(
                'v${AppConstants.appVersion} (${AppConstants.appBuild})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),

          _SectionHeader('Actions'),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/auth');
              }
            },
          ),

          const SizedBox(height: 40),

          Center(
            child: Text(
              'Made with ❤️ for better cities',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
