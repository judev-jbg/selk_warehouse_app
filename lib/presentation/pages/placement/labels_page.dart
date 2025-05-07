import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_color.dart';
import '../../../domain/entities/label.dart';
import '../../bloc/placement/labels_bloc.dart';
import '../../bloc/placement/labels_event.dart';
import '../../bloc/placement/labels_state.dart';

class LabelsPage extends StatelessWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => LabelsBloc(
            getLabels: context.read(),
            printLabels: context.read(),
            deleteLabel: context.read(),
          )..add(GetLabelsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Etiquetas Pendientes'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocConsumer<LabelsBloc, LabelsState>(
          listener: (context, state) {
            if (state is LabelsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is LabelsPrintSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Etiquetas enviadas a imprimir correctamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is LabelDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Etiqueta eliminada correctamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LabelsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is LabelsLoaded) {
              return _buildLabelsList(context, state.labels);
            } else if (state is LabelsEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.label_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay etiquetas pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Las etiquetas se generan al modificar la ubicación de un producto',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container();
          },
        ),
        bottomNavigationBar: BlocBuilder<LabelsBloc, LabelsState>(
          builder: (context, state) {
            if (state is LabelsLoaded && state.labels.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<LabelsBloc>().add(
                      PrintLabelsEvent(
                        labelIds: state.labels.map((e) => e.id).toList(),
                      ),
                    );
                  },
                  child: Text('Imprimir Etiquetas Seleccionadas'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              );
            }
            return SizedBox(height: 0);
          },
        ),
      ),
    );
  }

  Widget _buildLabelsList(BuildContext context, List<Label> labels) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: labels.length,
      itemBuilder: (context, index) {
        final label = labels[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            title: Text(
              label.product.description,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ref: ${label.product.reference}'),
                Text('Ubicación: ${label.product.location}'),
                Text('Generada: ${label.createdAt}'),
              ],
            ),
            secondary: IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                context.read<LabelsBloc>().add(
                  DeleteLabelEvent(labelId: label.id),
                );
              },
            ),
            value: label.selected,
            onChanged: (value) {
              context.read<LabelsBloc>().add(
                ToggleLabelSelectionEvent(
                  labelId: label.id,
                  selected: value ?? false,
                ),
              );
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }
}
