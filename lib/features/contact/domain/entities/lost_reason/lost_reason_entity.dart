import 'package:equatable/equatable.dart';

class LostReasonEntity extends Equatable {
  final int lostReasonId;
  final String lostReasonName;

  const LostReasonEntity({
    required this.lostReasonId,
    required this.lostReasonName,
  });

  @override
  List<Object?> get props => [lostReasonId, lostReasonName];
}