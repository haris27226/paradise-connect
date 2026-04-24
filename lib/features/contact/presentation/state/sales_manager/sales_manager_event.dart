import 'package:equatable/equatable.dart';

abstract class SalesManagerEvent extends Equatable {
  const SalesManagerEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesManagersEvent extends SalesManagerEvent {
  final bool isLoadMore;

  const FetchSalesManagersEvent({this.isLoadMore = false});

  @override
  List<Object?> get props => [isLoadMore];
}

class SearchSalesManagersEvent extends SalesManagerEvent {
  final String query;

  const SearchSalesManagersEvent(this.query);

  @override
  List<Object?> get props => [query];
}
