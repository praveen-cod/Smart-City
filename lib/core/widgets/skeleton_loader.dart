// lib/core/widgets/skeleton_loader.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A3344) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF3D4F66) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class IssueCardSkeleton extends StatelessWidget {
  const IssueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 32, height: 32, radius: 100),
              const SizedBox(width: 10),
              Expanded(child: const SkeletonBox(height: 14, radius: 6)),
              const SizedBox(width: 8),
              const SkeletonBox(width: 70, height: 22, radius: 100),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonBox(height: 16, radius: 6),
          const SizedBox(height: 6),
          const SkeletonBox(height: 14, radius: 6, width: 200),
          const SizedBox(height: 12),
          Row(
            children: const [
              SkeletonBox(width: 100, height: 12, radius: 6),
              SizedBox(width: 8),
              SkeletonBox(width: 80, height: 12, radius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (context, index) => const IssueCardSkeleton(),
    );
  }
}

class KpiCardSkeleton extends StatelessWidget {
  const KpiCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 32, height: 32, radius: 8),
          SizedBox(height: 12),
          SkeletonBox(height: 28, radius: 6),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 12, radius: 6),
        ],
      ),
    );
  }
}
