abstract class AttendanceEvent {}

class GetAttendanceEvent extends AttendanceEvent {}

class GetLocationsEvent extends AttendanceEvent {}

class SubmitAttendanceEvent extends AttendanceEvent {
  final String datetime;
  final int flag;
  final String location;
  final String? note;
  final String? filePath;

  SubmitAttendanceEvent({
    required this.datetime,
    required this.flag,
    required this.location,
    this.note,
    this.filePath,
  });
}

class SubmitAttendanceActivityEvent extends AttendanceEvent {
  final String datetime;
  final int flag;
  final String location;
  final String? note;
  final List<String> filePaths;

  SubmitAttendanceActivityEvent({
    required this.datetime,
    required this.flag,
    required this.location,
    this.note,
    required this.filePaths,
  });
}