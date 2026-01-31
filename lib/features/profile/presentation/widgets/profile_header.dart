/// Profile header widget displaying user avatar and information.
///
/// This widget shows the user's avatar, name, and email in a
/// centered column layout at the top of the profile page.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays the user's profile header information.
///
/// Shows a large avatar with the user's name and email below it.
/// The avatar displays initials derived from the user's name.
///
/// Example usage:
/// ```dart
/// ProfileHeader(user: currentUser)
/// ```
class ProfileHeader extends StatelessWidget {
  /// Creates a [ProfileHeader] widget.
  ///
  /// [user] - The user whose profile information to display.
  const ProfileHeader({required this.user, super.key});

  /// The user whose profile information to display.
  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AvatarWidget(name: user.name, size: 100),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
