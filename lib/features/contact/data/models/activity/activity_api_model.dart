import '../../../domain/entities/activity/activity.dart';

class ActivityApiModel extends Activity {
  const ActivityApiModel({
    required super.activityId,
    required super.contactId,
    super.dealId,
    required super.activityType,
    required super.activityDate,
    super.notes,
    super.nextFollowUpDate,
    required super.createdBy,
    required super.createdAt,
  });

  factory ActivityApiModel.fromJson(Map<String, dynamic> json) {
    return ActivityApiModel(
      activityId: json['activity_id'],
      contactId: json['contact_id'],
      dealId: json['deal_id'],
      activityType: json['activity_type'] ?? '',
      activityDate: json['activity_date'] ?? '',
      notes: json['notes'],
      nextFollowUpDate: json['next_follow_up_date'],
      createdBy: json['created_by'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ActivityResponseModel {
  final List<ActivityApiModel> activities;
  final int currentPage;
  final bool hasReachedMax;

  ActivityResponseModel({
    required this.activities,
    required this.currentPage,
    required this.hasReachedMax,
  });

  factory ActivityResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    return ActivityResponseModel(
      activities: data.map((e) => ActivityApiModel.fromJson(e)).toList(),
      currentPage: json['current_page'] ?? 1,
      hasReachedMax: json['next_page_url'] == null,
    );
  }
}
