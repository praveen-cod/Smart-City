// lib/features/issues/repositories/issue_repository.dart
import '../models/issue.dart';
import '../models/issue_status.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/user.dart';

class IssueFilters {
  final IssueStatus? status;
  final String? categoryId;
  final String? wardNumber;
  final String? reporterId;
  final DateTimeRange? dateRange;

  const IssueFilters({
    this.status,
    this.categoryId,
    this.wardNumber,
    this.reporterId,
    this.dateRange,
  });

  IssueFilters copyWith({
    IssueStatus? status,
    String? categoryId,
    String? wardNumber,
    String? reporterId,
    DateTimeRange? dateRange,
    bool clearStatus = false,
    bool clearCategory = false,
    bool clearWard = false,
    bool clearDate = false,
  }) {
    return IssueFilters(
      status: clearStatus ? null : (status ?? this.status),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      wardNumber: clearWard ? null : (wardNumber ?? this.wardNumber),
      reporterId: reporterId ?? this.reporterId,
      dateRange: clearDate ? null : (dateRange ?? this.dateRange),
    );
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}

enum SortOrder { latest, oldest }

class IssueRepository {
  final List<Issue> _issues = [];
  final Map<String, List<IssueStatusHistory>> _history = {};

  IssueRepository() {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    final locs = MockLocations.all;
    final cats = IssueCategories.all;
    final statuses = IssueStatus.values;
    final reporters = [
      ('user_001', 'Rahul Sharma'),
      ('user_002', 'Amit Patel'),
      ('user_003', 'Sunita Rao'),
      ('user_004', 'Deepak Nair'),
      ('user_005', 'Kavya Krishnan'),
    ];

    final seedData = [
      ('Pothole on 80 feet road', 'Large pothole causing accidents near the junction. Multiple vehicles damaged.', 0, 0, 0, 2, true),
      ('Broken streetlight near park', 'The streetlight has been non-functional for 3 weeks. Security concern at night.', 2, 1, 1, 5, false),
      ('Overflowing drain', 'Drain overflows during rain causing flooding on footpath. Disease risk.', 1, 2, 0, 8, true),
      ('Garbage not collected for 5 days', 'Garbage pickup has not happened this week. Stench is unbearable.', 3, 3, 2, 10, false),
      ('Fallen tree blocking road', 'Large tree fell during storm, blocking half the road near community hall.', 4, 4, 3, 1, true),
      ('Water pipe burst', 'Main water pipe has burst near the bus stop. Water wastage is high.', 1, 5, 0, 12, true),
      ('Road under construction left unattended', 'Road digging left open for 2 weeks without barricades or completion.', 0, 6, 1, 7, false),
      ('No electricity for 2 days', 'Power cut in the entire block since Tuesday. No response from EB.', 2, 7, 2, 15, true),
      ('Public toilet in poor condition', 'Community toilet near market is unclean, no water supply.', 6, 8, 2, 6, false),
      ('Noise pollution from construction', 'Illegal construction happening at night, causing noise disturbance.', 5, 9, 3, 3, false),
      ('Damaged footpath tiles', 'Footpath tiles are broken, causing tripping hazard especially for elderly.', 0, 0, 1, 4, false),
      ('Mosquito breeding in stagnant water', 'Stagnant water in empty plot is breeding mosquitoes. Health risk.', 1, 1, 3, 9, true),
      ('Street dog menace', 'Pack of aggressive stray dogs near school area. Children at risk.', 6, 2, 0, 11, true),
      ('Illegal dumping of waste', 'Construction debris illegally dumped on the roadside near sector 4.', 3, 3, 1, 2, false),
      ('Park benches broken', 'Several park benches are damaged. Senior citizens have nowhere to sit.', 4, 4, 2, 5, false),
      ('Manhole cover missing', 'Open manhole on the main road without any cover or warning. Very dangerous.', 0, 5, 0, 14, true),
      ('Waterlogging after rain', 'Water logging persists for days after rain. Poor drainage design.', 1, 6, 1, 8, false),
      ('Graffiti on public walls', 'Offensive graffiti sprayed on the school compound wall.', 6, 7, 2, 1, false),
      ('Bus stop shelter damaged', 'Bus stop shelter roof is broken, citizens exposed to sun and rain.', 0, 8, 3, 3, false),
      ('Electric poles leaning dangerously', 'Electricity poles are tilted dangerously after the storm. Risk of collapse.', 2, 9, 0, 16, true),
    ];

    for (var i = 0; i < seedData.length; i++) {
      final d = seedData[i];
      final reporterData = reporters[i % reporters.length];
      final daysAgo = (i * 2) + 1;
      final created = now.subtract(Duration(days: daysAgo, hours: i));
      final updated = created.add(Duration(hours: 2 + i));
      final status = statuses[d.$7 ? (i % 2 == 0 ? 0 : 1) : (i % statuses.length)];

      final issue = Issue(
        id: 'issue_${(i + 1).toString().padLeft(3, '0')}',
        title: d.$1,
        description: d.$2,
        category: cats[d.$3 % cats.length],
        location: locs[d.$4 % locs.length],
        status: status,
        createdAt: created,
        updatedAt: updated,
        reporterId: reporterData.$1,
        reporterName: reporterData.$2,
        attachments: [],
        upvotes: d.$6,
        isUrgent: d.$7,
      );
      _issues.add(issue);

      // Add initial history
      final history = <IssueStatusHistory>[
        IssueStatusHistory(
          id: 'hist_${i}_0',
          issueId: issue.id,
          oldStatus: IssueStatus.open,
          newStatus: IssueStatus.open,
          changedAt: created,
          note: 'Issue reported by citizen',
          changedBy: reporterData.$2,
        ),
      ];

      if (status == IssueStatus.inProgress || status == IssueStatus.resolved) {
        history.add(IssueStatusHistory(
          id: 'hist_${i}_1',
          issueId: issue.id,
          oldStatus: IssueStatus.open,
          newStatus: IssueStatus.inProgress,
          changedAt: created.add(const Duration(hours: 6)),
          note: 'Assigned to field team for inspection.',
          changedBy: 'Admin - Priya Menon',
        ));
      }
      if (status == IssueStatus.resolved) {
        history.add(IssueStatusHistory(
          id: 'hist_${i}_2',
          issueId: issue.id,
          oldStatus: IssueStatus.inProgress,
          newStatus: IssueStatus.resolved,
          changedAt: created.add(const Duration(days: 1, hours: 4)),
          note: 'Issue resolved. Work completed by maintenance team.',
          changedBy: 'Admin - Priya Menon',
        ));
      }
      if (status == IssueStatus.rejected) {
        history.add(IssueStatusHistory(
          id: 'hist_${i}_1r',
          issueId: issue.id,
          oldStatus: IssueStatus.open,
          newStatus: IssueStatus.rejected,
          changedAt: created.add(const Duration(hours: 12)),
          note: 'Issue falls outside municipal jurisdiction. Referred to state authority.',
          changedBy: 'Admin - Priya Menon',
        ));
      }

      _history[issue.id] = history;
    }
  }

  List<Issue> fetchAllIssues({IssueFilters? filters, SortOrder sort = SortOrder.latest}) {
    var result = List<Issue>.from(_issues);
    if (filters != null) {
      if (filters.status != null) {
        result = result.where((i) => i.status == filters.status).toList();
      }
      if (filters.categoryId != null && filters.categoryId!.isNotEmpty) {
        result = result.where((i) => i.category.id == filters.categoryId).toList();
      }
      if (filters.wardNumber != null && filters.wardNumber!.isNotEmpty) {
        result = result.where((i) => i.location.wardNumber == filters.wardNumber).toList();
      }
    }
    if (sort == SortOrder.latest) {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return result;
  }

  List<Issue> fetchMyIssues(String userId, {IssueFilters? filters, SortOrder sort = SortOrder.latest}) {
    final f = (filters ?? const IssueFilters()).copyWith(reporterId: userId);
    var result = fetchAllIssues(filters: f, sort: sort);
    return result.where((i) => i.reporterId == userId).toList();
  }

  Issue? getIssueById(String id) {
    try {
      return _issues.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Issue> searchIssues(String query, {IssueFilters? filters}) {
    final q = query.toLowerCase().trim();
    var result = fetchAllIssues(filters: filters);
    if (q.isEmpty) return result;
    return result.where((i) {
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.location.areaName.toLowerCase().contains(q) ||
          i.category.name.toLowerCase().contains(q);
    }).toList();
  }

  Issue createIssue(Issue issue) {
    _issues.insert(0, issue);
    _history[issue.id] = [
      IssueStatusHistory(
        id: 'hist_${issue.id}_0',
        issueId: issue.id,
        oldStatus: IssueStatus.open,
        newStatus: IssueStatus.open,
        changedAt: issue.createdAt,
        note: 'Issue reported by citizen',
        changedBy: issue.reporterName,
      ),
    ];
    return issue;
  }

  Issue? updateIssueStatus(String issueId, IssueStatus newStatus, {String? note}) {
    final idx = _issues.indexWhere((i) => i.id == issueId);
    if (idx == -1) return null;

    final old = _issues[idx];
    final updated = old.copyWith(status: newStatus, updatedAt: DateTime.now());
    _issues[idx] = updated;

    _history[issueId] ??= [];
    _history[issueId]!.add(IssueStatusHistory(
      id: 'hist_${issueId}_${_history[issueId]!.length}',
      issueId: issueId,
      oldStatus: old.status,
      newStatus: newStatus,
      changedAt: DateTime.now(),
      note: note,
      changedBy: MockUsers.admin.name,
    ));

    return updated;
  }

  List<IssueStatusHistory> getIssueHistory(String issueId) {
    return List.from(_history[issueId] ?? []);
  }

  Map<String, int> getIssueCountByCategory() {
    final counts = <String, int>{};
    for (final issue in _issues) {
      counts[issue.category.id] = (counts[issue.category.id] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getIssueCountByWard() {
    final counts = <String, int>{};
    for (final issue in _issues) {
      counts[issue.location.wardNumber] = (counts[issue.location.wardNumber] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getIssueCountByStatus() {
    final counts = <String, int>{};
    for (final issue in _issues) {
      counts[issue.status.value] = (counts[issue.status.value] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns issue counts grouped by day over last N days
  List<MapEntry<DateTime, int>> getIssuesTrend(int days) {
    final now = DateTime.now();
    final result = <MapEntry<DateTime, int>>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final count = _issues.where((issue) {
        final d = issue.createdAt;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
      result.add(MapEntry(day, count));
    }
    return result;
  }

  int get totalCount => _issues.length;
  int get openCount => _issues.where((i) => i.status == IssueStatus.open).length;
  int get inProgressCount => _issues.where((i) => i.status == IssueStatus.inProgress).length;
  int get resolvedCount => _issues.where((i) => i.status == IssueStatus.resolved).length;
  int get rejectedCount => _issues.where((i) => i.status == IssueStatus.rejected).length;

  List<Issue> getUrgentIssues() => _issues.where((i) => i.isUrgent && i.status == IssueStatus.open).toList();
}
