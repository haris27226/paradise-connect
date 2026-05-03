class ActivityTimelineItem {
  final DateTime date;
  final String type; // 'activity' / 'prospect'
  final dynamic data;

  ActivityTimelineItem({
    required this.date,
    required this.type,
    required this.data,
  });
}