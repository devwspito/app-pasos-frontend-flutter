import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_pasos_frontend/core/widgets/app_text_field.dart';
import 'package:app_pasos_frontend/core/widgets/app_button.dart';
import 'package:app_pasos_frontend/core/utils/validators.dart';

/// A form widget for creating or editing goals.
///
/// Includes fields for:
/// - Name (required)
/// - Description (optional)
/// - Target steps (required, minimum 1000)
/// - Start date (required)
/// - End date (required, must be after start date)
///
/// Example:
/// ```dart
/// GoalForm(
///   onSubmit: (name, description, targetSteps, startDate, endDate) {
///     // Handle form submission
///   },
///   isLoading: false,
/// )
/// ```
class GoalForm extends StatefulWidget {
  /// Creates a [GoalForm] widget.
  ///
  /// [onSubmit] is called when the form is submitted with valid data.
  /// [isLoading] shows a loading indicator on the submit button when true.
  const GoalForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  /// Callback invoked when the form is submitted with valid data.
  ///
  /// Parameters:
  /// - name: The goal name
  /// - description: Optional description (can be null)
  /// - targetSteps: Target number of steps
  /// - startDate: Goal start date
  /// - endDate: Goal end date
  final void Function(
    String name,
    String? description,
    int targetSteps,
    DateTime startDate,
    DateTime endDate,
  ) onSubmit;

  /// Whether the form is in a loading state.
  ///
  /// When true, disables all fields and shows a loading indicator on the button.
  final bool isLoading;

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetStepsController;

  // Dates
  DateTime? _startDate;
  DateTime? _endDate;

  // Date validation errors
  String? _startDateError;
  String? _endDateError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetStepsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetStepsController.dispose();
    super.dispose();
  }

  /// Validates the target steps field.
  ///
  /// Must be a number and at least 1000.
  String? _validateTargetSteps(String? value) {
    final requiredError = Validators.validateRequired(value, 'Target steps');
    if (requiredError != null) return requiredError;

    final number = int.tryParse(value!);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 1000) {
      return 'Target must be at least 1,000 steps';
    }
    return null;
  }

  /// Shows a date picker and updates the corresponding date field.
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now.add(const Duration(days: 7)));

    final firstDate = isStartDate ? now : (_startDate ?? now);
    final lastDate = now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          _startDateError = null;
          // Reset end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = null;
            _endDateError = 'Please select an end date after the start date';
          }
        } else {
          _endDate = pickedDate;
          _endDateError = null;
        }
      });
    }
  }

  /// Validates the dates and submits the form if valid.
  void _handleSubmit() {
    // Validate dates first
    bool datesValid = true;

    setState(() {
      if (_startDate == null) {
        _startDateError = 'Start date is required';
        datesValid = false;
      } else {
        _startDateError = null;
      }

      if (_endDate == null) {
        _endDateError = 'End date is required';
        datesValid = false;
      } else if (_startDate != null && _endDate!.isBefore(_startDate!)) {
        _endDateError = 'End date must be after start date';
        datesValid = false;
      } else {
        _endDateError = null;
      }
    });

    // Validate form fields
    if (_formKey.currentState!.validate() && datesValid) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final targetSteps = int.parse(_targetStepsController.text);

      widget.onSubmit(
        name,
        description.isEmpty ? null : description,
        targetSteps,
        _startDate!,
        _endDate!,
      );
    }
  }

  /// Formats a date as "MMM d, yyyy".
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
          // Goal Name
          AppTextField(
            controller: _nameController,
            label: 'Goal Name',
            hint: 'Enter a name for your goal',
            enabled: !widget.isLoading,
            prefixIcon: Icons.flag_outlined,
            validator: (value) => Validators.validateRequired(value, 'Goal name'),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Description (optional)
          AppTextField(
            controller: _descriptionController,
            label: 'Description (optional)',
            hint: 'Add a description for your goal',
            enabled: !widget.isLoading,
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Target Steps
          AppTextField(
            controller: _targetStepsController,
            label: 'Target Steps',
            hint: 'Minimum 1,000 steps',
            enabled: !widget.isLoading,
            prefixIcon: Icons.directions_walk,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: _validateTargetSteps,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // Date Section Header
          Text(
            'Goal Period',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          // Date Pickers Row
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Start Date',
                  value: _startDate,
                  error: _startDateError,
                  enabled: !widget.isLoading,
                  onTap: () => _selectDate(context, true),
                  formatDate: _formatDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DatePickerField(
                  label: 'End Date',
                  value: _endDate,
                  error: _endDateError,
                  enabled: !widget.isLoading,
                  onTap: () => _selectDate(context, false),
                  formatDate: _formatDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Submit Button
          AppButton(
            label: 'Create Goal',
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            fullWidth: true,
            size: AppButtonSize.large,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }
}

/// A custom date picker field widget.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.error,
    required this.enabled,
    required this.onTap,
    required this.formatDate,
  });

  final String label;
  final DateTime? value;
  final String? error;
  final bool enabled;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError
                    ? colorScheme.error
                    : colorScheme.outline,
                width: 1,
              ),
              color: enabled
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null ? formatDate(value!) : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null
                          ? (enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.38))
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
