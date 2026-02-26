// lib/core/widgets/issue_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../features/issues/models/issue.dart';
import 'status_pill.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final bool isAdmin;
  final VoidCallback? onTap;

  const IssueCard({
    super.key,
    required this.issue,
    this.isAdmin = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cat = issue.category;
    final timeStr = _formatTime(issue.createdAt);

    return Semantics(
      label: '${issue.title}, ${issue.status.label}, ${issue.location.displayName}',
      button: true,
      child: GestureDetector(
        onTap: onTap ??
            () {
              final path = isAdmin
                  ? '/admin/issue/${issue.id}'
                  : '/citizen/issue/${issue.id}';
              context.push(path);
            },
        child: Hero(
          tag: 'issue_${issue.id}',
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: issue.isUrgent
                      ? Colors.red.withOpacity(0.3)
                      : scheme.outlineVariant.withOpacity(0.2),
                  width: issue.isUrgent ? 1.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Urgent banner
                    if (issue.isUrgent)
                      Container(
                        width: double.infinity,
                        color: Colors.red.shade50,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.warning_rounded, size: 12, color: Colors.red.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category icon
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cat.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(cat.icon, size: 18, color: cat.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cat.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      issue.title,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusPill(status: issue.status, compact: true),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Description
                          Text(
                            issue.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),

                          const SizedBox(height: 10),

                          // Footer row
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 12, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  issue.location.displayName,
                                  style: Theme.of(context).textTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.schedule_rounded, size: 12, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Text(
                                timeStr,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),

                          if (isAdmin) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_rounded, size: 12, color: scheme.onSurfaceVariant),
                                const SizedBox(width: 3),
                                Text(
                                  issue.reporterName,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_upward_rounded, size: 10, color: scheme.primary),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${issue.upvotes}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: scheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 7) return DateFormat('d MMM y').format(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
