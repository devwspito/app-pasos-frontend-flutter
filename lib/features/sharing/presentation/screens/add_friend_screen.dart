import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// Screen for adding a new friend via email.
///
/// Features:
/// - Email input field with validation
/// - Permission checkboxes for sharing settings
/// - Send request functionality with success/error feedback
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/friends/add',
///   builder: (context, state) => const AddFriendScreen(),
/// )
/// ```
class AddFriendScreen extends ConsumerStatefulWidget {
  /// Creates an [AddFriendScreen].
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  // Permission checkboxes
  bool _shareSteps = true;
  bool _shareGoals = true;
  bool _shareStats = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendRequest() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      // TODO: Call provider to send friend request
      // await ref.read(sharingProvider.notifier).sendFriendRequest(
      //   email: email,
      //   permissions: FriendPermissions(
      //     canViewSteps: _shareSteps,
      //     canViewGoals: _shareGoals,
      //     canViewStats: _shareStats,
      //   ),
      // );

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSuccessDialog(email);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: const Text('Request Sent!'),
        content: Text(
          'Your friend request has been sent to $email. '
          'They will be notified and can accept your request.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _emailController.clear();
              _emailFocusNode.requestFocus();
            },
            child: const Text('Add Another'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allMd,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header text
              Text(
                'Send a friend request',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Enter the email address of the person you want to add as a friend.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Error message
              if (_errorMessage != null) ...[
                _buildErrorBanner(colorScheme, textTheme),
                SizedBox(height: AppSpacing.md),
              ],

              // Email input
              _buildEmailInput(colorScheme, textTheme),
              SizedBox(height: AppSpacing.lg),

              // Permissions section
              _buildPermissionsSection(colorScheme, textTheme),
              SizedBox(height: AppSpacing.xl),

              // Send request button
              AppButton(
                label: 'Send Request',
                onPressed: _handleSendRequest,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: colorScheme.onErrorContainer,
            ),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput(ColorScheme colorScheme, TextTheme textTheme) {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'friend@example.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      validator: Validators.email,
      onFieldSubmitted: (_) => _handleSendRequest(),
    );
  }

  Widget _buildPermissionsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return AppCard(
      elevation: AppCardElevation.flat,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'What to Share',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Choose what your friend can see about you',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Permission checkboxes
          _buildPermissionCheckbox(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.directions_walk_rounded,
            title: 'Daily Steps',
            subtitle: 'Share your daily step count',
            value: _shareSteps,
            onChanged: _isLoading
                ? null
                : (v) => setState(() => _shareSteps = v ?? false),
          ),
          _buildPermissionCheckbox(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.flag_rounded,
            title: 'Goal Progress',
            subtitle: 'Share your goal completion',
            value: _shareGoals,
            onChanged: _isLoading
                ? null
                : (v) => setState(() => _shareGoals = v ?? false),
          ),
          _buildPermissionCheckbox(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.bar_chart_rounded,
            title: 'Weekly Statistics',
            subtitle: 'Share your weekly trends',
            value: _shareStats,
            onChanged: _isLoading
                ? null
                : (v) => setState(() => _shareStats = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCheckbox({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onChanged != null ? () => onChanged(!value) : null,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(
                icon,
                size: 20,
                color: value
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
