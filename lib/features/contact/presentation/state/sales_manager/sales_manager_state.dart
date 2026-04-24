import 'package:equatable/equatable.dart';
import '../../../domain/entities/sales_manager.dart';

enum SalesManagerStatus { initial, loading, loaded, error }

class SalesManagerState extends Equatable {
  final SalesManagerStatus status;
  final List<SalesManager> salesManagers;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final String search;

  const SalesManagerState({
    this.status = SalesManagerStatus.initial,
    this.salesManagers = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.search = '',
  });

  SalesManagerState copyWith({  SalesManagerStatus? status,  List<SalesManager>? salesManagers,  String? errorMessage,  int? currentPage,  bool? hasReachedMax,  String? search,}) {
    return SalesManagerState(
      status: status ?? this.status,
      salesManagers: salesManagers ?? this.salesManagers,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        status,
        salesManagers,
        errorMessage,
        currentPage,
        hasReachedMax,
        search,
      ];
}
