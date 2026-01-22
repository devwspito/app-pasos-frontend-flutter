import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/steps_provider.dart';
import '../providers/steps_state.dart';
import '../widgets/activity_list_item.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/weekly_chart.dart';

/// Screen displaying step history with weekly trends and hourly breakdown.
///
/// Features:
/// - Weekly bar chart showing 7-day trend
/// - Date picker for selecting a specific day
/// - Hourly line chart for the selected day
/// - List of activities for the selected day
///
/// Uses Riverpod for state management via [stepsProvider].
class StepHistoryScreen extends ConsumerStatefulWidget {
  /// Creates a [StepHistoryScreen].
  const StepHistoryScreen({super.key});

  @override
  ConsumerState<StepHistoryScreen> createState() => _StepHistoryScreenState();
}

class _StepHistoryScreenState extends ConsumerState<StepHistoryScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final notifier = ref.read(stepsProvider.notifier);
    await Future.wait([
      notifier.loadWeeklyTrend(),
      notifier.loadHourlyData(_selectedDate),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    ref.read(stepsProvider.notifier).loadHourlyData(date);
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _onDateSelected(picked);
    }
  }

  void _onWeeklyBarTap(int index) {
    final stepsState = ref.read(stepsProvider);
    if (index >= 0 && index < stepsState.weeklyTrend.length) {
      final trend = stepsState.weeklyTrend[index];
      _onDateSelected(trend.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepsState = ref.watch(stepsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step History'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Chart Section
              _buildSectionHeader(
                theme,
                'Weekly Overview',
                Icons.calendar_view_week_rounded,
              ),
              AppSpacing.gapVerticalSm,
              _buildWeeklyChartCard(theme, stepsState),

              AppSpacing.gapVerticalLg,

              // Date Picker Section
              _buildDatePickerRow(theme),

              AppSpacing.gapVerticalLg,

              // Hourly Chart Section
              _buildSectionHeader(
                theme,
                'Hourly Breakdown',
                Icons.access_time_rounded,
              ),
              AppSpacing.gapVerticalSm,
              _buildHourlyChartCard(theme, stepsState),

              AppSpacing.gapVerticalLg,

              // Activity List Section
              _buildSectionHeader(
                theme,
                'Activities',
                Icons.directions_walk_rounded,
              ),
              AppSpacing.gapVerticalSm,
              _buildActivityListCard(theme, stepsState),

              // Bottom padding for scroll
              AppSpacing.gapVerticalXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSpacing.iconSm,
          color: theme.colorScheme.primary,
        ),
        AppSpacing.gapSm,
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChartCard(ThemeData theme, StepsState stepsState) {
    return AppCard(
      elevation: AppCardElevation.low,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stepsState.isLoading && stepsState.weeklyTrend.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(child: LoadingIndicator()),
            )
          else
            SizedBox(
              height: 200,
              child: WeeklyChart(
                weeklyTrend: stepsState.weeklyTrend,
                onBarTap: _onWeeklyBarTap,
              ),
            ),
          if (stepsState.weeklyTrend.isNotEmpty) ...[
            AppSpacing.gapVerticalSm,
            _buildWeeklySummary(theme, stepsState),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(ThemeData theme, StepsState stepsState) {
    final totalSteps = stepsState.weeklyTrend.fold<int>(
      0,
      (sum, trend) => sum + trend.steps,
    );
    final averageSteps = stepsState.weeklyTrend.isNotEmpty
        ? (totalSteps / stepsState.weeklyTrend.length).round()
        : 0;

    final formatter = NumberFormat.decimalPattern();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(
          theme,
          'Total',
          formatter.format(totalSteps),
          Icons.summarize_rounded,
        ),
        Container(
          width: 1,
          height: 32,
          color: theme.colorScheme.outlineVariant,
        ),
        _buildSummaryItem(
          theme,
          'Average',
          formatter.format(averageSteps),
          Icons.trending_up_rounded,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerRow(ThemeData theme) {
    final dateFormat = DateFormat.yMMMd();
    final isToday = _isToday(_selectedDate);

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _showDatePicker,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: AppSpacing.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Text(
                      isToday
                          ? 'Today, ${dateFormat.format(_selectedDate)}'
                          : dateFormat.format(_selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.gapSm,
        IconButton(
          onPressed: _canGoBack() ? _goToPreviousDay : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous day',
        ),
        IconButton(
          onPressed: _canGoForward() ? _goToNextDay : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next day',
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _canGoBack() {
    final earliestDate = DateTime.now().subtract(const Duration(days: 365));
    return _selectedDate.isAfter(earliestDate);
  }

  bool _canGoForward() {
    return !_isToday(_selectedDate);
  }

  void _goToPreviousDay() {
    _onDateSelected(_selectedDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    if (nextDay.isBefore(now) || _isToday(nextDay)) {
      _onDateSelected(nextDay);
    }
  }

  Widget _buildHourlyChartCard(ThemeData theme, StepsState stepsState) {
    return AppCard(
      elevation: AppCardElevation.low,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stepsState.isLoading && stepsState.hourlyData.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(child: LoadingIndicator()),
            )
          else
            SizedBox(
              height: 180,
              child: HourlyChart(
                hourlyData: stepsState.hourlyData,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityListCard(ThemeData theme, StepsState stepsState) {
    if (stepsState.isLoading && stepsState.hourlyData.isEmpty) {
      return const AppCard(
        elevation: AppCardElevation.low,
        child: SizedBox(
          height: 200,
          child: Center(child: LoadingIndicator()),
        ),
      );
    }

    if (stepsState.hourlyData.isEmpty) {
      return AppCard(
        elevation: AppCardElevation.low,
        padding: AppSpacing.allMd,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_walk_rounded,
                size: AppSpacing.xxl,
                color: theme.colorScheme.outline,
              ),
              AppSpacing.gapVerticalSm,
              Text(
                'No activities recorded for this day',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort hourly data by time (newest first)
    final sortedRecords = List.of(stepsState.hourlyData)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return AppCard(
      elevation: AppCardElevation.low,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              '${sortedRecords.length} ${sortedRecords.length == 1 ? 'activity' : 'activities'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedRecords.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: AppSpacing.md + 44 + AppSpacing.md,
            ),
            itemBuilder: (context, index) {
              return ActivityListItem(
                record: sortedRecords[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
