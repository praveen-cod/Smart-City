// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/issue_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../issues/providers/issue_providers.dart';
import '../../issues/models/issue_status.dart';
import '../../issues/models/location.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(AppConstants.mockLoadDelay, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.watch(issueRepositoryProvider);

    final kpiData = [
      _KpiData('Total Issues', repo.totalCount, Icons.assignment_rounded, const Color(0xFF1565C0)),
      _KpiData('Open', repo.openCount, Icons.radio_button_checked_rounded, const Color(0xFFE53935)),
      _KpiData('In Progress', repo.inProgressCount, Icons.autorenew_rounded, const Color(0xFFF57C00)),
      _KpiData('Resolved', repo.resolvedCount, Icons.check_circle_rounded, const Color(0xFF2E7D32)),
    ];

    final wardCounts = repo.getIssueCountByWard();
    final sortedWards = wardCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final urgentIssues = repo.getUrgentIssues().take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Text('Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (_loading)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const KpiCardSkeleton(),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kpiData.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _KpiCard(data: kpiData[i]),
              ),
            ),

          const SizedBox(height: 24),

          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.list_alt_rounded, label: 'All Issues', color: const Color(0xFF1565C0), onTap: () => context.go('/admin/issues'))),
              const SizedBox(width: 10),
              Expanded(child: _QuickAction(icon: Icons.analytics_rounded, label: 'Analytics', color: const Color(0xFF0288D1), onTap: () => context.go('/admin/analytics'))),
              const SizedBox(width: 10),
              Expanded(child: _QuickAction(icon: Icons.map_rounded, label: 'Map View', color: const Color(0xFF00897B), onTap: () => context.go('/admin/map'))),
            ],
          ),

          const SizedBox(height: 24),

          // Critical areas
          Text('Critical Areas (by volume)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...sortedWards.take(5).map((entry) {
            final loc = MockLocations.all.firstWhere(
              (l) => l.wardNumber == entry.key,
              orElse: () => IssueLocation(areaName: 'Ward ${entry.key}', wardNumber: entry.key),
            );
            final pct = repo.totalCount > 0 ? entry.value / repo.totalCount : 0.0;
            return _WardTile(
              area: loc.areaName,
              ward: entry.key,
              count: entry.value,
              pct: pct,
            );
          }),

          const SizedBox(height: 24),

          // Urgent issues
          if (urgentIssues.isNotEmpty) ...[
            Row(
              children: [
                Text('Urgent Issues', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                  child: Text('${urgentIssues.length}', style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...urgentIssues.map((issue) => IssueCard(issue: issue, isAdmin: true)),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _KpiData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.color.withOpacity(0.12), data.color.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: data.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const Spacer(),
          Text(
            '${data.value}',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: data.color),
          ),
          Text(data.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _WardTile extends StatelessWidget {
  final String area;
  final String ward;
  final int count;
  final double pct;
  const _WardTile({required this.area, required this.ward, required this.count, required this.pct});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barColor = pct > 0.2 ? Colors.red : pct > 0.1 ? Colors.orange : scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(area, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Ward $ward', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: barColor.withOpacity(0.12), borderRadius: BorderRadius.circular(100)),
                child: Text('$count issues', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: barColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: scheme.outlineVariant.withOpacity(0.2),
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}
