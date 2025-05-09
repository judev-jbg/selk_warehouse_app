import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/entry/scan_product.dart';
import '../../../domain/usecases/entry/get_scans.dart';
import '../../../domain/usecases/usecase.dart';
import '../../../domain/entities/product.dart';
import '../../../core/network/websocket_service.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/scan.dart';
import '../../../mocks/core_mocks.dart';
import '../../../domain/usecases/usecase.dart' as np;
import 'entry_event.dart';
import 'entry_state.dart';

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  final ScanProduct scanProduct;
  final GetScans getScans;
  final WebSocketService webSocketService;

  EntryBloc({
    required this.scanProduct,
    required this.getScans,
    required this.webSocketService,
  }) : super(EntryInitial()) {
    on<ScanProductEvent>(_onScanProduct);
    on<ResetScanEvent>(_onResetScan);
    on<GetAllScansEvent>(_onGetAllScans);
    on<ReceivedRealTimeScanEvent>(_onReceivedRealTimeScan);
    on<SearchSpecialProductsEvent>(_onSearchSpecialProducts);
    on<RegisterSpecialProductEvent>(_onRegisterSpecialProduct);

    // Suscribirse a eventos WebSocket
    _setupWebSocketListener();
  }

  void _setupWebSocketListener() {
    webSocketService.events.listen((event) {
      if (event.type == WSEventType.scan) {
        final data = event.data;
        add(
          ReceivedRealTimeScanEvent(
            barcode: data['barcode'],
            quantity: data['quantity'],
            userId: data['user_id'],
          ),
        );
      }
    });
  }

  Future<void> _onScanProduct(
    ScanProductEvent event,
    Emitter<EntryState> emit,
  ) async {
    emit(EntryLoading());

    final result = await scanProduct(
      ScanProductParams(
        barcode: event.barcode,
        orderId: event.orderId,
        supplierId: event.supplierId,
      ),
    );

    result.fold(
      (failure) {
        if (failure is ProductNotFoundFailure) {
          emit(ProductNotFound(failure.message));
        } else if (failure.message.contains('no está en ningún pedido')) {
          // Verificar por mensaje en lugar de tipo
          final product =
              failure.runtimeType.toString().contains(
                    'ProductNotOrderedFailure',
                  )
                  ? (failure as dynamic).product as Product
                  : null;

          if (product != null) {
            emit(ProductNotOrdered(product: product, message: failure.message));
          } else {
            emit(EntryError(failure.message));
          }
        } else {
          emit(EntryError(failure.message));
        }
      },
      (scan) {
        // Notificar a otros dispositivos sobre el escaneo
        _notifyOtherDevices(scan);

        emit(ProductScanned(product: scan.product, quantity: scan.quantity));
      },
    );
  }

  void _onResetScan(ResetScanEvent event, Emitter<EntryState> emit) {
    emit(EntryInitial());
  }

  Future<void> _onGetAllScans(
    GetAllScansEvent event,
    Emitter<EntryState> emit,
  ) async {
    emit(EntryLoading());

    final result = await getScans(np.NoParams());

    result.fold(
      (failure) => emit(EntryError(failure.message)),
      (scans) => emit(ScansLoaded(scans)),
    );
  }

  void _onReceivedRealTimeScan(
    ReceivedRealTimeScanEvent event,
    Emitter<EntryState> emit,
  ) {
    // Implementar lógica para actualizar la UI con lecturas en tiempo real
    // Por ahora, simplemente notificamos al usuario
    final currentState = state;

    // Si estamos en ScansLoaded, actualizar la lista de scans
    if (currentState is ScansLoaded) {
      add(GetAllScansEvent());
    }
  }

  Future<void> _onSearchSpecialProducts(
    SearchSpecialProductsEvent event,
    Emitter<EntryState> emit,
  ) async {
    emit(EntryLoading());

    // Por ahora, mockear la búsqueda de productos especiales (9999)
    await Future.delayed(Duration(seconds: 1));

    if (event.query.toLowerCase().contains('9999')) {
      final mockProducts = [
        Product(
          id: 'special1',
          reference: '9999  503',
          description: 'Tornillo especial zincado',
          barcode: '',
          location: 'B201',
          stock: 0,
          unit: 'unidades',
          status: 'Activo',
        ),
        Product(
          id: 'special2',
          reference: '9999  603',
          description: 'Brida especial',
          barcode: '',
          location: 'C102',
          stock: 0,
          unit: 'unidades',
          status: 'Activo',
        ),
      ];

      emit(SpecialProductsFound(products: mockProducts, query: event.query));
    } else {
      emit(
        SpecialProductsNotFound(
          query: event.query,
          message: 'No se encontraron productos especiales con "$event.query"',
        ),
      );
    }
  }

  Future<void> _onRegisterSpecialProduct(
    RegisterSpecialProductEvent event,
    Emitter<EntryState> emit,
  ) async {
    emit(EntryLoading());

    // Mockear el registro de un producto especial
    await Future.delayed(Duration(seconds: 1));

    emit(ProductScanned(product: event.product, quantity: event.quantity));

    // Notificar a otros dispositivos
    _notifySpecialProductRegistration(event.product, event.quantity);
  }

  void _notifyOtherDevices(Scan scan) {
    webSocketService.sendEvent(
      WSEvent(
        type: WSEventType.scan,
        data: {
          'barcode': scan.product.barcode,
          'quantity': scan.quantity,
          'user_id': scan.userId ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  void _notifySpecialProductRegistration(Product product, double quantity) {
    webSocketService.sendEvent(
      WSEvent(
        type: WSEventType.scan,
        data: {
          'barcode': product.barcode,
          'reference': product.reference,
          'description': product.description,
          'quantity': quantity,
          'user_id':
              'current_user', // En una implementación real, obtendríamos el ID del usuario
          'timestamp': DateTime.now().toIso8601String(),
          'is_special': true,
        },
      ),
    );
  }
}
