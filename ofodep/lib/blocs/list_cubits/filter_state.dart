import 'package:ofodep/models/abstract_params.dart';

abstract class ListState {
  final Map<String, dynamic>? filter;
  final List<String>? searchFields;
  final List<String>? arraySearchFields;
  final String? search;
  final String? orderBy;
  final bool ascending;
  final String? errorMessage;
  final ParamsComponent? rpcParams;
  final int limit;
  final String? randomSeed;

  const ListState({
    this.filter,
    this.searchFields,
    this.arraySearchFields,
    this.search,
    this.orderBy,
    this.ascending = false,
    this.errorMessage,
    this.rpcParams,
    this.limit = 10,
    this.randomSeed,
  });

  ListState copyWith({
    Map<String, dynamic>? filter,
    List<String>? searchFields,
    List<String>? arraySearchFields,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
    ParamsComponent? rpcParams,
    int? limit,
    String? randomSeed,
  });
}

/// Implementación genérica de ListState que cubre los parámetros básicos
class FilterState<P extends ParamsComponent> extends ListState {
  const FilterState({
    super.filter,
    super.searchFields,
    super.arraySearchFields,
    super.search,
    super.orderBy,
    super.ascending = false,
    super.errorMessage,
    super.rpcParams,
    super.limit = 10,
    super.randomSeed,
  });

  @override
  FilterState copyWith({
    Map<String, dynamic>? filter,
    List<String>? searchFields,
    List<String>? arraySearchFields,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
    ParamsComponent? rpcParams,
    int? limit,
    String? randomSeed,
  }) =>
      FilterState(
        filter: filter ?? this.filter,
        searchFields: searchFields ?? this.searchFields,
        arraySearchFields: arraySearchFields ?? this.arraySearchFields,
        search: search ?? this.search,
        orderBy: orderBy ?? this.orderBy,
        ascending: ascending ?? this.ascending,
        errorMessage: errorMessage ?? this.errorMessage,
        rpcParams: rpcParams ?? this.rpcParams,
        limit: limit ?? this.limit,
        randomSeed: randomSeed ?? this.randomSeed,
      );
}
