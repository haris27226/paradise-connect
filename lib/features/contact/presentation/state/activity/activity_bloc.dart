import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/contact/domain/usecases/activity/create_activity_visit_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/activity/get_activity_prospect_status_usecase.dart';
import '../../../domain/usecases/activity/create_activity_usecase.dart';
import '../../../domain/usecases/activity/get_activities_usecase.dart';
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


class ActivityVisitBloc extends Bloc<CreateVisitEvent, VisitState> {
  final CreateActivityVisitUseCase createVisit;

  ActivityVisitBloc(this.createVisit) : super(VisitInitial()) {
    on<CreateVisitEvent>((event, emit) async {
      emit(VisitLoading());

      final result = await createVisit(event.params);

      result.fold(
        (l) => emit(VisitError(l)),
        (_) => emit(VisitSuccess()),
      );
    });
  }
}


class ActivityProspectStatusBloc extends Bloc<ActivityProspectStatusEvent, ActivityProspectStatusState> {
  final GetActivityProspectStatusUseCase useCase;

  ActivityProspectStatusBloc(this.useCase)
      : super(const ActivityProspectStatusState()) {
    on<FetchActivityProspectStatusEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchActivityProspectStatusEvent event,
    Emitter<ActivityProspectStatusState> emit,
  ) async {
    emit(state.copyWith(status: ActivityProspectStatusStatus.loading));

    final result = await useCase(event.contactId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ActivityProspectStatusStatus.error,
        errorMessage: failure,
      )),
      (data) => emit(state.copyWith(
        status: ActivityProspectStatusStatus.loaded,
        data: data,
      )),
    );
  }
}