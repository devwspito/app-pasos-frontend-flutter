/// Member contribution tile widget for displaying member stats.
///
/// This widget shows a member's contribution to a group goal including
/// their avatar, name, steps contributed, and a visual progress bar.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/member_contribution.dart';
import 'package:app_pasos_frontend/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A tile widget that displays a member's contribution to a goal.
///
/// Shows the member's avatar, name, total steps contributed, and
/// a horizontal progress bar representing their contribution percentage.
///
/// Example usage:
/// ```dart
/// MemberContributionTile(
///   contribution: memberContribution,
///   onTap: () => navigateToMemberProfile(),
/// )
/// ```
class MemberContributionTile extends StatelessWidget {
  /// Creates a [MemberContributionTile].
  ///
  /// The [contribution] parameter is required.
  const MemberContributionTile({
    required this.contribution,
    this.onTap,
    this.avatarUrl,
    super.key,
  });

  /// The member contribution data to display.
  final MemberContribution contribution;

  /// Optional callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Optional URL for the member's avatar image.
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Avatar
          AvatarWidget(
            imageUrl: avatarUrl,
            name: contribution.userName,
          ),
          const SizedBox(width: 12),

          // Name and contribution info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contribution.userName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatSteps(contribution.totalSteps),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar with percentage
                Row(
                  children: [
                    Expanded(
                      child: _ContributionProgressBar(
                        percentage: contribution.contributionPercentage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        _formatPercentage(contribution.contributionPercentage),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }

  /// Formats a percentage value with one decimal place.
  String _formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Formats step count with K/M suffix for readability.
  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      final m = steps / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (steps >= 1000) {
      final k = steps / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return steps.toString();
  }
}

/// A horizontal progress bar showing contribution percentage.
class _ContributionProgressBar extends StatelessWidget {
  const _ContributionProgressBar({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Clamp to 0-100 range
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final progressRatio = clampedPercentage / 100.0;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progressRatio,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
