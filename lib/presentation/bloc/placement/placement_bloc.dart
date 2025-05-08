import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product.dart';
import 'placement_event.dart';
import 'placement_state.dart';

class PlacementBloc extends Bloc<PlacementEvent, PlacementState> {
  // Temporalmente utiliza funciones vacías hasta que implementemos los casos de uso reales
  final dynamic searchProduct;
  final dynamic updateLocation;
  final dynamic updateStock;

  PlacementBloc({
    required this.searchProduct,
    required this.updateLocation,
    required this.updateStock,
  }) : super(PlacementInitial()) {
    on<SearchProductEvent>(_onSearchProduct);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<UpdateStockEvent>(_onUpdateStock);
  }

  Future<void> _onSearchProduct(
    SearchProductEvent event,
    Emitter<PlacementState> emit,
  ) async {
    emit(PlacementLoading());

    // Implementación temporal hasta que tengamos el repositorio real
    await Future.delayed(Duration(seconds: 1));

    // Para pruebas, creamos un producto ficticio
    if (event.barcode == '1234567890123') {
      final mockProduct = Product(
        id: '1',
        reference: 'REF-001',
        description: 'Producto de prueba',
        barcode: event.barcode,
        location: 'A-01-02',
        stock: 100.0,
        unit: 'UND',
        status: 'Activo',
      );
      emit(ProductFound(mockProduct));
    } else {
      emit(
        ProductNotFound(
          'No se encontró el producto con código ${event.barcode}',
        ),
      );
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<PlacementState> emit,
  ) async {
    emit(PlacementLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos una actualización exitosa
    final mockProduct = Product(
      id: event.productId,
      reference: 'REF-001',
      description: 'Producto de prueba',
      barcode: '1234567890123',
      location: event.newLocation,
      stock: 100.0,
      unit: 'UND',
      status: 'Activo',
    );

    emit(LocationUpdateSuccess(mockProduct));
  }

  Future<void> _onUpdateStock(
    UpdateStockEvent event,
    Emitter<PlacementState> emit,
  ) async {
    emit(PlacementLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos una actualización exitosa
    final mockProduct = Product(
      id: event.productId,
      reference: 'REF-001',
      description: 'Producto de prueba',
      barcode: '1234567890123',
      location: 'A-01-02',
      stock: event.newStock,
      unit: 'UND',
      status: 'Activo',
    );

    emit(StockUpdateSuccess(mockProduct));
  }
}
