import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

/// A widget that displays an empty state with optional action.
///
/// Use this widget to show empty content states with a consistent design
/// throughout the application. It supports customizable icons, titles,
/// messages, and action buttons.
///
/// Example:
/// ```dart
/// // Basic empty state
/// AppEmptyState(message: 'No items found')
///
/// // Empty state with action
/// AppEmptyState(
///   icon: Icons.search_off,
///   title: 'No Results',
///   message: 'Try adjusting your search criteria',
///   actionLabel: 'Clear Filters',
///   onAction: () => clearFilters(),
/// )
///
/// // Custom child widget
/// AppEmptyState(
///   message: 'Your cart is empty',
///   child: Image.asset('assets/empty_cart.png'),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  /// Creates an empty state widget with the specified parameters.
  ///
  /// [message] is required and describes the empty state.
  /// [icon] overrides the default inbox icon.
  /// [title] adds an optional title above the message.
  /// [actionLabel] and [onAction] together show an action button.
  /// [child] allows for a completely custom widget above the text.
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
    this.child,
  });

  /// The message to display describing the empty state.
  final String message;

  /// The icon to display above the title/message.
  ///
  /// Defaults to [Icons.inbox_outlined].
  final IconData? icon;

  /// Optional title text above the message.
  final String? title;

  /// The label for the action button.
  ///
  /// If both [actionLabel] and [onAction] are provided,
  /// an action button is shown.
  final String? actionLabel;

  /// Callback invoked when the action button is pressed.
  ///
  /// If both [actionLabel] and [onAction] are provided,
  /// an action button is shown.
  final VoidCallback? onAction;

  /// Custom widget to display instead of the default icon.
  ///
  /// When provided, this widget is shown above the title/message
  /// instead of the icon.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (child != null)
              child!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80.0,
                color: mutedColor,
              ),
            const SizedBox(height: AppSpacing.lg),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
