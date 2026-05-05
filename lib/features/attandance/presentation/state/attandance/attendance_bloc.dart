import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/attandance/domain/usecase/get_attendance.dart';
import 'package:progress_group/features/attandance/domain/usecase/get_locations.dart';
import 'package:progress_group/features/attandance/domain/usecase/submit_attendance.dart';
import 'package:progress_group/features/attandance/domain/usecase/submit_attendance_activity.dart';
import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_event.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetAttendanceUseCase getAttendanceUseCase;
  final GetLocationsUseCase getLocationsUseCase;
  final SubmitAttendanceUseCase submitAttendanceUseCase;
  final SubmitAttendanceActivityUseCase submitAttendanceActivityUseCase;

  AttendanceBloc({
    required this.getAttendanceUseCase,
    required this.getLocationsUseCase,
    required this.submitAttendanceUseCase,
    required this.submitAttendanceActivityUseCase,
  }) : super(AttendanceInitial()) {
    on<GetAttendanceEvent>((event, emit) async {
      emit(AttendanceLoading());
      try {
        final data = await getAttendanceUseCase();
        emit(AttendanceLoaded(data: data));
      } catch (e) {
        emit(AttendanceError(e.toString()));
      }
    });

    on<GetLocationsEvent>((event, emit) async {
      final currentState = state;
      List<AttendanceEntity> currentData = [];
      if (currentState is AttendanceLoaded) {
        currentData = currentState.data;
      }

      try {
        final locations = await getLocationsUseCase();
        emit(AttendanceLoaded(data: currentData, locations: locations));
      } catch (e) {
        // We don't want to show a big error if just locations fail, 
        // but maybe we should for now.
        emit(AttendanceError(e.toString()));
      }
    });

    on<SubmitAttendanceEvent>((event, emit) async {
      emit(AttendanceSubmitLoading());
      try {
        await submitAttendanceUseCase(
          datetime: event.datetime,
          flag: event.flag,
          location: event.location,
          note: event.note,
          filePath: event.filePath,
        );
        emit(AttendanceSubmitSuccess());
      } catch (e) {
        emit(AttendanceError(e.toString()));
      }
    });

    on<SubmitAttendanceActivityEvent>((event, emit) async {
      emit(AttendanceSubmitLoading());
      try {
        await submitAttendanceActivityUseCase(
          datetime: event.datetime,
          flag: event.flag,
          location: event.location,
          note: event.note,
          filePaths: event.filePaths,
        );
        emit(AttendanceSubmitSuccess());
      } catch (e) {
        emit(AttendanceError(e.toString()));
      }
    });
  }
}