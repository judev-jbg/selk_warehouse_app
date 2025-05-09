import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/network/websocket_service.dart';
import '../../../domain/usecases/entry/scan_product.dart';
import '../../../domain/usecases/entry/get_scans.dart';
import '../../../mocks/entry_mocks.dart' as em;
import '../../../mocks/core_mocks.dart';
import '../../bloc/entry/entry_bloc.dart';
import '../../bloc/entry/entry_event.dart';
import '../../bloc/entry/entry_state.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/loading_overlay.dart';
import 'scans_page.dart';
import 'special_products_page.dart';

// Clases Mock para pruebas
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/scan.dart';
import '../../../domain/entities/supplier.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => EntryBloc(
            scanProduct: em.MockScanProduct(),
            getScans: em.MockGetScans(),
            webSocketService: MockWebSocketService(),
          ),
      child: _EntryPageContent(),
    );
  }
}

class _EntryPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrada (Picking)'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => SpecialProductsPage()));
            },
            tooltip: 'Buscar producto 9999',
          ),
        ],
      ),
      body: BlocConsumer<EntryBloc, EntryState>(
        listener: (context, state) {
          if (state is EntryError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ProductScanned && state.isNewScan) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Producto escaneado correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ReceivedRealTimeScanEvent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Nueva lectura recibida de otro dispositivo'),
                backgroundColor: AppColors.info,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is EntryLoading,
            child: Column(
              children: [
                SelkSearchBar(
                  onSearch: (value) {
                    context.read<EntryBloc>().add(
                      ScanProductEvent(barcode: value),
                    );
                  },
                  autofocus: true,
                  hintText: 'Escanear código de barras del producto',
                ),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lecturas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Prod. 9999',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          } else if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ScansPage()));
          } else if (index == 2) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => SpecialProductsPage()));
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EntryState state) {
    print('Estado de la lectura: ${state}');
    if (state is ProductScanned) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '¡Producto escaneado!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.product.description,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ref: ${state.product.reference}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cantidad: ',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  '${state.quantity} ${state.product.unit}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<EntryBloc>().add(ResetScanEvent());
              },
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Escanear otro producto'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => ScansPage()));
              },
              icon: Icon(Icons.list),
              label: Text('Ver todas las lecturas'),
            ),
          ],
        ),
      );
    } else if (state is ProductNotFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Producto no encontrado',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<EntryBloc>().add(ResetScanEvent());
              },
              icon: Icon(Icons.refresh),
              label: Text('Intentar de nuevo'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SpecialProductsPage()),
                );
              },
              icon: Icon(Icons.search),
              label: Text('Buscar producto especial (9999)'),
            ),
          ],
        ),
      );
    } else if (state is ProductNotOrdered) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber,
                size: 48,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Producto no pedido',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.product.description,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ref: ${state.product.reference}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<EntryBloc>().add(ResetScanEvent());
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Escanear otro'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Permitir registrar el producto aunque no esté pedido
                    _showConfirmDialog(context, state.product);
                  },
                  icon: Icon(Icons.add_circle),
                  label: Text('Registrar igual'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (state is EntryInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Escanee un código de barras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Los productos escaneados se registrarán automáticamente',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => ScansPage()));
                  },
                  icon: Icon(Icons.list),
                  label: Text('Ver lecturas'),
                ),
                SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SpecialProductsPage()),
                    );
                  },
                  icon: Icon(Icons.search),
                  label: Text('Buscar 9999'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container();
  }

  void _showConfirmDialog(BuildContext context, Product product) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Registrar producto no pedido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Está registrando un producto que no está en ningún pedido pendiente.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 16),
                Text(product.description),
                Text('Ref: ${product.reference}'),
                SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  final quantity =
                      double.tryParse(quantityController.text) ?? 1;

                  context.read<EntryBloc>().add(
                    RegisterSpecialProductEvent(
                      product: product,
                      quantity: quantity,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: Text('Registrar'),
              ),
            ],
          ),
    );
  }
}

class MockWebSocketService implements WebSocketService {
  final _eventsController = StreamController<WSEvent>.broadcast();

  @override
  Stream<WSEvent> get events => _eventsController.stream;

  @override
  Future<bool> connect() async {
    return true;
  }

  @override
  void disconnect() {}

  @override
  Future<bool> sendEvent(WSEvent event) async {
    _eventsController.add(event);
    return true;
  }

  @override
  void setAuthToken(String token) {}

  @override
  bool get isConnected => true;
}
