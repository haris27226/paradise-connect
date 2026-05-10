import 'package:equatable/equatable.dart';

abstract class ProspectStatusEvent extends Equatable {
  const ProspectStatusEvent();

  @override
  List<Object> get props => [];
}

class FetchProspectStatusesEvent extends ProspectStatusEvent {
  final String? type;

  const FetchProspectStatusesEvent({this.type});

  @override
  List<Object> get props => [type ?? ''];
}
