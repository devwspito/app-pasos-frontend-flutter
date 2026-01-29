/// Edit goal page for updating existing group goals.
///
/// This page provides a form for users to edit existing group goals
/// with pre-populated values for name, description, target steps, and date range.
library;

import 'package:app_pasos_frontend/core/utils/validators.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/edit_goal_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/edit_goal_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/edit_goal_state.dart';
import 'package:app_pasos_frontend/shared/widgets/app_button.dart';
import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Edit goal page for updating existing group goals.
///
/// Features:
/// - Loading state while fetching existing goal data
/// - Goal form with pre-populated values and validation
/// - Loading state during submission
/// - Success/error feedback with snackbars
/// - Navigation back on success
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.editGoal,
///   builder: (context, state) {
///     final goalId = state.uri.queryParameters['goalId'] ?? '';
///     return BlocProvider(
///       create: (context) => EditGoalBloc(...)
///         ..add(EditGoalLoadRequested(goalId: goalId)),
///       child: EditGoalPage(goalId: goalId),
///     );
///   },
/// )
/// ```
class EditGoalPage extends StatelessWidget {
  /// Creates an [EditGoalPage].
  ///
  /// [goalId] - The ID of the goal being edited.
  const EditGoalPage({
    required this.goalId,
    super.key,
  });

  /// The ID of the goal being edited.
  final String goalId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<EditGoalBloc, EditGoalState>(
      listener: (context, state) {
        if (state is EditGoalSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Goal "${state.goal.name}" updated successfully!'),
              backgroundColor: colorScheme.primary,
            ),
          );
          // Navigate back to goal detail page
          context.pop();
        } else if (state is EditGoalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Goal'),
          centerTitle: true,
        ),
        body: BlocBuilder<EditGoalBloc, EditGoalState>(
          builder: (context, state) {
            return switch (state) {
              EditGoalInitial() => const LoadingIndicator(
                  message: 'Loading goal...',
                ),
              EditGoalLoading() => const LoadingIndicator(
                  message: 'Loading goal...',
                ),
              EditGoalLoaded(:final goal) => _EditGoalForm(
                  goal: goal,
                  isLoading: false,
                  goalId: goalId,
                ),
              EditGoalSubmitting(:final goal) => _EditGoalForm(
                  goal: goal,
                  isLoading: true,
                  goalId: goalId,
                ),
              EditGoalSuccess() => const LoadingIndicator(
                  message: 'Goal updated!',
                ),
              EditGoalError(:final goal) => goal != null
                  ? _EditGoalForm(
                      goal: goal,
                      isLoading: false,
                      goalId: goalId,
                    )
                  : _buildRetryView(context),
            };
          },
        ),
      ),
    );
  }

  /// Builds a retry view when goal loading fails.
  Widget _buildRetryView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load goal',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<EditGoalBloc>().add(
                      EditGoalLoadRequested(goalId: goalId),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal form widget for editing goals with pre-populated values.
class _EditGoalForm extends StatefulWidget {
  const _EditGoalForm({
    required this.goal,
    required this.isLoading,
    required this.goalId,
  });

  final GroupGoal goal;
  final bool isLoading;
  final String goalId;

  @override
  State<_EditGoalForm> createState() => _EditGoalFormState();
}

class _EditGoalFormState extends State<_EditGoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetStepsController;

  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _targetStepsFocusNode = FocusNode();

  late DateTime _startDate;
  late DateTime _endDate;

  /// Minimum target steps allowed.
  static const int _minTargetSteps = 1000;

  /// Maximum goal name length.
  static const int _maxNameLength = 50;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing goal values
    _nameController = TextEditingController(text: widget.goal.name);
    _descriptionController = TextEditingController(
      text: widget.goal.description ?? '',
    );
    _targetStepsController = TextEditingController(
      text: widget.goal.targetSteps.toString(),
    );
    _startDate = widget.goal.startDate;
    _endDate = widget.goal.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetStepsController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _targetStepsFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final description = _descriptionController.text.trim();
      context.read<EditGoalBloc>().add(
            EditGoalSubmitted(
              goalId: widget.goalId,
              name: _nameController.text.trim(),
              description: description.isEmpty ? null : description,
              targetSteps: int.parse(_targetStepsController.text.trim()),
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    }
  }

  String? _validateName(String? value) {
    final requiredError = Validators.required(value, 'Goal name');
    if (requiredError != null) return requiredError;

    final maxLengthError =
        Validators.maxLength(value, _maxNameLength, 'Goal name');
    if (maxLengthError != null) return maxLengthError;

    return null;
  }

  String? _validateTargetSteps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Target steps is required';
    }

    final steps = int.tryParse(value.trim());
    if (steps == null) {
      return 'Please enter a valid number';
    }

    if (steps < _minTargetSteps) {
      return 'Minimum target is $_minTargetSteps steps';
    }

    return null;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select start date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate)
          ? _endDate
          : _startDate.add(const Duration(days: 1)),
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: _startDate.add(const Duration(days: 365)),
      helpText: 'Select end date',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Goal name field
            AppTextField(
              controller: _nameController,
              labelText: 'Goal Name',
              hintText: 'Enter a name for your goal',
              prefixIcon: Icons.flag_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              focusNode: _nameFocusNode,
              onEditingComplete: _descriptionFocusNode.requestFocus,
              validator: _validateName,
            ),
            const SizedBox(height: 16),

            // Description field (optional)
            AppTextField(
              controller: _descriptionController,
              labelText: 'Description (optional)',
              hintText: 'Add a description for your goal',
              prefixIcon: Icons.description_outlined,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLines: 3,
              enabled: !widget.isLoading,
              focusNode: _descriptionFocusNode,
              onEditingComplete: _targetStepsFocusNode.requestFocus,
            ),
            const SizedBox(height: 16),

            // Target steps field
            AppTextField(
              controller: _targetStepsController,
              labelText: 'Target Steps',
              hintText: 'Enter target step count (min $_minTargetSteps)',
              prefixIcon: Icons.directions_walk,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              focusNode: _targetStepsFocusNode,
              onEditingComplete: _handleSubmit,
              validator: _validateTargetSteps,
            ),
            const SizedBox(height: 24),

            // Date selection section
            Text(
              'Goal Period',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Start date picker
                Expanded(
                  child: _DatePickerField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: widget.isLoading ? null : _selectStartDate,
                  ),
                ),
                const SizedBox(width: 16),
                // End date picker
                Expanded(
                  child: _DatePickerField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: widget.isLoading ? null : _selectEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Duration info
            _DurationInfo(
              startDate: _startDate,
              endDate: _endDate,
            ),
            const SizedBox(height: 24),

            // Submit button
            AppButton(
              text: 'Update Goal',
              onPressed: widget.isLoading ? null : _handleSubmit,
              isLoading: widget.isLoading,
              fullWidth: true,
              leadingIcon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}

/// A date picker field widget.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onTap != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.38),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a date for display.
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Widget showing the duration between start and end dates.
class _DurationInfo extends StatelessWidget {
  const _DurationInfo({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final days = endDate.difference(startDate).inDays;
    final durationText = days == 1 ? '1 day' : '$days days';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timelapse,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Duration: $durationText',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
