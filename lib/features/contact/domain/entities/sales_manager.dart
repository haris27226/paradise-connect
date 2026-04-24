import 'package:equatable/equatable.dart';

class SalesManager extends Equatable {
  final int salesPersonId;
  final String fullName;
  final String? salesPersonCode;

  const SalesManager({
    required this.salesPersonId,
    required this.fullName,
    this.salesPersonCode,
  });

  @override
  List<Object?> get props => [salesPersonId, fullName, salesPersonCode];
}
