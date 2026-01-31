/// Profile page for viewing and editing user profile information.
///
/// This page displays the user's profile with their avatar, name, and email.
/// Users can edit their profile information using the built-in form.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_state.dart';
import 'package:app_pasos_frontend/features/profile/presentation/widgets/profile_form.dart';
import 'package:app_pasos_frontend/features/profile/presentation/widgets/profile_header.dart';
import 'package:app_pasos_frontend/shared/widgets/app_scaffold.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The main profile page widget.
///
/// Displays the user's profile information with the ability to edit
/// name and email. Uses [ProfileBloc] for state management.
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.profile,
///   name: 'profile',
///   builder: (context, state) => BlocProvider(
///     create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
///     child: const ProfilePage(),
///   ),
/// )
/// ```
class ProfilePage extends StatefulWidget {
  /// Creates a [ProfilePage] widget.
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Whether the user is currently editing their profile.
  bool _isEditing = false;

  /// Controller for the name text field.
  late TextEditingController _nameController;

  /// Controller for the email text field.
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Called when the edit button is pressed.
  ///
  /// Enables editing mode and populates the text controllers with
  /// the current user's data.
  void _onEditPressed(User user) {
    setState(() {
      _isEditing = true;
      _nameController.text = user.name;
      _emailController.text = user.email;
    });
  }

  /// Called when the cancel button is pressed.
  ///
  /// Disables editing mode and reverts the text controllers to
  /// the original user data.
  void _onCancelPressed(User user) {
    setState(() {
      _isEditing = false;
      _nameController.text = user.name;
      _emailController.text = user.email;
    });
  }

  /// Called when the save button is pressed.
  ///
  /// Dispatches a [ProfileUpdateRequested] event to the bloc with
  /// the updated name and email values.
  void _onSavePressed() {
    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            name: _nameController.text,
            email: _emailController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            setState(() => _isEditing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() || ProfileLoading() => const LoadingIndicator(),
            ProfileLoaded(:final user) ||
            ProfileUpdating(:final user) ||
            ProfileUpdateSuccess(:final user) =>
              _buildContent(user, state is ProfileUpdating),
            ProfileError(:final message) => _buildErrorContent(message),
          };
        },
      ),
    );
  }

  /// Builds the main profile content with header and form.
  Widget _buildContent(User user, bool isUpdating) {
    // Initialize controllers with user data if not editing
    if (!_isEditing) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: 32),
          ProfileForm(
            nameController: _nameController,
            emailController: _emailController,
            isEditing: _isEditing,
            isLoading: isUpdating,
            onEdit: () => _onEditPressed(user),
            onCancel: () => _onCancelPressed(user),
            onSave: _onSavePressed,
          ),
        ],
      ),
    );
  }

  /// Builds the error content when profile loading fails.
  Widget _buildErrorContent(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
