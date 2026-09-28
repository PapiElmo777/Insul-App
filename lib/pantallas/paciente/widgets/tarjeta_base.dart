import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TarjetaBaseWidget extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget hijo;
  final String? subtitulo;

  const TarjetaBaseWidget({
    super.key,
    required this.titulo,
    required this.icono,
    required this.hijo,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Color(0xFF1C63BB).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icono, color: Color(0xFF1C63BB), size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                  if (subtitulo != null) Text(subtitulo!, style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          hijo,
        ],
      ),
      ),
    );
  }
}

class CampoTextoWidget extends StatelessWidget {
  final TextEditingController controlador;
  final String titulo;
  final String hint;
  final String sufijo;
  final IconData icono;
  final Color color;
  final String? ayuda;
  final bool readOnly;

  const CampoTextoWidget({
    super.key,
    required this.controlador,
    required this.titulo,
    required this.hint,
    required this.sufijo,
    required this.icono,
    required this.color,
    this.ayuda,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(
          key: ValueKey(titulo),
          controller: controlador,
          readOnly: readOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
            prefixIcon: Icon(icono, color: color, size: 20),
            suffixText: sufijo, suffixStyle: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            filled: true, fillColor: Color(0xFFF5F7FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
        ),
        if (ayuda != null) ...[
          const SizedBox(height: 4),
          Text(ayuda!, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
        ],
      ],
    );
  }
}


