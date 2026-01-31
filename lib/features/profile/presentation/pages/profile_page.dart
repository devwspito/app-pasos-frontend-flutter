/// Profile page for displaying and editing user profile.
///
/// This page allows users to view and edit their profile information.
/// It uses the ProfileBloc for state management and provides form
/// validation using the Validators class.
library;

import 'package:app_pasos_frontend/core/utils/validators.dart';
import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Profile page for displaying and editing user profile.
///
/// Displays the user's profile information and allows editing.
/// On successful update, shows a success snackbar. Shows error messages
/// via snackbars on failure with retry option via RefreshIndicator.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: RouteNames.profile,
///   builder: (context, state) => const ProfilePage(),
/// )
/// ```
class ProfilePage extends StatefulWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    // Load profile data when page is created
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateControllersFromUser(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            ProfileUpdateRequested(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  void _handleCancel() {
    context.read<ProfileBloc>().add(const ProfileCancelEditRequested());
  }

  void _handleEdit() {
    context.read<ProfileBloc>().add(const ProfileEditModeToggled());
  }

  Future<void> _handleRefresh() async {
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              // Show edit button only when loaded and not editing
              if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _handleEdit,
                  tooltip: 'Edit Profile',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Theme.of(context).colorScheme.onError,
                  onPressed: _handleRefresh,
                ),
              ),
            );
          } else if (state is ProfileEditing) {
            // Update controllers when entering edit mode
            _updateControllersFromUser(state.user);
          } else if (state is ProfileLoaded) {
            // Update controllers when profile is loaded
            _updateControllersFromUser(state.user);
          }
        },
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileLoaded(:final user) => _buildProfileView(user),
            ProfileEditing(:final user) => _buildEditForm(user),
            ProfileUpdateSuccess(:final user) => _buildProfileView(user),
            ProfileError(:final user) => user != null
                ? _buildProfileView(user)
                : _buildErrorView(state.message),
          };
        },
      ),
    );
  }

  /// Formats a DateTime to a human-readable date string.
  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildProfileView(User user) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _buildProfileField(
              label: 'Name',
              value: user.name,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Email
            _buildProfileField(
              label: 'Email',
              value: user.email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            // Join Date
            if (user.createdAt != null)
              _buildProfileField(
                label: 'Member Since',
                value: _formatDate(user.createdAt!),
                icon: Icons.calendar_today_outlined,
              ),
            const SizedBox(height: 32),

            // Edit Button
            FilledButton.icon(
              onPressed: _handleEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => Validators.required(value, 'Name'),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _handleSave,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            OutlinedButton(
              onPressed: _handleCancel,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _handleRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
