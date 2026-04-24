import 'package:equatable/equatable.dart';

abstract class SalesExecutiveEvent extends Equatable {
  const SalesExecutiveEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesExecutivesEvent extends SalesExecutiveEvent {
  final bool isLoadMore;

  const FetchSalesExecutivesEvent({this.isLoadMore = false});

  @override
  List<Object?> get props => [isLoadMore];
}

class SearchSalesExecutivesEvent extends SalesExecutiveEvent {
  final String query;

  const SearchSalesExecutivesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
