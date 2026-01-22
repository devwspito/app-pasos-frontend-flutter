/// Enum defining permissions that can be shared between users.
///
/// These permissions control what data a friend can see
/// in the sharing relationship.
enum SharingPermission {
  /// Permission to view daily step counts.
  viewSteps,

  /// Permission to view weekly trends and statistics.
  viewTrends,

  /// Permission to view detailed hourly breakdowns.
  viewHourlyBreakdown,

  /// Permission to view goal progress and achievements.
  viewGoals,
}
