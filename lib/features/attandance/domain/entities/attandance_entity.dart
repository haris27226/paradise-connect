class AttendanceEntity {
  final String date;
  final String? clockIn;
  final String? clockOut;
  final String? checkInActivity;
  final String location;
  final List<String>? fileAttchment0;
  final List<String>? fileAttchment1;
  final List<String>? fileAttchment6;
  final String? note0;
  final String? note1;
  final String? note6;


  AttendanceEntity({
    required this.date,
    this.clockIn,
    this.clockOut,
    this.checkInActivity,
    required this.location,
    this.fileAttchment0,
    this.fileAttchment1,
    this.fileAttchment6,
    this.note0,
    this.note1,
    this.note6
  });
}