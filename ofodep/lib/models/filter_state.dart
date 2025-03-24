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
    String? errorMessage,
  });
}
