/// Model representing a progress entry for a goal.
///
/// Tracks daily step contributions from members towards a goal's target.
class GoalProgressModel {
  final String id;
  final String goalId;
  final String memberId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final int steps;
  final DateTime date;
  final DateTime createdAt;

  const GoalProgressModel({
    required this.id,
    required this.goalId,
    required this.memberId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.steps,
    required this.date,
    required this.createdAt,
  });

  /// Creates a [GoalProgressModel] from JSON data.
  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    return GoalProgressModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      memberId: json['memberId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      steps: json['steps'] as int,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'memberId': memberId,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'steps': steps,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Returns the date portion only (without time).
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  /// Returns true if this progress entry is from today.
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
