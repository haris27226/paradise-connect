import 'package:equatable/equatable.dart';

abstract class ProspectStatusEvent extends Equatable {
  const ProspectStatusEvent();

  @override
  List<Object> get props => [];
}

class FetchProspectStatusesEvent extends ProspectStatusEvent {}
