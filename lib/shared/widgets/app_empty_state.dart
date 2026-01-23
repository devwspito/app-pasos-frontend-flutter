import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A reusable empty state widget that provides consistent styling
/// across the app with Material 3 design.
///
/// Features:
/// - Customizable icon, title, and description
/// - Optional action button for user actions
/// - Centered layout suitable for full-screen or inline use
///
/// Usage:
/// ```dart
/// AppEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No messages',
///   description: 'Your inbox is empty',
/// )
/// ```
///
/// With action button:
/// ```dart
/// AppEmptyState(
///   icon: Icons.search_off,
///   title: 'No results found',
///   description: 'Try adjusting your search or filters',
///   actionLabel: 'Clear Filters',
///   onAction: () => clearFilters(),
/// )
/// ```
///
/// Custom appearance:
/// ```dart
/// AppEmptyState(
///   icon: Icons.cloud_off,
///   iconSize: 64.0,
///   iconColor: Colors.grey,
///   title: 'Offline',
///   description: 'Check your connection',
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  /// Creates an [AppEmptyState] widget.
  ///
  /// The [icon], [title], and [description] parameters are required.
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconSize,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.padding,
    this.compact = false,
  });

  /// The icon to display.
  final IconData icon;

  /// The title text.
  final String title;

  /// The description text.
  final String description;

  /// The size of the icon.
  /// When null, defaults to 64.0 (or 48.0 in compact mode).
  final double? iconSize;

  /// The color of the icon.
  /// When null, uses the theme's onSurfaceVariant color.
  final Color? iconColor;

  /// The label for the action button.
  /// When null (along with [onAction]), no button is displayed.
  final String? actionLabel;

  /// Callback when the action button is pressed.
  /// When null (along with [actionLabel]), no button is displayed.
  final VoidCallback? onAction;

  /// Optional icon for the action button.
  final IconData? actionIcon;

  /// The padding around the empty state widget.
  /// When null, uses [AppSpacing.xl].
  final EdgeInsetsGeometry? padding;

  /// Whether to use a more compact layout.
  /// When true, uses smaller spacing and icon size.
  /// Defaults to false.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectivePadding = padding ?? EdgeInsets.all(
      compact ? AppSpacing.md : AppSpacing.xl,
    );
    final effectiveIconSize = iconSize ?? (compact ? 48.0 : 64.0);
    final effectiveIconColor = iconColor ?? colorScheme.onSurfaceVariant;

    return Padding(
      padding: effectivePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: effectiveIconSize,
              color: effectiveIconColor,
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
            Text(
              title,
              style: (compact
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleLarge)?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              description,
              style: (compact
                  ? theme.textTheme.bodySmall
                  : theme.textTheme.bodyMedium)?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              if (actionIcon != null)
                FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                )
              else
                FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Factory methods for common empty state scenarios.
extension AppEmptyStateFactories on AppEmptyState {
  /// Creates an empty state for "no items" scenario.
  static AppEmptyState noItems({
    Key? key,
    String title = 'No items',
    String description = 'There are no items to display',
    IconData icon = Icons.inbox_outlined,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? actionIcon,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      actionIcon: actionIcon,
      compact: compact,
    );
  }

  /// Creates an empty state for "no search results" scenario.
  static AppEmptyState noSearchResults({
    Key? key,
    String title = 'No results found',
    String description = 'Try adjusting your search criteria',
    IconData icon = Icons.search_off,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? actionIcon,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      actionIcon: actionIcon,
      compact: compact,
    );
  }

  /// Creates an empty state for "offline" scenario.
  static AppEmptyState offline({
    Key? key,
    String title = 'You\'re offline',
    String description = 'Check your internet connection and try again',
    IconData icon = Icons.cloud_off_outlined,
    String? actionLabel = 'Retry',
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      actionIcon: Icons.refresh,
      compact: compact,
    );
  }

  /// Creates an empty state for "no favorites" scenario.
  static AppEmptyState noFavorites({
    Key? key,
    String title = 'No favorites yet',
    String description = 'Items you favorite will appear here',
    IconData icon = Icons.favorite_border,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? actionIcon,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      actionIcon: actionIcon,
      compact: compact,
    );
  }

  /// Creates an empty state for "no notifications" scenario.
  static AppEmptyState noNotifications({
    Key? key,
    String title = 'All caught up!',
    String description = 'You have no new notifications',
    IconData icon = Icons.notifications_none,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      icon: icon,
      title: title,
      description: description,
      compact: compact,
    );
  }
}

/// A widget that displays different content based on the data state.
///
/// Usage:
/// ```dart
/// StateRenderer(
///   isLoading: isLoading,
///   isEmpty: items.isEmpty,
///   hasError: error != null,
///   errorMessage: error,
///   emptyIcon: Icons.inbox_outlined,
///   emptyTitle: 'No items',
///   emptyDescription: 'Add items to get started',
///   onRetry: () => loadData(),
///   onEmptyAction: () => addItem(),
///   emptyActionLabel: 'Add Item',
///   child: ListView.builder(...),
/// )
/// ```
class StateRenderer extends StatelessWidget {
  /// Creates a [StateRenderer] widget.
  const StateRenderer({
    super.key,
    required this.child,
    this.isLoading = false,
    this.isEmpty = false,
    this.hasError = false,
    this.errorMessage,
    this.errorTitle,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'No items',
    this.emptyDescription = 'There are no items to display',
    this.loadingMessage,
    this.onRetry,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.emptyActionIcon,
    this.compact = false,
  });

  /// The main content to display when data is available.
  final Widget child;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Whether the data set is empty.
  final bool isEmpty;

  /// Whether an error occurred.
  final bool hasError;

  /// The error message to display.
  final String? errorMessage;

  /// The error title to display.
  final String? errorTitle;

  /// The icon for the empty state.
  final IconData emptyIcon;

  /// The title for the empty state.
  final String emptyTitle;

  /// The description for the empty state.
  final String emptyDescription;

  /// The message to display during loading.
  final String? loadingMessage;

  /// Callback for retry on error.
  final VoidCallback? onRetry;

  /// Callback for action on empty state.
  final VoidCallback? onEmptyAction;

  /// Label for empty state action button.
  final String? emptyActionLabel;

  /// Icon for empty state action button.
  final IconData? emptyActionIcon;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Import app_loading.dart is not needed here as we're creating widgets inline
    // This keeps the file self-contained while following existing patterns

    if (hasError) {
      return _buildErrorState(context);
    }

    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (isEmpty) {
      return AppEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        description: emptyDescription,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
        actionIcon: emptyActionIcon,
        compact: compact,
      );
    }

    return child;
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: compact ? 24.0 : 36.0,
            height: compact ? 24.0 : 36.0,
            child: CircularProgressIndicator(
              strokeWidth: compact ? 2.0 : 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          if (loadingMessage != null) ...[
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
            Text(
              loadingMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: compact ? 32.0 : 48.0,
              color: colorScheme.error,
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
            if (errorTitle != null) ...[
              Text(
                errorTitle!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              errorMessage ?? 'An error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
