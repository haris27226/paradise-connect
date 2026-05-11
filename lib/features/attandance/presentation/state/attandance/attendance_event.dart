abstract class AttendanceEvent {}

class GetAttendanceEvent extends AttendanceEvent {
  final List<int>? salesPersonIds;
  GetAttendanceEvent({this.salesPersonIds});
}

class FetchAttendanceDataEvent extends AttendanceEvent {
  final List<int>? salesPersonIds;
  FetchAttendanceDataEvent({this.salesPersonIds});
}

class GetLocationsEvent extends AttendanceEvent {}

class GetOfficeLocationsEvent extends AttendanceEvent {}

class SubmitAttendanceEvent extends AttendanceEvent {
  final String datetime;
  final int flag;
  final String location;
  final String? note;
  final String? filePath;
  final int nikNumber;

  SubmitAttendanceEvent({
    required this.datetime,
    required this.flag,
    required this.location,
    this.note,
    this.filePath,
    required this.nikNumber,
  });
}

class SubmitAttendanceActivityEvent extends AttendanceEvent {
  final String datetime;
  final int flag;
  final String location;
  final String? note;
  final List<String> filePaths;
  final int nikNumber;

  SubmitAttendanceActivityEvent({
    required this.datetime,
    required this.flag,
    required this.location,
    this.note,
    required this.filePaths,
    required this.nikNumber,
  });
}