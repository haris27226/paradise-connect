import 'package:equatable/equatable.dart';

class InfoSource extends Equatable {
  final int id;
  final String name;
  final String typeData;

  const InfoSource({
    required this.id,
    required this.name,
    required this.typeData,
  });

  @override
  List<Object?> get props => [id, name, typeData];
}