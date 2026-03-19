import '../../../core/constants/demo_data.dart';

class LeaveModel {
  final String userId;
  final String userName; // Derived via join in real SQL
  final int used;
  final int remaining;

  LeaveModel({
    required this.userId,
    required this.userName,
    required this.used,
    required this.remaining,
  });

  // Helper to convert DB map to Model
  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      userId: map['user_id'],
      userName: map['user_id'] == DemoData.userAId ? "User A" : "User B",
      used: map['used'],
      remaining: map['balance'], // Per schema 13.4, 'balance' is the remaining
    );
  }
}