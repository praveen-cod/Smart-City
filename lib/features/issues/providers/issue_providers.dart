// lib/features/issues/providers/issue_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/issue_repository.dart';
import '../models/issue.dart';
import '../models/issue_status.dart';

final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepository();
});

// --- Filter State ---
class IssueFilterState {
  final IssueStatus? status;
  final String? categoryId;
  final String? wardNumber;
  final SortOrder sortOrder;

  const IssueFilterState({
    this.status,
    this.categoryId,
    this.wardNumber,
    this.sortOrder = SortOrder.latest,
  });

  IssueFilterState copyWith({
    IssueStatus? status,
    String? categoryId,
    String? wardNumber,
    SortOrder? sortOrder,
    bool clearStatus = false,
    bool clearCategory = false,
    bool clearWard = false,
  }) {
    return IssueFilterState(
      status: clearStatus ? null : (status ?? this.status),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      wardNumber: clearWard ? null : (wardNumber ?? this.wardNumber),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class IssueFilterNotifier extends StateNotifier<IssueFilterState> {
  IssueFilterNotifier() : super(const IssueFilterState());

  void setStatus(IssueStatus? status) {
    state = state.copyWith(
      clearStatus: status == null,
      status: status,
    );
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      clearCategory: categoryId == null,
      categoryId: categoryId,
    );
  }

  void setWard(String? wardNumber) {
    state = state.copyWith(
      clearWard: wardNumber == null,
      wardNumber: wardNumber,
    );
  }

  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void resetAll() {
    state = const IssueFilterState();
  }
}

final issueFilterProvider =
    StateNotifierProvider<IssueFilterNotifier, IssueFilterState>((ref) {
  return IssueFilterNotifier();
});

// --- All Issues ---
final allIssuesProvider = Provider<List<Issue>>((ref) {
  final repo = ref.watch(issueRepositoryProvider);
  final filters = ref.watch(issueFilterProvider);
  return repo.fetchAllIssues(
    filters: IssueFilters(
      status: filters.status,
      categoryId: filters.categoryId,
      wardNumber: filters.wardNumber,
    ),
    sort: filters.sortOrder,
  );
});

// --- My Issues filter ---
class MyIssueFilterNotifier extends StateNotifier<IssueFilterState> {
  MyIssueFilterNotifier() : super(const IssueFilterState());

  void setStatus(IssueStatus? status) {
    state = state.copyWith(clearStatus: status == null, status: status);
  }

  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }
}

final myIssueFilterProvider =
    StateNotifierProvider<MyIssueFilterNotifier, IssueFilterState>((ref) {
  return MyIssueFilterNotifier();
});

// --- Search ---
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void update(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

final searchResultsProvider = Provider<List<Issue>>((ref) {
  final repo = ref.watch(issueRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(issueFilterProvider);
  return repo.searchIssues(
    query,
    filters: IssueFilters(
      status: filters.status,
      categoryId: filters.categoryId,
    ),
  );
});

// --- Single Issue ---
final issueByIdProvider = Provider.family<Issue?, String>((ref, id) {
  final repo = ref.watch(issueRepositoryProvider);
  return repo.getIssueById(id);
});

// --- Loading simulation ---
final isLoadingProvider = StateProvider<bool>((ref) => true);
