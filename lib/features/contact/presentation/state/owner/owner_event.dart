import 'package:equatable/equatable.dart';

abstract class OwnerEvent extends Equatable {
  const OwnerEvent();

  @override
  List<Object?> get props => [];
}

class FetchOwnersEvent extends OwnerEvent {
  final bool isLoadMore;

  const FetchOwnersEvent({this.isLoadMore = false});

  @override
  List<Object?> get props => [isLoadMore];
}

class SearchOwnersEvent extends OwnerEvent {
  final String query;

  const SearchOwnersEvent(this.query);

  @override
  List<Object?> get props => [query];
}
