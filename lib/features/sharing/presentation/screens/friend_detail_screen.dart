import 'package:flutter/material.dart';

/// Screen displaying detailed statistics for a specific friend.
///
/// Shows:
/// - Friend's profile info
/// - Today's step count and progress
/// - Weekly trends comparison
/// - Historical data
class FriendDetailScreen extends StatelessWidget {
  const FriendDetailScreen({
    super.key,
    required this.friendId,
  });

  /// The ID of the friend to display.
  final String friendId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Friend Profile',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $friendId',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed friend stats coming soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
