/// Goal form widget for creating new group goals.
///
/// This widget provides a form for creating goals with validation
/// support using the shared widgets and validators.
library;

import 'package:app_pasos_frontend/core/utils/validators.dart';
import 'package:app_pasos_frontend/shared/widgets/app_button.dart';
import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// A form widget for creating new group goals.
///
/// This form collects the goal name, optional description, target steps,
/// start date, and end date. It handles validation and provides a callback
/// for form submission.
///
/// Example usage:
/// ```dart
/// GoalForm(
///   isLoading: state is GoalCreating,
///   onSubmit: (name, description, targetSteps, startDate, endDate) {
///     context.read<CreateGoalBloc>().add(
///       CreateGoalRequested(
///         name: name,
///         description: description,
///         targetSteps: targetSteps,
///         startDate: startDate,
///         endDate: endDate,
///       ),
///     );
///   },
/// )
/// ```
class GoalForm extends StatefulWidget {
  /// Creates a [GoalForm].
  const GoalForm({
    required this.onSubmit,
    this.isLoading = false,
    super.key,
  });

  /// Callback when the form is submitted with valid data.
  ///
  /// Parameters:
  /// - [name] - The goal name (required).
  /// - [description] - Optional goal description.
  /// - [targetSteps] - The step target (minimum 1000).
  /// - [startDate] - When the goal period starts.
  /// - [endDate] - When the goal period ends.
  final void Function(
    String name,
    String? description,
    int targetSteps,
    DateTime startDate,
    DateTime endDate,
  ) onSubmit;

  /// Whether the form is in a loading state.
  ///
  /// When true, form fields are disabled and the submit button
  /// shows a loading indicator.
  final bool isLoading;

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetStepsController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _targetStepsFocusNode = FocusNode();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  /// Minimum target steps allowed.
  static const int _minTargetSteps = 1000;

  /// Maximum goal name length.
  static const int _maxNameLength = 50;

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
      widget.onSubmit(
        _nameController.text.trim(),
        description.isEmpty ? null : description,
        int.parse(_targetStepsController.text.trim()),
        _startDate,
        _endDate,
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
      firstDate: DateTime.now(),
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

    return Form(
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
            text: 'Create Goal',
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            fullWidth: true,
            leadingIcon: Icons.add,
          ),
        ],
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
