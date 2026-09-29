import 'package:flutter/material.dart';

Widget crearTarjetaGlass({required Widget hijo}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
    ),
    child: hijo,
  );
}

Widget crearOpcionPaciente({required String titulo, required IconData icono, required bool seleccionado, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: seleccionado ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: seleccionado ? const Color(0xFF00D1FF) : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          Icon(icono, color: seleccionado ? Colors.white : const Color(0xFF1C63BB), size: 28),
          const SizedBox(width: 15),
          Text(
              titulo,
              style: TextStyle(
                  color: seleccionado ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              )
          ),
        ],
      ),
    ),
  );
}

Widget crearChipSeleccion(String texto, bool seleccionado, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: seleccionado ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: seleccionado ? const Color(0xFF00D1FF) : const Color(0xFFD2D2D2), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
          texto,
          style: TextStyle(color: seleccionado ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
      ),
    ),
  );
}

Widget crearCampoTexto({
  required String titulo,
  required String hint,
  required TextEditingController controlador,
  required bool esNumero,
  bool activo = true,
  FocusNode? focusNode,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: activo ? Colors.white : Colors.grey)),
      const SizedBox(height: 5),
      TextField(
        controller: controlador,
        focusNode: focusNode,
        enabled: activo,
        keyboardType: esNumero ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Color(0xFF848282)),
          filled: true, fillColor: activo ? Colors.white : Colors.grey.shade300,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    ],
  );
}

Widget crearDropdown({required String? valorActual, required String hint, required List<String> opciones, required Function(String?) onChange}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        itemHeight: null,
        value: valorActual,
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        onChanged: onChange,
        items: opciones.map((String valor) => DropdownMenuItem<String>(
            value: valor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(valor, style: const TextStyle(color: Colors.black)),
            )
        )).toList(),
      ),
    ),
  );
}
