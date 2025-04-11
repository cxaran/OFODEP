import 'package:ofodep/models/abstract_model.dart';

abstract class ListState<T extends ModelComponent> {
  final Map<String, dynamic>? filter;
  final String? search;
  final String? orderBy;
  final bool ascending;
  final String? errorMessage;
  final Map<String, dynamic>? rpcParams;
  final int limit;
  final String? randomSeed;

  const ListState({
    this.filter,
    this.search,
    this.orderBy,
    this.ascending = false,
    this.errorMessage,
    this.rpcParams,
    this.limit = 10,
    this.randomSeed,
  });

  ListState<T> copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
    Map<String, dynamic>? rpcParams,
    int? limit,
    String? randomSeed,
  });
}

/// Implementación genérica de ListState que cubre los parámetros básicos
class FilterState<T extends ModelComponent> extends ListState<T> {
  const FilterState({
    super.filter,
    super.search,
    super.orderBy,
    super.ascending = false,
    super.errorMessage,
    super.rpcParams,
    super.limit = 10,
    super.randomSeed,
  });

  @override
  FilterState<T> copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
    Map<String, dynamic>? rpcParams,
    int? limit,
    String? randomSeed,
  }) =>
      FilterState<T>(
        filter: filter ?? this.filter,
        search: search ?? this.search,
        orderBy: orderBy ?? this.orderBy,
        ascending: ascending ?? this.ascending,
        errorMessage: errorMessage ?? this.errorMessage,
        rpcParams: rpcParams ?? this.rpcParams,
        limit: limit ?? this.limit,
        randomSeed: randomSeed ?? this.randomSeed,
      );
}
