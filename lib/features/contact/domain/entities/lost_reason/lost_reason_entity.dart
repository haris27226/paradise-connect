import 'package:equatable/equatable.dart';

class LostReasonEntity extends Equatable {
  final int id;
  final String text;

  const LostReasonEntity({
    required this.id,
    required this.text,
  });

  @override
  List<Object?> get props => [id, text];
}