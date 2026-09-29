import 'package:flutter/material.dart';

class TarjetasTirPromedio extends StatelessWidget {
  final int porcentajeTir;
  final int promedio;
  final VoidCallback? onVerTir;
  final bool tieneRegistros;

  const TarjetasTirPromedio({
    super.key,
    required this.porcentajeTir,
    required this.promedio,
    this.onVerTir,
    required this.tieneRegistros,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFD2D2D2), width: 2), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Text('Tiempo en nivel normal (TIR)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F)), textAlign: TextAlign.center),
                const SizedBox(height: 2),
                Text(
                  !tieneRegistros ? '--%' : '$porcentajeTir%',
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 38, height: 1.2, color: Color(0xFF01689C)),
                ),
                GestureDetector(
                  onTap: !tieneRegistros ? null : onVerTir,
                  child: Text(
                    'Ver mas',
                    style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: !tieneRegistros ? Colors.transparent : const Color(0xFF888888), decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFD2D2D2), width: 2), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Text('Promedio\n', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F)), textAlign: TextAlign.center),
                const SizedBox(height: 2),
                Text(
                  !tieneRegistros ? '--' : promedio.toString(),
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 38, height: 1.2, color: Color(0xFF01689C)),
                ),
                const Text('Histórico total', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
