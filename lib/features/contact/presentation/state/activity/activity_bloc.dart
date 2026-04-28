import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_activity_usecase.dart';
import '../../../domain/usecases/get_activities_usecase.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivitiesUseCase getActivitiesUseCase;
  final CreateActivityUseCase createActivityUseCase;

  ActivityBloc({
    required this.getActivitiesUseCase,
    required this.createActivityUseCase,
  }) : super(const ActivityState()) {
    on<FetchActivitiesEvent>(_onFetchActivities);
    on<CreateActivityEvent>(_onCreateActivity);
  }

  Future<void> _onFetchActivities(
    FetchActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: ActivityStatus.loading,
        activities: [],
        currentPage: 1,
        hasReachedMax: false,
      ));
    } else {
      if (state.hasReachedMax) return;
      if (state.status == ActivityStatus.initial) {
        emit(state.copyWith(status: ActivityStatus.loading));
      }
    }

    final result = await getActivitiesUseCase(
      contactId: event.contactId,
      dealId: event.dealId,
      activityType: event.activityType,
      page: state.currentPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ActivityStatus.error,
        errorMessage: failure,
      )),
      (activities) {
        if (activities.isEmpty) {
          emit(state.copyWith(
            status: ActivityStatus.loaded,
            hasReachedMax: true,
          ));
        } else {
          emit(state.copyWith(
            status: ActivityStatus.loaded,
            activities: List.of(state.activities)..addAll(activities),
            currentPage: state.currentPage + 1,
            hasReachedMax: activities.length < 15, // matches per_page
          ));
        }
      },
    );
  }

  Future<void> _onCreateActivity(
    CreateActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: ActivityStatus.creating));

    final result = await createActivityUseCase(event.params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ActivityStatus.error,
        errorMessage: failure,
      )),
      (_) => emit(state.copyWith(status: ActivityStatus.createSuccess)),
    );
  }
}
