import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_repository.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';

class ProductsListCubit extends ListCubit<ProductModel, BasicListFilterState> {
  String? storeId;

  ProductsListCubit({
    this.storeId,
    ProductRepository? productRepository,
    BasicListFilterState? initialState,
    super.limit,
  }) : super(
          initialState: initialState ?? const BasicListFilterState(),
          repository: productRepository ?? ProductRepository(),
        );

  /// Método para agregar un producto.
  /// [storeId] ID de la tienda donde se agregará el producto.
  /// [name] nombre del producto.
  /// [description] descripción del producto.
  /// [imageUrl] URL de la imagen del producto.
  /// [price] precio del producto.
  /// [category] categoría del producto.
  /// [tags] etiquetas del producto.
  Future<void> addProduct({
    required String storeId,
    required String name,
    String? description,
    String? imageUrl,
    num? price,
    String? category,
    List<String>? tags,
  }) async {
    final newProduct = ProductModel(
      id: '',
      storeId: storeId,
      storeName: '',
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      category: category,
      tags: tags,
    );

    await super.add(newProduct);
  }

  @override
  Future<List<ProductModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    if (storeId != null) {
      filter ??= {};
      filter['store_id'] = storeId;
    }
    return repository.getPaginated(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      orderBy: orderBy,
      ascending: ascending,
    );
  }
}
