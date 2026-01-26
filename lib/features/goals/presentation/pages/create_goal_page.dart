import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';

// TODO: Import from goals_provider.dart when Epic 5 is completed
// import '../providers/goals_provider.dart';

// TODO: Import from goal_form.dart widget when Epic 6 is completed
// import '../widgets/goal_form.dart';

/// Page for creating a new goal.
///
/// Features:
/// - Form with goal name, description, target steps, start/end dates
/// - Validation for required fields
/// - Loading state during creation
/// - Navigation back on success
class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage({super.key});

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetStepsController = TextEditingController(text: '10000');

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetStepsController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Start Date',
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: 'Select End Date',
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Goal name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }

  String? _validateTargetSteps(String? value) {
    if (value == null || value.isEmpty) {
      return 'Target steps is required';
    }
    final steps = int.tryParse(value);
    if (steps == null) {
      return 'Please enter a valid number';
    }
    if (steps <= 0) {
      return 'Target must be greater than 0';
    }
    if (steps > 1000000) {
      return 'Target seems too high';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional date validation
    if (_endDate.isBefore(_startDate) ||
        _endDate.isAtSameMomentAs(_startDate)) {
      setState(() {
        _errorMessage = 'End date must be after start date';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call via GoalsProvider
      // final goalsProvider = context.read<GoalsProvider>();
      // final newGoal = await goalsProvider.createGoal(
      //   _nameController.text.trim(),
      //   _descriptionController.text.trim().isEmpty
      //       ? null
      //       : _descriptionController.text.trim(),
      //   int.parse(_targetStepsController.text),
      //   _startDate,
      //   _endDate,
      // );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulated success - navigate to the new goal
      // In real implementation: context.go('/goals/${newGoal.id}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/goals');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create goal. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateBack() {
    context.go('/goals');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Goal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : _navigateBack,
        ),
      ),
      body: _isLoading
          ? const AppLoading(message: 'Creating goal...')
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildNameField(),
            const SizedBox(height: AppSpacing.md),
            _buildDescriptionField(),
            const SizedBox(height: AppSpacing.md),
            _buildTargetStepsField(),
            const SizedBox(height: AppSpacing.lg),
            _buildDateSection(),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildErrorMessage(),
            ],
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.flag_outlined,
          size: 64,
          color: colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Set Your Goal',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Create a new goal and invite friends to join!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return AppTextField(
      controller: _nameController,
      label: 'Goal Name',
      hint: 'e.g., 30-Day Step Challenge',
      prefixIcon: Icons.flag_outlined,
      validator: _validateName,
      textInputAction: TextInputAction.next,
      maxLength: 100,
      enabled: !_isLoading,
    );
  }

  Widget _buildDescriptionField() {
    return AppTextField(
      controller: _descriptionController,
      label: 'Description (Optional)',
      hint: 'Describe your goal...',
      prefixIcon: Icons.description_outlined,
      maxLines: 3,
      maxLength: 500,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
    );
  }

  Widget _buildTargetStepsField() {
    return AppTextField(
      controller: _targetStepsController,
      label: 'Daily Step Target',
      hint: 'e.g., 10000',
      prefixIcon: Icons.directions_walk,
      keyboardType: TextInputType.number,
      validator: _validateTargetSteps,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ],
      enabled: !_isLoading,
    );
  }

  Widget _buildDateSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DatePickerButton(
                label: 'Start Date',
                date: _startDate,
                onTap: _isLoading ? null : _selectStartDate,
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DatePickerButton(
                label: 'End Date',
                date: _endDate,
                onTap: _isLoading ? null : _selectEndDate,
                icon: Icons.event,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Duration: ${_endDate.difference(_startDate).inDays} days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _isLoading ? null : _handleSubmit,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check),
      label: Text(_isLoading ? 'Creating...' : 'Create Goal'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),
    );
  }
}

/// Date picker button widget.
class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback? onTap;
  final IconData icon;

  const _DatePickerButton({
    required this.label,
    required this.date,
    this.onTap,
    required this.icon,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatDate(date),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
