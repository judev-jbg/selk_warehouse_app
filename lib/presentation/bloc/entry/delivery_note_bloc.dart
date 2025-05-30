import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/entry/get_suppliers.dart' as gs;
import '../../../domain/usecases/entry/generate_delivery_note.dart';
import '../../../domain/entities/scan.dart';
import '../../../domain/usecases/usecase.dart';
import 'delivery_note_event.dart';
import 'delivery_note_state.dart';

// Mock classes
import '../../../domain/entities/product.dart';
import '../../../domain/entities/supplier.dart';

class DeliveryNoteBloc extends Bloc<DeliveryNoteEvent, DeliveryNoteState> {
  final gs.GetAllSuppliers getAllSuppliers;
  final GenerateDeliveryNote generateDeliveryNote;

  // Estado interno
  List<Scan> _scans = [];
  String? _selectedSupplierId;

  DeliveryNoteBloc({
    required this.getAllSuppliers,
    required this.generateDeliveryNote,
  }) : super(DeliveryNoteInitial()) {
    on<GetSuppliersEvent>(_onGetSuppliers);
    on<SelectSupplierEvent>(_onSelectSupplier);
    on<GenerateDeliveryNoteEvent>(_onGenerateDeliveryNote);
  }

  Future<void> _onGetSuppliers(
    GetSuppliersEvent event,
    Emitter<DeliveryNoteState> emit,
  ) async {
    emit(DeliveryNoteLoading());

    final result = await getAllSuppliers(NoParams());

    result.fold(
      (failure) => emit(DeliveryNoteError(failure.message)),
      (suppliers) => emit(SuppliersLoaded(suppliers)),
    );
  }

  Future<void> _onSelectSupplier(
    SelectSupplierEvent event,
    Emitter<DeliveryNoteState> emit,
  ) async {
    emit(DeliveryNoteLoading());

    _selectedSupplierId = event.supplierId;

    // En una implementación real, aquí obtendríamos las lecturas
    // filtradas por el proveedor seleccionado.
    // Por ahora, simulamos con datos mock.

    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    if (_selectedSupplierId == '1') {
      // Mockear scans para el proveedor 1
      _scans = _getMockScansForSupplier(_selectedSupplierId!);
    } else {
      // Para otros proveedores, no hay scans
      _scans = [];
    }

    emit(ScansForDeliveryNoteLoaded(_scans));
  }

  Future<void> _onGenerateDeliveryNote(
    GenerateDeliveryNoteEvent event,
    Emitter<DeliveryNoteState> emit,
  ) async {
    if (_scans.isEmpty) {
      emit(DeliveryNoteError('No hay lecturas para generar albarán'));
      return;
    }

    emit(DeliveryNoteLoading());

    final scanIds = _scans.map((scan) => scan.id).toList();

    final result = await generateDeliveryNote(
      GenerateDeliveryNoteParams(
        supplierReference: event.supplierReference,
        scanIds: scanIds,
      ),
    );

    result.fold(
      (failure) => emit(DeliveryNoteError(failure.message)),
      (deliveryNote) => emit(DeliveryNoteGenerated(deliveryNote)),
    );
  }

  // Mock helper
  List<Scan> _getMockScansForSupplier(String supplierId) {
    if (supplierId == '1') {
      return [
        Scan(
          id: '1',
          product: Product(
            id: '1',
            reference: '5808  493256E',
            description: 'Tornillo hexagonal M8x40',
            barcode: '7898422746759',
            location: 'A102',
            stock: 120.0,
            unit: 'unidades',
            status: 'Activo',
          ),
          quantity: 25.0,
          createdAt: '2025-05-08T10:30:00',
          supplier: Supplier(
            id: '1',
            name: 'Proveedor Ejemplo S.L.',
            code: 'PROV001',
          ),
        ),
        Scan(
          id: '2',
          product: Product(
            id: '2',
            reference: '5810  493258E',
            description: 'Tornillo hexagonal M10x60',
            barcode: '7898422746760',
            location: 'A103',
            stock: 85.0,
            unit: 'unidades',
            status: 'Activo',
          ),
          quantity: 10.0,
          createdAt: '2025-05-08T11:15:00',
          supplier: Supplier(
            id: '1',
            name: 'Proveedor Ejemplo S.L.',
            code: 'PROV001',
          ),
        ),
      ];
    }

    return [];
  }
}
