import 'package:equatable/equatable.dart';

class Owner extends Equatable {
  final int salesPersonId;
  final String fullName;
  final String? salesPersonCode;

  const Owner({
    required this.salesPersonId,
    required this.fullName,
    this.salesPersonCode,
  });

  @override
  List<Object?> get props => [salesPersonId, fullName, salesPersonCode];
}
