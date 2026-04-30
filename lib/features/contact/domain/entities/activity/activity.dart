import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  final int activityId;
  final int contactId;
  final int? dealId;
  final String activityType;
  final String activityDate;
  final String? notes;
  final String? nextFollowUpDate;
  final int createdBy;
  final String createdAt;

  const Activity({
    required this.activityId,
    required this.contactId,
    this.dealId,
    required this.activityType,
    required this.activityDate,
    this.notes,
    this.nextFollowUpDate,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        activityId,
        contactId,
        dealId,
        activityType,
        activityDate,
        notes,
        nextFollowUpDate,
        createdBy,
        createdAt,
      ];
}
