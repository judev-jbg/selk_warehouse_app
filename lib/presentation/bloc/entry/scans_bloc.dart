import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/scan.dart';
import 'scans_event.dart';
import 'scans_state.dart';

class ScansBloc extends Bloc<ScansEvent, ScansState> {
  // Temporalmente utiliza funciones vacías hasta que implementemos los casos de uso reales
  final dynamic getScans;
  final dynamic updateScan;
  final dynamic deleteScan;

  ScansBloc({
    required this.getScans,
    required this.updateScan,
    required this.deleteScan,
  }) : super(ScansInitial()) {
    on<GetScansEvent>(_onGetScans);
    on<UpdateScanEvent>(_onUpdateScan);
    on<DeleteScanEvent>(_onDeleteScan);
  }

  Future<void> _onGetScans(
    GetScansEvent event,
    Emitter<ScansState> emit,
  ) async {
    emit(ScansLoading());

    // Implementación temporal hasta que tengamos el repositorio real
    await Future.delayed(Duration(seconds: 1));

    // Para pruebas, creamos escaneos ficticios
    final mockProduct = Product(
      id: '1',
      reference: 'REF-001',
      description: 'Producto de prueba',
      barcode: '1234567890123',
      location: 'A-01-02',
      stock: 100.0,
      unit: 'UND',
      status: 'Activo',
    );

    final mockScans = [
      Scan(
        id: '1',
        product: mockProduct,
        quantity: 10,
        createdAt: DateTime.now().toString(),
      ),
      Scan(
        id: '2',
        product: mockProduct,
        quantity: 5,
        createdAt: DateTime.now().subtract(Duration(hours: 1)).toString(),
        supplierId: 'PROV-001',
      ),
    ];

    if (mockScans.isEmpty) {
      emit(ScansEmpty());
    } else {
      emit(ScansLoaded(mockScans));
    }
  }

  Future<void> _onUpdateScan(
    UpdateScanEvent event,
    Emitter<ScansState> emit,
  ) async {
    emit(ScansLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos una actualización exitosa
    final mockProduct = Product(
      id: '1',
      reference: 'REF-001',
      description: 'Producto de prueba',
      barcode: '1234567890123',
      location: 'A-01-02',
      stock: 100.0,
      unit: 'UND',
      status: 'Activo',
    );

    final updatedScan = Scan(
      id: event.scanId,
      product: mockProduct,
      quantity: event.newQuantity,
      createdAt: DateTime.now().toString(),
    );

    emit(ScanUpdateSuccess(updatedScan));

    // Recargamos la lista actualizada
    add(GetScansEvent());
  }

  Future<void> _onDeleteScan(
    DeleteScanEvent event,
    Emitter<ScansState> emit,
  ) async {
    emit(ScansLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos una eliminación exitosa
    emit(ScanDeleteSuccess());

    // Recargamos la lista actualizada
    add(GetScansEvent());
  }
}
