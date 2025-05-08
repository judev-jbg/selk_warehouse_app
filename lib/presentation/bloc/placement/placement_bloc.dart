import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/placement/search_product.dart';
import '../../../domain/usecases/placement/update_location.dart';
import '../../../domain/usecases/placement/update_stock.dart';
import 'placement_event.dart';
import 'placement_state.dart';

class PlacementBloc extends Bloc<PlacementEvent, PlacementState> {
  final SearchProduct searchProduct;
  final UpdateLocation updateLocation;
  final UpdateStock updateStock;

  PlacementBloc({
    required this.searchProduct,
    required this.updateLocation,
    required this.updateStock,
  }) : super(PlacementInitial()) {
    on<SearchProductEvent>(_onSearchProduct);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<UpdateStockEvent>(_onUpdateStock);
    on<ResetEvent>(_onReset);
  }

  Future<void> _onSearchProduct(
    SearchProductEvent event,
    Emitter<PlacementState> emit,
  ) async {
    emit(PlacementLoading());

    final result = await searchProduct(
      SearchProductParams(barcode: event.barcode),
    );

    result.fold(
      (failure) => emit(ProductNotFound(failure.message)),
      (product) => emit(ProductFound(product)),
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<PlacementState> emit,
  ) async {
    emit(PlacementLoading());

    final result = await updateLocation(
      UpdateLocationParams(
        productId: event.productId,
        newLocation: event.newLocation,
      ),
    );

    result.fold(
      (failure) => emit(PlacementError(failure.message)),
      (updatedProduct) => emit(LocationUpdateSuccess(updatedProduct)),
    );
  }

  Future<void> _onUpdateStock(
    UpdateStockEvent event,
    Emitter<PlacementState> emit,
  ) async {
    emit(PlacementLoading());

    final result = await updateStock(
      UpdateStockParams(productId: event.productId, newStock: event.newStock),
    );

    result.fold(
      (failure) => emit(PlacementError(failure.message)),
      (updatedProduct) => emit(StockUpdateSuccess(updatedProduct)),
    );
  }

  void _onReset(ResetEvent event, Emitter<PlacementState> emit) {
    emit(PlacementInitial());
  }
}
