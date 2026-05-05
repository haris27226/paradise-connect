import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';
import 'package:progress_group/features/attandance/domain/entities/location_entity.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceEntity> data;
  final List<AttendanceLocation>? locations;

  AttendanceLoaded({required this.data, this.locations});
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}

class AttendanceSubmitLoading extends AttendanceState {}

class AttendanceSubmitSuccess extends AttendanceState {}