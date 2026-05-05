import 'package:progress_group/features/attandance/domain/repositories/attandance_repository.dart';

class SubmitAttendanceUseCase {
  final AttendanceRepository repository;

  SubmitAttendanceUseCase(this.repository);

  Future<void> call({
    required String datetime,
    required int flag,
    required String location,
    String? note,
    String? filePath,
  }) {
    return repository.submitAttendance(
      datetime: datetime,
      flag: flag,
      location: location,
      note: note,
      filePath: filePath,
    );
  }
}
