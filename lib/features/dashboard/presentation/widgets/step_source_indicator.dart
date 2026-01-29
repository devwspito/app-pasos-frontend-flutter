/// Step source indicator widget for displaying the data source type.
///
/// This widget shows a compact indicator with an icon and optional label
/// representing where the step data originated from.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:flutter/material.dart';

/// A compact widget that displays the source of step data.
///
/// Shows an icon and optional label indicating whether steps came from
/// native health sensors, manual entry, or web sync.
///
/// Features:
/// - Different icons for each [StepSource] value
/// - Optional text label (controlled by [showLabel])
/// - Compact chip-like styling using theme colors
/// - Suitable for embedding in cards or list items
///
/// Example usage:
/// ```dart
/// // Full indicator with icon and label
/// StepSourceIndicator(source: StepSource.native)
///
/// // Icon only (no label)
/// StepSourceIndicator(
///   source: StepSource.manual,
///   showLabel: false,
/// )
/// ```
class StepSourceIndicator extends StatelessWidget {
  /// Creates a [StepSourceIndicator].
  ///
  /// [source] - The source type of the step data.
  /// [showLabel] - Whether to show the text label (defaults to true).
  const StepSourceIndicator({
    required this.source,
    this.showLabel = true,
    super.key,
  });

  /// The source of the step data to display.
  final StepSource source;

  /// Whether to show the text label alongside the icon.
  ///
  /// When false, only the icon is displayed for a more compact view.
  final bool showLabel;

  /// Returns the appropriate icon for the current [source].
  IconData get _icon => switch (source) {
        StepSource.native => Icons.favorite,
        StepSource.manual => Icons.edit,
        StepSource.web => Icons.computer,
      };

  /// Returns the label text for the current [source].
  String get _label => switch (source) {
        StepSource.native => 'Health Connected',
        StepSource.manual => 'Manual Entry',
        StepSource.web => 'Web Sync',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 16,
            color: colorScheme.onSecondaryContainer,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
