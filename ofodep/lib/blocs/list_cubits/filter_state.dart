import 'package:ofodep/models/abstract_model.dart';

abstract class ListState<T extends ModelComponent> {
  final Map<String, dynamic>? filter;
  final String? search;
  final String? orderBy;
  final bool ascending;
  final String? newElementId;
  final String? errorMessage;
  final Map<String, dynamic>? params;

  const ListState({
    this.filter,
    this.search,
    this.orderBy,
    this.ascending = false,
    this.newElementId,
    this.errorMessage,
    this.params,
  });

  ListState<T> copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? newElementId,
    String? errorMessage,
    Map<String, dynamic>? params,
  });
}

/// Implementación genérica de ListState que cubre los parámetros básicos
class FilterState<T extends ModelComponent> implements ListState<T> {
  @override
  final Map<String, dynamic>? filter;
  @override
  final String? search;
  @override
  final String? orderBy;
  @override
  final bool ascending;
  @override
  final String? newElementId;
  @override
  final String? errorMessage;
  @override
  final Map<String, dynamic>? params;

  const FilterState({
    this.filter,
    this.search,
    this.orderBy,
    this.ascending = false,
    this.newElementId,
    this.errorMessage,
    this.params,
  });

  @override
  FilterState<T> copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? newElementId,
    String? errorMessage,
    Map<String, dynamic>? params,
  }) =>
      FilterState<T>(
        filter: filter ?? this.filter,
        search: search ?? this.search,
        orderBy: orderBy ?? this.orderBy,
        ascending: ascending ?? this.ascending,
        newElementId: newElementId ?? this.newElementId,
        errorMessage: errorMessage ?? this.errorMessage,
        params: params ?? this.params,
      );
}
