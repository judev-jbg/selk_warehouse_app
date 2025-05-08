import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product.dart';
import 'entry_event.dart';
import 'entry_state.dart';

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  // Temporalmente utiliza funciones vacías hasta que implementemos los casos de uso reales
  final dynamic scanProduct;
  final dynamic getScans;

  EntryBloc({required this.scanProduct, required this.getScans})
    : super(EntryInitial()) {
    on<ScanProductEvent>(_onScanProduct);
    on<ResetScanEvent>(_onResetScan);
  }

  Future<void> _onScanProduct(
    ScanProductEvent event,
    Emitter<EntryState> emit,
  ) async {
    emit(EntryLoading());

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
      emit(ProductScanned(product: mockProduct, quantity: 1.0));
    } else {
      emit(
        ProductNotFound(
          'No se encontró el producto con código ${event.barcode}',
        ),
      );
    }
  }

  void _onResetScan(ResetScanEvent event, Emitter<EntryState> emit) {
    emit(EntryInitial());
  }
}
