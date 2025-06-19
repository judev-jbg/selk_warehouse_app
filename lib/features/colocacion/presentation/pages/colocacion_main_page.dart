import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/entities/product_search_result.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/common/custom_app_bar.dart';
import '../../../../shared/widgets/common/loading_overlay.dart';
import '../bloc/colocacion_bloc.dart';
import '../bloc/colocacion_event.dart';
import '../bloc/colocacion_state.dart';
import '../widgets/barcode_search_bar.dart';
import '../widgets/product_result_card.dart';
import '../widgets/error_message_card.dart';
import '../widgets/colocacion_bottom_navigation.dart';

class ColocacionMainPage extends StatefulWidget {
  const ColocacionMainPage({Key? key}) : super(key: key);

  @override
  State<ColocacionMainPage> createState() => _ColocacionMainPageState();
}

class _ColocacionMainPageState extends State<ColocacionMainPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Establecer foco automático al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    // Escuchar cambios en el texto para detectar sufijos del escáner
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Detectar cuando se completa la lectura del código de barras
  void _onSearchTextChanged() {
    final text = _searchController.text;

    // Detectar sufijos del escáner PDA: \n, \t, \r
    if (text.contains('\n') || text.contains('\t') || text.contains('\r')) {
      // Limpiar sufijos y buscar automáticamente
      final cleanBarcode = text
          .replaceAll('\n', '')
          .replaceAll('\t', '')
          .replaceAll('\r', '')
          .trim();

      if (cleanBarcode.isNotEmpty) {
        _performSearch(cleanBarcode);
      }
    }
  }

  /// Ejecutar búsqueda de producto
  void _performSearch(String barcode) {
    if (barcode.trim().isEmpty) return;

    // Limpiar barra de búsqueda
    _searchController.clear();

    // Mantener foco en la barra de búsqueda
    _searchFocusNode.requestFocus();

    // Ejecutar búsqueda
    context.read<ColocacionBloc>().add(
          ColocacionSearchProduct(barcode: barcode.trim()),
        );
  }

  /// Limpiar búsqueda y resultados
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    context.read<ColocacionBloc>().add(ColocacionClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ColocacionBloc, ColocacionState>(
      listener: (context, state) {
        setState(() {
          _isLoading = state is ColocacionLoading;
        });

        // Mantener foco en la barra de búsqueda después de operaciones
        if (state is ColocacionProductFound ||
            state is ColocacionProductNotFound ||
            state is ColocacionUpdateSuccess ||
            state is ColocacionError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _searchFocusNode.requestFocus();
          });
        }

        // Mostrar mensajes de éxito
        if (state is ColocacionUpdateSuccess) {
          _showSuccessSnackBar(state.message);
        }

        // Mostrar mensajes de etiqueta creada
        if (state is ColocacionLabelCreated) {
          _showSuccessSnackBar('Etiqueta creada para impresión');
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Colocación',
          showBackButton: true,
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: Column(
            children: [
              // Barra de búsqueda siempre visible
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: BarcodeSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSearch: _performSearch,
                  onClear: _clearSearch,
                ),
              ),

              // Contenido principal
              Expanded(
                child: BlocBuilder<ColocacionBloc, ColocacionState>(
                  builder: (context, state) {
                    return _buildContent(context, state);
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const ColocacionBottomNavigation(
          currentIndex: 1, // Colocación
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColocacionState state) {
    if (state is ColocacionInitial) {
      return _buildWelcomeContent();
    } else if (state is ColocacionProductFound) {
      return ProductResultCard(
        searchResult: state.searchResult,
        onLocationUpdate: (productId, newLocation) {
          context.read<ColocacionBloc>().add(
                ColocacionUpdateLocation(
                  productId: productId,
                  newLocation: newLocation,
                ),
              );
        },
        onStockUpdate: (productId, newStock) {
          context.read<ColocacionBloc>().add(
                ColocacionUpdateStock(
                  productId: productId,
                  newStock: newStock,
                ),
              );
        },
      );
    } else if (state is ColocacionProductNotFound) {
      return ErrorMessageCard(
        title: 'Producto no encontrado',
        message: state.error,
        icon: Icons.search_off,
        actionText: 'Buscar otro',
        onAction: _clearSearch,
      );
    } else if (state is ColocacionUpdateSuccess) {
      return ProductResultCard(
        searchResult: ProductSearchResult(
          found: true,
          product: state.updatedProduct,
          cached: false,
          searchTime: 0,
          timestamp: DateTime.now(),
        ),
        onLocationUpdate: (productId, newLocation) {
          context.read<ColocacionBloc>().add(
                ColocacionUpdateLocation(
                  productId: productId,
                  newLocation: newLocation,
                ),
              );
        },
        onStockUpdate: (productId, newStock) {
          context.read<ColocacionBloc>().add(
                ColocacionUpdateStock(
                  productId: productId,
                  newStock: newStock,
                ),
              );
        },
      );
    } else if (state is ColocacionError) {
      return ErrorMessageCard(
        title: 'Error',
        message: state.message,
        icon: Icons.error_outline,
        actionText: 'Reintentar',
        onAction: _clearSearch,
      );
    }

    return _buildWelcomeContent();
  }

  Widget _buildWelcomeContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Escanear Código de Barras',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Apunte la PDA hacia el código de barras del producto o ingrese el código manualmente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
