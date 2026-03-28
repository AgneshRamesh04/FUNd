/// Utility functions for personalizing username display

/// Returns "you" if the userId matches the currentUserId, otherwise returns the display name
String getDisplayName(
  String userId,
  String currentUserId,
  Map<String, String> userNames,
) {
  if (userId == currentUserId) {
    return 'You';
  }
  return userNames[userId] ?? 'Unknown';
}
