// lib/features/citizen/screens/citizen_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/issue_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/category_chip.dart';
import '../../issues/models/category.dart';
import '../../issues/models/issue.dart';
import '../../issues/providers/issue_providers.dart';
import '../../auth/controllers/auth_controller.dart';

class CitizenHomeScreen extends ConsumerStatefulWidget {
  const CitizenHomeScreen({super.key});
  @override
  ConsumerState<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends ConsumerState<CitizenHomeScreen> {
  bool _loading = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _simulateLoad();
  }

  Future<void> _simulateLoad() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _onRefresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _loading = false);
  }

  List<Issue> _filtered(List<Issue> all) {
    if (_selectedCategoryId == null) return all;
    return all.where((i) => i.category.id == _selectedCategoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = ref.watch(authControllerProvider);
    final allIssues = ref.watch(allIssuesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered(allIssues);
    final nearby = allIssues.take(5).toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${auth.user?.name.split(' ').first ?? 'Citizen'} 👋',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'What needs fixing today?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(themeControllerProvider.notifier).toggle(context);
            },
            icon: AnimatedSwitcher(
              duration: AppConstants.animFast,
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            onPressed: () => context.push('/citizen/notifications'),
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Hero(
                        tag: 'search_field',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: scheme.onSurfaceVariant, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Search issues by area, type...',
                                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: IssueCategories.all.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return FilterChip(
                              label: const Text('All'),
                              selected: _selectedCategoryId == null,
                              onSelected: (_) => setState(() => _selectedCategoryId = null),
                              showCheckmark: false,
                            );
                          }
                          final cat = IssueCategories.all[index - 1];
                          return CategoryChip(
                            category: cat,
                            selected: _selectedCategoryId == cat.id,
                            onTap: () => setState(() {
                              _selectedCategoryId = _selectedCategoryId == cat.id ? null : cat.id;
                            }),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nearby Issues
                    Text('Nearby Issues', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            // Horizontal nearby list
            SliverToBoxAdapter(
              child: SizedBox(
                height: _loading ? 120 : 140,
                child: _loading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 4,
                        itemBuilder: (_, __) => Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: const IssueCardSkeleton(),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: nearby.length,
                        itemBuilder: (_, i) => _NearbyCard(issue: nearby[i]),
                      ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Text('Recent Issues', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/citizen/my-issues'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),
            ),

            // Vertical issues list
            if (_loading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const IssueCardSkeleton(),
                    childCount: 4,
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No issues found',
                  subtitle: 'Try a different category filter.',
                  actionLabel: 'Clear filter',
                  onAction: () => setState(() => _selectedCategoryId = null),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => IssueCard(issue: filtered[i]),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/citizen/report'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report Issue'),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final Issue issue;
  const _NearbyCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cat = issue.category;

    return GestureDetector(
      onTap: () => context.push('/citizen/issue/${issue.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cat.color.withOpacity(0.15), cat.color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cat.color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: cat.color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(cat.icon, size: 16, color: cat.color),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(100)),
                  child: Row(children: [
                    const Icon(Icons.near_me_rounded, size: 10, color: Colors.green),
                    const SizedBox(width: 3),
                    Text('${(issue.upvotes * 0.1 + 0.3).toStringAsFixed(1)} km', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              issue.location.areaName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
