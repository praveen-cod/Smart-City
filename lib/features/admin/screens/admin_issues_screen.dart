// lib/features/admin/screens/admin_issues_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/issue_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../issues/models/issue_status.dart';
import '../../issues/models/category.dart';
import '../../issues/providers/issue_providers.dart';
import '../../issues/repositories/issue_repository.dart';

class AdminIssuesScreen extends ConsumerStatefulWidget {
  const AdminIssuesScreen({super.key});
  @override
  ConsumerState<AdminIssuesScreen> createState() => _AdminIssuesScreenState();
}

class _AdminIssuesScreenState extends ConsumerState<AdminIssuesScreen> {
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _query = '';
  IssueStatus? _filterStatus;
  String? _filterCategoryId;
  SortOrder _sortOrder = SortOrder.latest;

  @override
  void initState() {
    super.initState();
    Future.delayed(AppConstants.mockLoadDelay, () {
      if (mounted) setState(() => _loading = false);
    });
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.watch(issueRepositoryProvider);

    final issues = _query.trim().isNotEmpty
        ? repo.searchIssues(_query, filters: IssueFilters(status: _filterStatus, categoryId: _filterCategoryId))
        : repo.fetchAllIssues(filters: IssueFilters(status: _filterStatus, categoryId: _filterCategoryId), sort: _sortOrder);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Search
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search issues...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        })
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              // Filter row
              Row(
                children: [
                  // Status filter
                  Expanded(
                    child: DropdownButtonFormField<IssueStatus?>(
                      value: _filterStatus,
                      decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Status')),
                        ...IssueStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
                      ],
                      onChanged: (v) => setState(() => _filterStatus = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Category filter
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _filterCategoryId,
                      decoration: const InputDecoration(labelText: 'Category', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Categories')),
                        ...IssueCategories.all.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) => setState(() => _filterCategoryId = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Result count + sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${issues.length} issue${issues.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              DropdownButton<SortOrder>(
                value: _sortOrder,
                underline: const SizedBox(),
                isDense: true,
                items: const [
                  DropdownMenuItem(value: SortOrder.latest, child: Text('Latest', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: SortOrder.oldest, child: Text('Oldest', style: TextStyle(fontSize: 13))),
                ],
                onChanged: (v) => setState(() => _sortOrder = v ?? SortOrder.latest),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: _loading
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (_, __) => const IssueCardSkeleton(),
                )
              : issues.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No issues found',
                      subtitle: 'Try adjusting your search or filters.',
                      actionLabel: 'Clear all',
                      onAction: () {
                        _searchCtrl.clear();
                        setState(() {
                          _query = '';
                          _filterStatus = null;
                          _filterCategoryId = null;
                        });
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: issues.length,
                      itemBuilder: (_, i) => IssueCard(issue: issues[i], isAdmin: true),
                    ),
        ),
      ],
    );
  }
}
