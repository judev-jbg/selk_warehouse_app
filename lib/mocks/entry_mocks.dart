import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/failures.dart';
import '../domain/entities/product.dart';
import '../domain/entities/scan.dart';
import '../domain/entities/order.dart' as od;
import '../domain/entities/supplier.dart';
import '../domain/entities/delivery_note.dart';
import '../domain/usecases/entry/scan_product.dart';
import '../domain/usecases/usecase.dart' as np;
import '../domain/usecases/entry/get_scans.dart';
import '../domain/usecases/entry/update_scan.dart';
import '../domain/usecases/entry/delete_scan.dart';
import '../domain/usecases/entry/get_suppliers.dart';
import '../domain/usecases/entry/generate_delivery_note.dart';
import '../domain/repositories/entry_repository.dart';
import 'core_mocks.dart';

// Mock repository base
class MockEntryRepository implements EntryRepository {
  @override
  Future<Either<Failure, void>> deleteScan(String scanId) async {
    return Right(null);
  }

  @override
  Future<Either<Failure, Product>> findProductByBarcode(String barcode) async {
    return Right(
      Product(
        id: '1',
        reference: '5808  493256E',
        description: 'Tornillo hexagonal M8x40',
        barcode: barcode,
        location: 'A102',
        stock: 120.0,
        unit: 'unidades',
        status: 'Activo',
      ),
    );
  }

  @override
  Future<Either<Failure, DeliveryNote>> generateDeliveryNote(
    String supplierReference,
    List<String> scanIds,
  ) async {
    // Implementación mock
    return Right(
      DeliveryNote(
        id: 'DN1',
        number: 'ALB-2025-001',
        createdAt: DateTime.now().toIso8601String(),
        status: DeliveryNoteStatus.confirmed,
        supplier: Supplier(
          id: '1',
          name: 'Proveedor Ejemplo S.L.',
          code: 'PROV001',
        ),
        supplierReference: supplierReference,
        scans: [],
      ),
    );
  }

  @override
  Future<Either<Failure, List<Scan>>> getAllScans() async {
    // Implementación mock
    return Right([]);
  }

  @override
  Future<Either<Failure, List<Supplier>>> getAllSuppliers() async {
    // Implementación mock
    return Right([]);
  }

  @override
  Future<Either<Failure, List<od.Order>>> getPendingOrders({
    String? supplierId,
  }) async {
    // Implementación mock
    return Right([]);
  }

  @override
  Future<Either<Failure, Scan>> registerScan(
    String barcode, {
    String? orderId,
    String? supplierId,
  }) async {
    // Implementación mock
    return Right(
      Scan(
        id: '1',
        product: Product(
          id: '1',
          reference: '5808  493256E',
          description: 'Tornillo hexagonal M8x40',
          barcode: barcode,
          location: 'A102',
          stock: 120.0,
          unit: 'unidades',
          status: 'Activo',
        ),
        quantity: 10.0,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Product>>> searchSpecialProducts(
    String query,
  ) async {
    // Implementación mock
    return Right([]);
  }

  @override
  Future<Either<Failure, Scan>> updateScanQuantity(
    String scanId,
    double newQuantity,
  ) async {
    // Implementación mock
    return Right(
      Scan(
        id: scanId,
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
        quantity: newQuantity,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}

// Mock de ScanProduct
class MockScanProduct implements ScanProduct {
  final _mockRepo = MockEntryRepository();

  @override
  EntryRepository get repository => _mockRepo;

  final _products = {
    '7898422746759': Product(
      id: '1',
      reference: '5808  493256E',
      description: 'Tornillo hexagonal M8x40',
      barcode: '7898422746759',
      location: 'A102',
      stock: 120.0,
      unit: 'unidades',
      status: 'Activo',
    ),
    // ... resto de los productos
  };

  // Productos en pedidos pendientes
  final _orderedProducts = ['7898422746759', '7898422746760'];

  final _uuid = Uuid();
  final _mockSupplier = Supplier(
    id: '1',
    name: 'Proveedor Ejemplo S.L.',
    code: 'PROV001',
  );

  @override
  Future<Either<Failure, Scan>> call(ScanProductParams params) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    final product = _products[params.barcode];
    if (product == null) {
      return Left(
        ProductNotFoundFailure(
          'No se encontró ningún producto con el código ${params.barcode}',
        ),
      );
    }

    // Verificar si el producto está en algún pedido pendiente
    if (!_orderedProducts.contains(params.barcode)) {
      return Left(
        ProductNotOrderedFailure(
          message: 'El producto no está en ningún pedido pendiente',
          product: product,
        ),
      );
    }

    // Determinar la cantidad según las unidades de empaquetado
    // En este ejemplo, usamos un valor fijo
    final quantity = product.reference.contains('5808') ? 25.0 : 10.0;

    final scan = Scan(
      id: _uuid.v4(),
      product: product,
      quantity: quantity,
      createdAt: DateTime.now().toIso8601String(),
      supplier: _mockSupplier,
      userId:
          'current_user', // En una implementación real, obtendríamos el ID del usuario
    );

    return Right(scan);
  }
}

// Mock de GetScans
class MockGetScans implements GetScans {
  final _mockRepo = MockEntryRepository();

  @override
  EntryRepository get repository => _mockRepo;

  final _scans = <Scan>[];
  final _uuid = Uuid();

  MockGetScans() {
    // Crear algunas lecturas de ejemplo
    _scans.add(
      Scan(
        id: _uuid.v4(),
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
        createdAt:
            DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        supplier: Supplier(
          id: '1',
          name: 'Proveedor Ejemplo S.L.',
          code: 'PROV001',
        ),
      ),
    );

    _scans.add(
      Scan(
        id: _uuid.v4(),
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
        createdAt:
            DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        supplier: Supplier(
          id: '1',
          name: 'Proveedor Ejemplo S.L.',
          code: 'PROV001',
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Scan>>> call(np.NoParams params) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia
    return Right(_scans);
  }

  // Método para agregar una nueva lectura (usado para simular lecturas en tiempo real)
  void addScan(Scan scan) {
    _scans.add(scan);
  }
}

// Mock de UpdateScan
class MockUpdateScan implements UpdateScan {
  final _mockRepo = MockEntryRepository();

  @override
  EntryRepository get repository => _mockRepo;

  @override
  Future<Either<Failure, Scan>> call(UpdateScanParams params) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    // Crear una copia actualizada de la lectura
    final updatedScan = Scan(
      id: params.scanId,
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
      quantity: params.newQuantity,
      createdAt: '2025-05-08T10:30:00',
      supplier: Supplier(
        id: '1',
        name: 'Proveedor Ejemplo S.L.',
        code: 'PROV001',
      ),
    );

    return Right(updatedScan);
  }
}

// Mock de DeleteScan
class MockDeleteScan implements DeleteScan {
  final _mockRepo = MockEntryRepository();

  @override
  EntryRepository get repository => _mockRepo;

  @override
  Future<Either<Failure, void>> call(DeleteScanParams params) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia
    return Right(null);
  }
}

// Mock de GetAllSuppliers
class MockGetAllSuppliers implements GetAllSuppliers {
  final _mockRepo = MockEntryRepository();

  @override
  EntryRepository get repository => _mockRepo;

  final _suppliers = [
    Supplier(id: '1', name: 'Proveedor Ejemplo S.L.', code: 'PROV001'),
    Supplier(
      id: '2',
      name: 'Distribuciones Industriales S.A.',
      code: 'PROV002',
    ),
    Supplier(id: '3', name: 'Ferretería Global Inc.', code: 'PROV003'),
  ];

  @override
  Future<Either<Failure, List<Supplier>>> call(np.NoParams params) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia
    return Right(_suppliers);
  }
}

// Mock de GenerateDeliveryNote
class MockGenerateDeliveryNote implements GenerateDeliveryNote {
  final _mockRepo = MockEntryRepository();

  @override
  EntryRepository get repository => _mockRepo;

  @override
  Future<Either<Failure, DeliveryNote>> call(
    GenerateDeliveryNoteParams params,
  ) async {
    await Future.delayed(Duration(seconds: 2)); // Simular latencia

    final mockSupplier = Supplier(
      id: '1',
      name: 'Proveedor Ejemplo S.L.',
      code: 'PROV001',
    );

    final mockScans = [
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
        supplier: mockSupplier,
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
        supplier: mockSupplier,
      ),
    ];

    final mockDeliveryNote = DeliveryNote(
      id: 'DN1',
      number: 'ALB-2025-001',
      createdAt: DateTime.now().toIso8601String(),
      status: DeliveryNoteStatus.confirmed,
      supplier: mockSupplier,
      supplierReference: params.supplierReference,
      scans: mockScans,
    );

    return Right(mockDeliveryNote);
  }
}
