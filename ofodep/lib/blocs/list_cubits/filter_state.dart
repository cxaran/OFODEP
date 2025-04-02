abstract class ListFilterState {
  final Map<String, dynamic>? filter;
  final String? search;
  final String? orderBy;
  final bool ascending;
  final String? newElementId;
  final String? errorMessage;

  const ListFilterState({
    this.filter,
    this.search,
    this.orderBy,
    this.ascending = false,
    this.newElementId,
    this.errorMessage,
  });

  /// Método que permite crear una copia modificada del estado.
  ListFilterState copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? newElementId,
    String? errorMessage,
  });
}

/// Implementación genérica de ListFilterState que cubre los parámetros básicos
class BasicListFilterState implements ListFilterState {
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

  const BasicListFilterState({
    this.filter,
    this.search,
    this.orderBy,
    this.ascending = false,
    this.newElementId,
    this.errorMessage,
  });

  @override
  BasicListFilterState copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? newElementId,
    String? errorMessage,
  }) =>
      BasicListFilterState(
        filter: filter ?? this.filter,
        search: search ?? this.search,
        orderBy: orderBy ?? this.orderBy,
        ascending: ascending ?? this.ascending,
        newElementId: newElementId ?? this.newElementId,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
