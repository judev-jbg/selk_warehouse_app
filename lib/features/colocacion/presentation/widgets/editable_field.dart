// lib/features/colocacion/presentation/widgets/editable_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isRequired;
  final String? placeholder;
  final TextInputType keyboardType;
  final String? Function(String)? validator;
  final Function(String) onSave;

  const EditableField({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.isRequired = false,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.validator,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _cancelEdit();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
      _errorText = null;
    });

    _controller.text = widget.value;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _errorText = null;
    });
    _controller.text = widget.value;
    _focusNode.unfocus();
  }

  void _saveEdit() {
    final value = _controller.text.trim();

    // Validar el valor si hay validador
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }

    // Si el valor no cambió, cancelar edición
    if (value == widget.value.trim()) {
      _cancelEdit();
      return;
    }

    // Guardar el nuevo valor
    widget.onSave(value);

    setState(() {
      _isEditing = false;
      _errorText = null;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isEditing
              ? (_errorText != null ? AppColors.error : AppColors.primary)
              : AppColors.divider,
          width: _isEditing ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _isEditing ? AppColors.surface : AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del campo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color:
                      _isEditing ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isEditing
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (widget.isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
                const Spacer(),

                // Botones de acción
                if (_isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.error,
                    onPressed: _cancelEdit,
                    tooltip: 'Cancelar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, size: 20),
                    color: AppColors.success,
                    onPressed: _saveEdit,
                    tooltip: 'Guardar',
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: AppColors.textHint,
                    onPressed: _startEdit,
                    tooltip: 'Editar',
                  ),
                ],
              ],
            ),
          ),

          // Campo de texto
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onDoubleTap: _isEditing ? null : _startEdit,
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: widget.keyboardType,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        errorText: _errorText,
                        errorStyle: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                      inputFormatters: widget.keyboardType ==
                              TextInputType.numberWithOptions(decimal: true)
                          ? [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'))
                            ]
                          : widget.label.toLowerCase().contains('localización')
                              ? [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9]')),
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    return newValue.copyWith(
                                        text: newValue.text.toUpperCase());
                                  }),
                                ]
                              : null,
                      onSubmitted: (_) => _saveEdit(),
                    )
                  : Text(
                      widget.value.isNotEmpty
                          ? widget.value
                          : 'Doble clic para editar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.value.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontStyle: widget.value.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
            ),
          ),

          // Indicador de cambio
          if (_isEditing && _controller.text.trim() != widget.value.trim())
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Valor modificado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
