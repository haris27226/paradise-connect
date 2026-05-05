import 'package:dio/dio.dart';

abstract class AttendanceRemoteDataSource {
  Future<Map<String, dynamic>> getAttendance();
  Future<Map<String, dynamic>> postAttendance({required String attendanceDatetime,required int flag,required String locationName,String? note,String? filePath,});
  Future<Map<String, dynamic>> postAttendanceActivity({required String attendanceDatetime,  required int flag,  required String locationName,  String? note,  required List<String> filePaths,});
  Future<Map<String, dynamic>> getLocations();
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getLocations() async {
    final response = await dio.get('/attendance/locations');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getAttendance() async {
    final response = await dio.get(
      '/attendance',
      queryParameters: {
        "per_page": 10,
      },
    );

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> postAttendance({
    required String attendanceDatetime,
    required int flag,
    required String locationName,
    String? note,
    String? filePath,
  }) async {
    final formData = FormData.fromMap({
      'attendance_datetime': attendanceDatetime,
      'flag': flag,
      'location_name': locationName,
      if (note != null) 'note': note,
      if (filePath != null)
        'file_attachment': await MultipartFile.fromFile(filePath),
    });

    final response = await dio.post('/attendance', data: formData);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> postAttendanceActivity({  required String attendanceDatetime,  required int flag,  required String locationName,  String? note,  required List<String> filePaths,}) async {
    final formData = FormData.fromMap({
      'attendance_datetime': attendanceDatetime,
      'flag': flag,
      'location_name': locationName,
      if (note != null) 'note': note,
    });

    for (var path in filePaths) {
      formData.files.add(MapEntry(
        'files[]',
        await MultipartFile.fromFile(path),
      ));
    }

    final response = await dio.post('/attendance/activity', data: formData);
    return response.data;
  }
}