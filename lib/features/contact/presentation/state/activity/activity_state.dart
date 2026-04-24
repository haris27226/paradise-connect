import 'package:equatable/equatable.dart';
import '../../../domain/entities/activity.dart';

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
