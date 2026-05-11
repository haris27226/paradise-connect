import 'package:progress_group/features/attandance/data/datasource/attendance_remote_datasource.dart';
import 'package:progress_group/features/attandance/data/models/attendance_model.dart';
import 'package:progress_group/features/attandance/data/models/location_model.dart';
import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';
import 'package:progress_group/features/attandance/domain/entities/location_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendance({List<int>? salesPersonIds});
  Future<List<AttendanceLocation>> getLocations();
  Future<List<AttendanceLocation>> getOfficeLocations();
  Future<void> submitAttendance({required String datetime,required int flag,required String location,String? note,String? filePath,required int nikNumber,});
  Future<void> submitAttendanceActivity({required String datetime,required int flag,required String location,String? note,required List<String> filePaths,required int nikNumber,});
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remote;

  AttendanceRepositoryImpl(this.remote);

  @override
  Future<List<AttendanceLocation>> getLocations() async {
    final result = await remote.getLocations();
    final list = result['data'] as List;
    return list.map((e) => AttendanceLocationModel.fromJson(e)).toList();
  }

  @override
  Future<List<AttendanceLocation>> getOfficeLocations() async {
    final result = await remote.getOfficeLocations();
    final list = result['data']['data'] as List;
    return list.map((e) => AttendanceLocationModel.fromJson(e)).toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendance({List<int>? salesPersonIds}) async {
    final result = await remote.getAttendance(salesPersonIds: salesPersonIds);

    final list = result['data']['data'] as List;
    final models = list.map((e) => AttendanceModel.fromJson(e)).toList();

    // Grouping by Date and FullName to merge ClockIn and ClockOut
    final Map<String, AttendanceEntity> grouped = {};

    for (var m in models) {
      final key = "${m.date}_${m.fullName}";
      if (!grouped.containsKey(key)) {
        grouped[key] = m;
      } else {
        final existing = grouped[key]!;
        grouped[key] = AttendanceEntity(
          date: m.date,
          fullName: m.fullName,
          location: m.location.isNotEmpty ? m.location : existing.location,
          clockIn: m.clockIn ?? existing.clockIn,
          clockOut: m.clockOut ?? existing.clockOut,
          checkInActivity: m.checkInActivity ?? existing.checkInActivity,
          fileAttchment0: (m.fileAttchment0 != null && m.fileAttchment0!.isNotEmpty) ? m.fileAttchment0 : existing.fileAttchment0,
          fileAttchment1: (m.fileAttchment1 != null && m.fileAttchment1!.isNotEmpty) ? m.fileAttchment1 : existing.fileAttchment1,
          fileAttchment6: (m.fileAttchment6 != null && m.fileAttchment6!.isNotEmpty) ? m.fileAttchment6 : existing.fileAttchment6,
          note0: m.note0 ?? existing.note0,
          note1: m.note1 ?? existing.note1,
          note6: m.note6 ?? existing.note6,
          location0: m.location0 ?? existing.location0,
          location1: m.location1 ?? existing.location1,
          location6: m.location6 ?? existing.location6,
        );
      }
    }

    return grouped.values.toList();
  }

  @override
  Future<void> submitAttendance({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    String? filePath,
    required int nikNumber,
  }) async {
    await remote.postAttendance(
      attendanceDatetime: datetime,
      flag: flag,
      locationName: location,
      note: note,
      filePath: filePath,
      nikNumber: nikNumber,
    );
  }

  @override
  Future<void> submitAttendanceActivity({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    required List<String> filePaths,
    required int nikNumber,
  }) async {
    await remote.postAttendanceActivity(
      attendanceDatetime: datetime,
      flag: flag,
      locationName: location,
      note: note,
      filePaths: filePaths,
      nikNumber: nikNumber,
    );
  }
}