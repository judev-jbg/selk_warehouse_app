import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_color.dart';
import '../../bloc/entry/entry_bloc.dart';
import '../../bloc/entry/entry_event.dart';
import '../../bloc/entry/entry_state.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/loading_overlay.dart';
import 'scans_page.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              EntryBloc(scanProduct: context.read(), getScans: context.read()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Entrada (Picking)'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocConsumer<EntryBloc, EntryState>(
          listener: (context, state) {
            if (state is EntryError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ProductScanned) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Producto escaneado correctamente'),
                  backgroundColor: AppColors.success,
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
              icon: Icon(Icons.logout),
              label: 'Cerrar Sesión',
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
              // Cerrar sesión - implementar lógica
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EntryState state) {
    if (state is ProductScanned || state is EntryInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: state is ProductScanned ? AppColors.success : Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              state is ProductScanned
                  ? '¡Producto escaneado!'
                  : 'Escanee un código de barras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              state is ProductScanned
                  ? '${state.product.description}\nCantidad: ${state.quantity}'
                  : 'Los productos escaneados se registrarán automáticamente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (state is ProductScanned) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Limpiar el estado actual y preparar para un nuevo escaneo
                  context.read<EntryBloc>().add(ResetScanEvent());
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Escanear otro producto'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    } else if (state is ProductNotFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              'Producto no encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Limpiar el estado actual y preparar para un nuevo escaneo
                context.read<EntryBloc>().add(ResetScanEvent());
              },
              icon: Icon(Icons.refresh),
              label: Text('Intentar de nuevo'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container();
  }
}
