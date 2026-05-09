/// Returns "you" if the userId matches the currentUserId, otherwise returns the display name
String getDisplayName(
  String userId,
  String currentUserId,
  Map<String, String> userNames,
) {
  if (userId == currentUserId) {
    return 'You';
  } else if (userId.isEmpty) {
    return 'FUNd';
  }
  return userNames[userId] ?? 'Unknown';
}
