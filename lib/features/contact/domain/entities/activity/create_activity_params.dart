import 'package:equatable/equatable.dart';

class CreateActivityParams extends Equatable {
  final int contactId;
  final int? dealId;
  final String activityType;
  final String activityDate;
  final String? notes;
  final String? nextFollowUpDate;

  const CreateActivityParams({
    required this.contactId,
    this.dealId,
    required this.activityType,
    required this.activityDate,
    this.notes,
    this.nextFollowUpDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'deal_id': dealId,
      'activity_type': activityType,
      'activity_date': activityDate,
      'notes': notes,
      'next_follow_up_date': nextFollowUpDate,
    };
  }

  @override
  List<Object?> get props => [
        contactId,
        dealId,
        activityType,
        activityDate,
        notes,
        nextFollowUpDate,
      ];
}
