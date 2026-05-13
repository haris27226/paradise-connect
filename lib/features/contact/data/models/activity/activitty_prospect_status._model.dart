import '../../../domain/entities/activity/activity_prospect_status.dart';

class ActivityProspectStatusModel {
  final int historyId;
  final int dealId;
  final String projectName;
  final int statusProspectId;
  final String statusName;
  final int? previousStatusId;
  final String? previousStatusName;
  final String createdAt;
  final String? statusValue;
  final String? previousStatusValue;

  ActivityProspectStatusModel({
    required this.historyId,
    required this.dealId,
    required this.projectName,
    required this.statusProspectId,
    required this.statusName,
    this.previousStatusId,
    this.previousStatusName,
    required this.createdAt,
    this.statusValue,
    this.previousStatusValue,
  });

  factory ActivityProspectStatusModel.fromJson(Map<String, dynamic> json) {
    return ActivityProspectStatusModel(
      historyId: json['history_id'],
      dealId: json['deal_id'],
      projectName: json['project_name'],
      statusProspectId: json['status_prospect_id'],
      statusName: json['status_name'],
      previousStatusId: json['previous_status_id'],
      previousStatusName: json['previous_status_name'],
      createdAt: json['created_at'],
      statusValue: json['status_value'],
      previousStatusValue: json['previous_status_value'],
    );
  }

  ActivityProspectStatusEntity toEntity() {
    return ActivityProspectStatusEntity(
      historyId: historyId,
      dealId: dealId,
      projectName: projectName,
      statusProspectId: statusProspectId,
      statusName: statusName,
      previousStatusId: previousStatusId,
      previousStatusName: previousStatusName,
      createdAt: createdAt,
      statusValue: statusValue,
      previousStatusValue: previousStatusValue,
    );
  }
}