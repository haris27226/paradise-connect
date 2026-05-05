import 'package:progress_group/features/attandance/data/datasource/attendance_remote_datasource.dart';
import 'package:progress_group/features/attandance/data/models/attendance_model.dart';
import 'package:progress_group/features/attandance/data/models/location_model.dart';
import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';
import 'package:progress_group/features/attandance/domain/entities/location_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendance();
  Future<List<AttendanceLocation>> getLocations();
  Future<void> submitAttendance({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    String? filePath,
  });
  Future<void> submitAttendanceActivity({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    required List<String> filePaths,
  });
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
  Future<List<AttendanceEntity>> getAttendance() async {
    final result = await remote.getAttendance();

    final list = result['data']['data'] as List;

    return list.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  @override
  Future<void> submitAttendance({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    String? filePath,
  }) async {
    await remote.postAttendance(
      attendanceDatetime: datetime,
      flag: flag,
      locationName: location,
      note: note,
      filePath: filePath,
    );
  }

  @override
  Future<void> submitAttendanceActivity({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    required List<String> filePaths,
  }) async {
    await remote.postAttendanceActivity(
      attendanceDatetime: datetime,
      flag: flag,
      locationName: location,
      note: note,
      filePaths: filePaths,
    );
  }
}