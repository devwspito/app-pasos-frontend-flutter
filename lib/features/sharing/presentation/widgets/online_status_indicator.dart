/// Online status indicator widget for App Pasos.
///
/// This widget provides a visual indicator for user online/offline status.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A circular indicator that displays the online/offline status of a user.
///
/// The indicator uses the app's success color for online status and
/// outline variant color for offline status. It includes a white border
/// for better visibility against various backgrounds.
///
/// Example usage:
/// ```dart
/// OnlineStatusIndicator(
///   isOnline: user.isOnline,
///   size: 12,
/// )
/// ```
class OnlineStatusIndicator extends StatelessWidget {
  /// Creates an [OnlineStatusIndicator].
  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
  });

  /// Whether the user is currently online.
  ///
  /// When true, displays the success color (green).
  /// When false, displays the outline variant color (gray).
  final bool isOnline;

  /// Diameter of the status indicator.
  ///
  /// Defaults to 12.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? AppColors.success : colorScheme.outlineVariant,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}
