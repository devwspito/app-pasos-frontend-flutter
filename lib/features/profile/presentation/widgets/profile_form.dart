/// Profile form widget for editing user profile information.
///
/// This widget provides a form with text fields for name and email,
/// along with edit, cancel, and save buttons for managing profile updates.
library;

import 'package:app_pasos_frontend/shared/widgets/app_button.dart';
import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// A form widget for editing user profile information.
///
/// Displays name and email text fields that can be toggled between
/// view and edit modes. In edit mode, provides cancel and save buttons.
/// In view mode, shows an edit button.
///
/// Example usage:
/// ```dart
/// ProfileForm(
///   nameController: _nameController,
///   emailController: _emailController,
///   isEditing: _isEditing,
///   isLoading: _isUpdating,
///   onEdit: _handleEdit,
///   onCancel: _handleCancel,
///   onSave: _handleSave,
/// )
/// ```
class ProfileForm extends StatelessWidget {
  /// Creates a [ProfileForm] widget.
  ///
  /// All parameters are required for proper form functionality.
  const ProfileForm({
    required this.nameController,
    required this.emailController,
    required this.isEditing,
    required this.isLoading,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  /// Controller for the name text field.
  final TextEditingController nameController;

  /// Controller for the email text field.
  final TextEditingController emailController;

  /// Whether the form is in editing mode.
  ///
  /// When true, text fields are enabled and save/cancel buttons are shown.
  /// When false, text fields are disabled and edit button is shown.
  final bool isEditing;

  /// Whether a save operation is in progress.
  ///
  /// When true, buttons are disabled and save button shows loading indicator.
  final bool isLoading;

  /// Callback invoked when the edit button is pressed.
  final VoidCallback onEdit;

  /// Callback invoked when the cancel button is pressed.
  final VoidCallback onCancel;

  /// Callback invoked when the save button is pressed.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: nameController,
          labelText: 'Name',
          prefixIcon: Icons.person_outline,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          enabled: isEditing,
        ),
        const SizedBox(height: 24),
        if (!isEditing)
          AppButton(
            text: 'Edit Profile',
            onPressed: onEdit,
            leadingIcon: Icons.edit,
            fullWidth: true,
          )
        else
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  onPressed: isLoading ? null : onCancel,
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Save',
                  onPressed: isLoading ? null : onSave,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
