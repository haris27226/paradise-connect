import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  AttendanceModel({
    required super.date,
    super.clockIn,
    super.clockOut,
    super.checkInActivity,
    required super.location,
    super.fileAttchment0,
    super.fileAttchment1,
    super.fileAttchment6,
    super.note0,
    super.note1,
    super.note6,
    super.location0,
    super.location1,
    super.location6,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      date: json['date'] ?? '',
      clockIn: json['clockIn_date'],
      clockOut: json['clockOut_date'],
      checkInActivity: json['checkIn_date_activity'],
      location: json['location_flag_0'] ?? json['location_name'] ?? '',
      fileAttchment0: json['file_attachment_flag_0'] != null ? List<String>.from(json['file_attachment_flag_0']) : null,
      fileAttchment1: json['file_attachment_flag_1'] != null ? List<String>.from(json['file_attachment_flag_1']) : null,
      fileAttchment6: json['file_attachment_flag_6'] != null ? List<String>.from(json['file_attachment_flag_6']) : null,
      note0: json['note_flag_0'],
      note1: json['note_flag_1'],
      note6: json['note_flag_6'],
      location0: json['location_flag_0'],
      location1: json['location_flag_1'],
      location6: json['location_flag_6'],
    );
  }

}