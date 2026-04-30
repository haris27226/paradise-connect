import 'package:equatable/equatable.dart';
import '../../../domain/entities/activity/create_activity_params.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class FetchActivitiesEvent extends ActivityEvent {
  final int contactId;
  final int? dealId;
  final String? activityType;
  final bool isRefresh;

  const FetchActivitiesEvent({
    required this.contactId,
    this.dealId,
    this.activityType,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [contactId, dealId, activityType, isRefresh];
}

class CreateActivityEvent extends ActivityEvent {
  final CreateActivityParams params;

  const CreateActivityEvent(this.params);

  @override
  List<Object?> get props => [params];
}
