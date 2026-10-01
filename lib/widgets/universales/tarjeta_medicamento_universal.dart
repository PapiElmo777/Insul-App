import 'package:flutter/material.dart';

class TarjetaMedicamentoUniversal extends StatelessWidget {
  final Map<String, dynamic> medicamento;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TarjetaMedicamentoUniversal({
    super.key,
    required this.medicamento,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
              child: const Icon(Icons.medication, color: Color(0xFF1C63BB), size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${medicamento['nombre']} - ${medicamento['gramaje']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Frecuencia: ${medicamento['frecuencia']}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (medicamento['proposito'] != null && medicamento['proposito'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Nota: ${medicamento['proposito']}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    )
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF0C80EB), size: 20),
                    onPressed: onEdit,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 20),
                    onPressed: onDelete,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
