import 'package:flutter/material.dart';
import '../../../core/themes/app_color.dart';

class SelkSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function()? onBarcodeScanned;
  final bool autofocus;
  final String hintText;

  const SelkSearchBar({
    Key? key,
    required this.onSearch,
    this.onBarcodeScanned,
    this.autofocus = true,
    this.hintText = 'Escanear código de barras',
  }) : super(key: key);

  @override
  _SelkSearchBarState createState() => _SelkSearchBarState();
}

class _SelkSearchBarState extends State<SelkSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Configurar listener para detectar cuando se completa una búsqueda
    _controller.addListener(() {
      // La PDA está configurada para agregar \n o \t después de escanear
      if (_controller.text.endsWith('\n') || _controller.text.endsWith('\t')) {
        final searchText = _controller.text.trim();
        widget.onSearch(searchText);

        if (widget.onBarcodeScanned != null) {
          widget.onBarcodeScanned!();
        }

        // Limpiar el campo y volver a enfocar
        Future.delayed(Duration(milliseconds: 100), () {
          _controller.clear();
          _focusNode.requestFocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: AppColors.primary),
            onPressed: () {
              _controller.clear();
              _focusNode.requestFocus();
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onSearch(value);
            _controller.clear();
            _focusNode.requestFocus();
          }
        },
      ),
    );
  }
}
