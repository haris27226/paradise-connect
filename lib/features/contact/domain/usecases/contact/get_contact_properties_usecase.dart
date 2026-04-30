import 'package:dartz/dartz.dart';
import '../../entities/contact/contact_property.dart';
import '../../repositories/contact_repository.dart';

class GetContactPropertiesUseCase {
  final ContactRepository repository;
  GetContactPropertiesUseCase(this.repository);

  Future<Either<String, List<ContactPropertyGroup>>> call() async {
    return await repository.getContactProperties();
  }
}
