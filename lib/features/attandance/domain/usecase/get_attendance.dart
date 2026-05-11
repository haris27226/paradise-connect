import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';
import 'package:progress_group/features/attandance/domain/repositories/attandance_repository.dart';

class GetAttendanceUseCase {
  final AttendanceRepository repository;

  GetAttendanceUseCase(this.repository);

  Future<List<AttendanceEntity>> call({List<int>? salesPersonIds}) {
    return repository.getAttendance(salesPersonIds: salesPersonIds);
  }
}