// lib/features/admin/screens/admin_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/status_pill.dart';
import '../../issues/providers/issue_providers.dart';
import '../../issues/repositories/issue_repository.dart';
import '../../issues/models/issue.dart';
import '../../issues/models/issue_status.dart';

class AdminMapScreen extends ConsumerStatefulWidget {
  const AdminMapScreen({super.key});
  @override
  ConsumerState<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends ConsumerState<AdminMapScreen> {
  IssueStatus? _filterStatus;
  Issue? _selectedIssue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.watch(issueRepositoryProvider);
    final allIssues = repo.fetchAllIssues(
      filters: _filterStatus != null
          ? IssueFilters(status: _filterStatus)
          : null,
    );

    return Stack(
      children: [
        Column(
          children: [
            // Filter row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_rounded, color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Issue Map', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: scheme.primaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(100)),
                        child: Text('${allIssues.length} issues', style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterStatus == null,
                          showCheckmark: false,
                          onSelected: (_) => setState(() { _filterStatus = null; _selectedIssue = null; }),
                        ),
                        ...IssueStatus.values.map((s) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(s.label),
                            selected: _filterStatus == s,
                            showCheckmark: false,
                            onSelected: (_) => setState(() { _filterStatus = _filterStatus == s ? null : s; _selectedIssue = null; }),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Map canvas
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRRect(
                    child: Stack(
                      children: [
                        // Grid background
                        Container(
                          color: scheme.brightness == Brightness.dark
                              ? const Color(0xFF1A2639)
                              : const Color(0xFFE8F2F8),
                          child: CustomPaint(
                            painter: _MapGridPainter(color: scheme.outlineVariant.withOpacity(0.3)),
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                          ),
                        ),

                        // Road lines (decorative)
                        CustomPaint(
                          painter: _RoadPainter(),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),

                        // Pin widgets
                        ...allIssues.map((issue) {
                          final pos = _mockPosition(issue, constraints.maxWidth, constraints.maxHeight);
                          return Positioned(
                            left: pos.dx - 16,
                            top: pos.dy - 16,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedIssue = issue),
                              child: _MapPin(issue: issue, isSelected: _selectedIssue?.id == issue.id),
                            ),
                          );
                        }),

                        // Legend
                        Positioned(
                          bottom: 16, left: 16,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: scheme.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...IssueStatus.values.map((s) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _pinColor(s),
                                      const SizedBox(width: 6),
                                      Text(s.label, style: const TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // Preview bottom sheet when pin selected
        if (_selectedIssue != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _IssuePreviewSheet(
              issue: _selectedIssue!,
              onClose: () => setState(() => _selectedIssue = null),
            ),
          ),
      ],
    );
  }

  Offset _mockPosition(Issue issue, double width, double height) {
    // Deterministic pseudo-random position based on issue id
    final hash = issue.id.hashCode.abs();
    final x = 40.0 + (hash % 1000) / 1000.0 * (width - 80);
    final y = 40.0 + ((hash ~/ 1000) % 1000) / 1000.0 * (height - 120);
    return Offset(x, y);
  }

  Widget _pinColor(IssueStatus s) {
    final color = _statusColor(s);
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Color _statusColor(IssueStatus s) {
    switch (s) {
      case IssueStatus.open: return const Color(0xFFE53935);
      case IssueStatus.inProgress: return const Color(0xFFF57C00);
      case IssueStatus.resolved: return const Color(0xFF2E7D32);
      case IssueStatus.rejected: return const Color(0xFF616161);
    }
  }
}

class _MapPin extends StatelessWidget {
  final Issue issue;
  final bool isSelected;
  const _MapPin({required this.issue, required this.isSelected});

  Color _color() {
    switch (issue.status) {
      case IssueStatus.open: return const Color(0xFFE53935);
      case IssueStatus.inProgress: return const Color(0xFFF57C00);
      case IssueStatus.resolved: return const Color(0xFF2E7D32);
      case IssueStatus.rejected: return const Color(0xFF616161);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 40 : 32,
      height: isSelected ? 40 : 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 12 : 6,
          ),
        ],
      ),
      child: Icon(issue.category.icon, size: isSelected ? 20 : 16, color: Colors.white),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Color color;
  const _MapGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.2)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), paint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IssuePreviewSheet extends StatelessWidget {
  final Issue issue;
  final VoidCallback onClose;
  const _IssuePreviewSheet({required this.issue, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: issue.category.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(issue.category.icon, color: issue.category.color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(issue.category.name, style: TextStyle(fontSize: 11, color: issue.category.color, fontWeight: FontWeight.w600)),
                    Text(issue.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(issue.location.displayName, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: onClose, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusPill(status: issue.status),
              const Spacer(),
              Text(issue.id, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
