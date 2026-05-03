import 'package:equatable/equatable.dart';
import 'package:progress_group/features/contact/domain/entities/activity/activity_prospect_status.dart';
import '../../../domain/entities/activity/activity.dart';

enum ActivityStatus { initial, loading, loaded, error, creating, createSuccess }

class ActivityState extends Equatable {
  final ActivityStatus status;
  final List<Activity> activities;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  const ActivityState({
    this.status = ActivityStatus.initial,
    this.activities = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  ActivityState copyWith({
    ActivityStatus? status,
    List<Activity>? activities,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return ActivityState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, activities, errorMessage, currentPage, hasReachedMax];
}


abstract class VisitState {}

class VisitInitial extends VisitState {}
class VisitLoading extends VisitState {}
class VisitSuccess extends VisitState {}
class VisitError extends VisitState {
  final String message;
  VisitError(this.message);
}



enum ActivityProspectStatusStatus { initial, loading, loaded, error }

class ActivityProspectStatusState extends Equatable {
  final ActivityProspectStatusStatus status;
  final List<ActivityProspectStatusEntity> data;
  final String? errorMessage;

  const ActivityProspectStatusState({
    this.status = ActivityProspectStatusStatus.initial,
    this.data = const [],
    this.errorMessage,
  });

  ActivityProspectStatusState copyWith({
    ActivityProspectStatusStatus? status,
    List<ActivityProspectStatusEntity>? data,
    String? errorMessage,
  }) {
    return ActivityProspectStatusState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}