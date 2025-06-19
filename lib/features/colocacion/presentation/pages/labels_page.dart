// lib/features/colocacion/presentation/pages/labels_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/common/custom_app_bar.dart';
import '../../../../shared/widgets/common/loading_overlay.dart';
import '../bloc/colocacion_bloc.dart';
import '../bloc/colocacion_event.dart';
import '../bloc/colocacion_state.dart';
import '../widgets/label_item_card.dart';
import '../widgets/colocacion_bottom_navigation.dart';
import '../widgets/error_message_card.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  State<LabelsPage> createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  final Set<String> _selectedLabels = <String>{};
  bool _isLoading = false;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadPendingLabels();
  }

  void _loadPendingLabels() {
    context.read<ColocacionBloc>().add(ColocacionLoadPendingLabels());
  }

  void _toggleSelection(String labelId) {
    setState(() {
      if (_selectedLabels.contains(labelId)) {
        _selectedLabels.remove(labelId);
      } else {
        _selectedLabels.add(labelId);
      }
      _isSelectionMode = _selectedLabels.isNotEmpty;
    });
  }

  void _selectAll(List<String> allLabelIds) {
    setState(() {
      _selectedLabels.addAll(allLabelIds);
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedLabels.clear();
      _isSelectionMode = false;
    });
  }

  void _printSelectedLabels() {
    if (_selectedLabels.isEmpty) return;

    context.read<ColocacionBloc>().add(
          ColocacionMarkLabelsAsPrinted(labelIds: _selectedLabels.toList()),
        );
  }

  void _deleteSelectedLabels() {
    if (_selectedLabels.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Etiquetas'),
        content: Text(
          '¿Está seguro de que desea eliminar ${_selectedLabels.length} etiqueta${_selectedLabels.length > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ColocacionBloc>().add(
                    ColocacionDeleteLabels(labelIds: _selectedLabels.toList()),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ColocacionBloc, ColocacionState>(
      listener: (context, state) {
        setState(() {
          _isLoading = state is ColocacionLoading;
        });

        if (state is ColocacionLabelsMarkedAsPrinted) {
          _clearSelection();
          _showSuccessSnackBar(
              '${state.count} etiqueta${state.count > 1 ? 's' : ''} marcada${state.count > 1 ? 's' : ''} como impresa${state.count > 1 ? 's' : ''}');
        }

        if (state is ColocacionLabelsDeleted) {
          _clearSelection();
          _showSuccessSnackBar(
              '${state.count} etiqueta${state.count > 1 ? 's' : ''} eliminada${state.count > 1 ? 's' : ''}');
        }

        if (state is ColocacionError) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _isSelectionMode
              ? '${_selectedLabels.length} seleccionada${_selectedLabels.length > 1 ? 's' : ''}'
              : 'Etiquetas',
          actions: _buildAppBarActions(),
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: BlocBuilder<ColocacionBloc, ColocacionState>(
            builder: (context, state) {
              return _buildContent(context, state);
            },
          ),
        ),
        bottomNavigationBar: const ColocacionBottomNavigation(
          currentIndex: 2, // Etiquetas
        ),
        floatingActionButton: _isSelectionMode ? _buildFloatingActions() : null,
      ),
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (!_isSelectionMode) {
      return [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadPendingLabels,
          tooltip: 'Actualizar',
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: _clearSelection,
        tooltip: 'Cancelar selección',
      ),
    ];
  }

  Widget _buildContent(BuildContext context, ColocacionState state) {
    if (state is ColocacionLabelsLoaded) {
      final labels = state.labels;

      if (labels.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          // Header con información y acciones
          _buildHeader(labels.length),

          // Lista de etiquetas
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadPendingLabels(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  final isSelected = _selectedLabels.contains(label.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LabelItemCard(
                      label: label,
                      isSelected: isSelected,
                      isSelectionMode: _isSelectionMode,
                      onTap: () => _toggleSelection(label.id),
                      onLongPress: () => _toggleSelection(label.id),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else if (state is ColocacionError) {
      return ErrorMessageCard(
        title: 'Error al cargar etiquetas',
        message: state.message,
        icon: Icons.error_outline,
        actionText: 'Reintentar',
        onAction: _loadPendingLabels,
      );
    }

    return _buildEmptyState();
  }

  Widget _buildHeader(int totalLabels) {
    final pendingCount =
        totalLabels; // Todas las etiquetas mostradas son pendientes

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.label,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etiquetas Pendientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$pendingCount etiqueta${pendingCount != 1 ? 's' : ''} lista${pendingCount != 1 ? 's' : ''} para imprimir',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isSelectionMode && totalLabels > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectAll(
                      context.read<ColocacionBloc>().state
                              is ColocacionLabelsLoaded
                          ? (context.read<ColocacionBloc>().state
                                  as ColocacionLabelsLoaded)
                              .labels
                              .map((l) => l.id)
                              .toList()
                          : [],
                    ),
                    icon: const Icon(Icons.select_all, size: 18),
                    label: const Text('Seleccionar Todo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ErrorMessageCard(
      title: 'Sin Etiquetas',
      message:
          'No hay etiquetas pendientes para imprimir.\n\nLas etiquetas se crean automáticamente al actualizar la localización de un producto.',
      icon: Icons.label_off,
      actionText: 'Ir a Colocación',
      onAction: () => Navigator.of(context).pushReplacementNamed('/colocacion'),
      backgroundColor: AppColors.info.withOpacity(0.05),
      iconColor: AppColors.info,
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de eliminar
        FloatingActionButton(
          heroTag: 'delete',
          onPressed: _deleteSelectedLabels,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnPrimary,
          child: const Icon(Icons.delete),
        ),

        const SizedBox(height: 12),

        // Botón de imprimir
        FloatingActionButton.extended(
          heroTag: 'print',
          onPressed: _printSelectedLabels,
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.textOnPrimary,
          icon: const Icon(Icons.print),
          label: Text('Imprimir (${_selectedLabels.length})'),
        ),
      ],
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
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
