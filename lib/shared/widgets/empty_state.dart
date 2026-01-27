/// Empty state widget for displaying when no content is available.
///
/// This widget provides a consistent empty state display with icon,
/// title, message, and optional action widget.
library;

import 'package:flutter/material.dart';

/// A widget that displays an empty state with optional action.
///
/// Shows an icon, optional title, message, and optional action widget
/// using subtle theme colors for a non-intrusive appearance.
///
/// Example usage:
/// ```dart
/// // Basic empty state
/// EmptyState(message: 'No items found')
///
/// // With title and action
/// EmptyState(
///   title: 'No Messages',
///   message: 'You have no messages yet',
///   action: FilledButton(
///     onPressed: () => startNewConversation(),
///     child: Text('Start a conversation'),
///   ),
/// )
///
/// // Custom icon
/// EmptyState(
///   icon: Icons.search_off,
///   message: 'No results match your search',
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an empty state display widget.
  ///
  /// The [message] parameter is required and describes the empty state.
  /// The [title] is optional and displayed above the message.
  /// The [icon] defaults to [Icons.inbox_outlined].
  /// The [action] is an optional widget displayed below the message.
  const EmptyState({
    required this.message,
    super.key,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  /// The message describing the empty state.
  ///
  /// This is displayed below the title (if provided) with secondary styling.
  final String message;

  /// Optional title displayed above the message.
  ///
  /// When null, only the message is displayed.
  final String? title;

  /// The icon displayed above the title/message.
  ///
  /// Defaults to [Icons.inbox_outlined].
  final IconData icon;

  /// Optional action widget displayed below the message.
  ///
  /// Typically a button that allows the user to take action
  /// to change the empty state (e.g., create new item, refresh).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Title (if provided)
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Action widget (if provided)
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
