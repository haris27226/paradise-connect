import 'package:progress_group/features/attandance/domain/entities/location_entity.dart';
import 'package:progress_group/features/attandance/domain/repositories/attandance_repository.dart';

class GetOfficeLocationsUseCase {
  final AttendanceRepository repository;

  GetOfficeLocationsUseCase(this.repository);

  Future<List<AttendanceLocation>> call() {
    return repository.getOfficeLocations();
  }
}
