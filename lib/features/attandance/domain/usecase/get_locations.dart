import 'package:progress_group/features/attandance/domain/entities/location_entity.dart';
import 'package:progress_group/features/attandance/domain/repositories/attandance_repository.dart';

class GetLocationsUseCase {
  final AttendanceRepository repository;

  GetLocationsUseCase(this.repository);

  Future<List<AttendanceLocation>> call() {
    return repository.getLocations();
  }
}
