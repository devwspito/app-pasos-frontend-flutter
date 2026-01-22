import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_button.dart';

/// A reusable empty state widget following Material Design 3 guidelines.
///
/// Displays a message when there is no content to show, with optional
/// illustration, title, description, and action button.
///
/// Example usage:
/// ```dart
/// EmptyStateWidget(
///   title: 'No items yet',
///   description: 'Add your first item to get started',
///   icon: Icons.inbox_outlined,
///   actionLabel: 'Add Item',
///   onAction: () => addNewItem(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Creates an EmptyStateWidget.
  const EmptyStateWidget({
    this.title,
    this.description,
    this.icon,
    this.iconSize = 64.0,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
    super.key,
  });

  /// The main title text
  final String? title;

  /// Descriptive text below the title
  final String? description;

  /// Icon to display (ignored if illustration is provided)
  final IconData? icon;

  /// Size of the icon
  final double iconSize;

  /// Custom illustration widget (takes precedence over icon)
  final Widget? illustration;

  /// Label for the primary action button
  final String? actionLabel;

  /// Callback for the primary action button
  final VoidCallback? onAction;

  /// Label for the secondary action button
  final String? secondaryActionLabel;

  /// Callback for the secondary action button
  final VoidCallback? onSecondaryAction;

  /// Whether to use a compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactLayout(context);
    }
    return _buildFullLayout(context);
  }

  Widget _buildCompactLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              size: AppSpacing.iconLg,
            ),
          if (icon != null) SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                if (description != null)
                  Text(
                    description!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or icon
            if (illustration != null)
              illustration!
            else if (icon != null)
              _buildIconContainer(colorScheme),

            if (illustration != null || icon != null)
              SizedBox(height: AppSpacing.lg),

            // Title
            if (title != null)
              Text(
                title!,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

            if (title != null && description != null)
              SizedBox(height: AppSpacing.sm),

            // Description
            if (description != null)
              Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

            // Primary action button
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.primary,
              ),
            ],

            // Secondary action button
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              SizedBox(height: AppSpacing.sm),
              AppButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                variant: AppButtonVariant.text,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(ColorScheme colorScheme) {
    return Container(
      width: iconSize * 1.75,
      height: iconSize * 1.75,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        size: iconSize,
      ),
    );
  }
}

/// Pre-configured empty state for no search results.
class NoSearchResultsWidget extends StatelessWidget {
  /// Creates a NoSearchResultsWidget.
  const NoSearchResultsWidget({
    this.searchQuery,
    this.onClearSearch,
    super.key,
  });

  /// The search query that returned no results
  final String? searchQuery;

  /// Callback to clear the search
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final message = searchQuery != null
        ? 'No results found for "$searchQuery"'
        : 'No results found';

    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No results',
      description: message,
      actionLabel: onClearSearch != null ? 'Clear search' : null,
      onAction: onClearSearch,
    );
  }
}

/// Pre-configured empty state for no internet connection.
class NoConnectionWidget extends StatelessWidget {
  /// Creates a NoConnectionWidget.
  const NoConnectionWidget({
    this.onRetry,
    super.key,
  });

  /// Callback to retry connection
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'No connection',
      description: 'Check your internet connection and try again',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Pre-configured empty state for empty lists.
class EmptyListWidget extends StatelessWidget {
  /// Creates an EmptyListWidget.
  const EmptyListWidget({
    required this.itemName,
    this.onAdd,
    super.key,
  });

  /// Name of the items that are empty (e.g., "tasks", "messages")
  final String itemName;

  /// Callback to add a new item
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'No $itemName yet',
      description: 'Your $itemName will appear here',
      actionLabel: onAdd != null ? 'Add $itemName' : null,
      onAction: onAdd,
    );
  }
}

/// Pre-configured empty state for features coming soon.
class ComingSoonWidget extends StatelessWidget {
  /// Creates a ComingSoonWidget.
  const ComingSoonWidget({
    this.featureName,
    super.key,
  });

  /// Optional name of the upcoming feature
  final String? featureName;

  @override
  Widget build(BuildContext context) {
    final title = featureName != null ? '$featureName coming soon' : 'Coming soon';

    return EmptyStateWidget(
      icon: Icons.construction_rounded,
      title: title,
      description: 'This feature is under development and will be available soon',
    );
  }
}
