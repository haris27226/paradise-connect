import 'package:equatable/equatable.dart';

abstract class InfoSourceEvent extends Equatable {
  const InfoSourceEvent();

  @override
  List<Object> get props => [];
}

class FetchInfoSourcesEvent extends InfoSourceEvent {
  final int? type;
  const FetchInfoSourcesEvent({this.type});

  @override
  List<Object> get props => [type ?? 0];
}