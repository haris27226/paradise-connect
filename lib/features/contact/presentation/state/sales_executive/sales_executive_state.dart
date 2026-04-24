import 'package:equatable/equatable.dart';
import '../../../domain/entities/sales_executive.dart';

enum SalesExecutiveStatus { initial, loading, loaded, error }

class SalesExecutiveState extends Equatable {
  final SalesExecutiveStatus status;
  final List<SalesExecutive> salesExecutives;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final String search;

  const SalesExecutiveState({
    this.status = SalesExecutiveStatus.initial,
    this.salesExecutives = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.search = '',
  });

  SalesExecutiveState copyWith({
    SalesExecutiveStatus? status,
    List<SalesExecutive>? salesExecutives,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? search,
  }) {
    return SalesExecutiveState(
      status: status ?? this.status,
      salesExecutives: salesExecutives ?? this.salesExecutives,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        status,
        salesExecutives,
        errorMessage,
        currentPage,
        hasReachedMax,
        search,
      ];
}
