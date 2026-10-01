import 'package:flutter/material.dart';
import '../controlador_calculadora.dart';
import 'formulario_calculadora.dart'; // Para actividadesDisponibles
import 'constantes_calculadora.dart';

class FilaDesgloseWidget extends StatelessWidget {
  final IconData icono;
  final String label;
  final String formula;
  final String valor;
  final Color colorValor;
  final bool negrita;
  final bool grande;

  const FilaDesgloseWidget({
    super.key,
    required this.icono,
    required this.label,
    required this.formula,
    required this.valor,
    required this.colorValor,
    this.negrita = false,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: grande ? 12 : 11, color: Colors.white, fontWeight: negrita ? FontWeight.bold : FontWeight.normal)),
              if (formula.isNotEmpty) Text(formula, style: TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ),
        Text(valor, style: TextStyle(fontSize: grande ? 16 : 13, fontWeight: negrita ? FontWeight.bold : FontWeight.w500, color: colorValor)),
      ],
    );
  }
}

class ChipEstadoGlucosaWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  const ChipEstadoGlucosaWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    Color c; IconData ic;
    switch (controlador.estadoGlucosa) {
      case 'Hipoglucemia': c = Color(0xFFD32F2F); ic = Icons.warning_rounded; break;
      case 'Bajo': c = Color(0xFFE65100); ic = Icons.arrow_downward; break;
      case 'Normal': c = Color(0xFF2E7D32); ic = Icons.check_circle; break;
      case 'Elevado': c = Color(0xFFE65100); ic = Icons.arrow_upward; break;
      default: c = Color(0xFFD32F2F); ic = Icons.warning_rounded;
    }
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withValues(alpha: 0.5), width: 1)),
      child: Row(
        children: [
          Icon(ic, color: c, size: 18), const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Glucosa ${controlador.estadoGlucosa}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c)),
                Text(
                  controlador.estadoGlucosa == 'Hipoglucemia' ? TextosCalculadora.glucosaMsgHipo
                      : controlador.estadoGlucosa == 'Hiperglucemia' ? TextosCalculadora.glucosaMsgHiper
                      : TextosCalculadora.glucosaMsgNormal,
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SeccionResultadoWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  const SeccionResultadoWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    final act = actividadesDisponibles.firstWhere((a) => a.nombre == controlador.actividadSeleccionada);
    final tieneCorreccion = controlador.dosisCorreccion.abs() > 0.01;
    final tieneAjuste     = controlador.ajusteActividad > 0.01;

    Color colorDosis = Color(0xFF1C63BB);
    if (controlador.dosisAjustada <= 0) colorDosis = Color(0xFF2E7D32);
    if (controlador.dosisAjustada > 15)  colorDosis = Color(0xFFD32F2F);

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1C63BB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Color(0xFF1C63BB).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF00D1FF), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TextosCalculadora.resDosisCalculada, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(TextosCalculadora.resInsulinaRapida, style: TextStyle(fontSize: 11, color: Color(0xFF00D1FF))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  '${controlador.dosisAjustada.toStringAsFixed(1)} UI',
                  style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: colorDosis, height: 1),
                ),
                const Text(TextosCalculadora.resUnidadesInsulina, style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                  child: const Text(TextosCalculadora.alertaDescargo, style: TextStyle(fontSize: 11, color: Color(0xFF1565C0)), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(TextosCalculadora.resDesgloseCalculo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00D1FF), letterSpacing: 0.5)),
                const SizedBox(height: 10),
                FilaDesgloseWidget(
                  icono: Icons.restaurant_outlined, label: TextosCalculadora.metodoBoloComida,
                  formula: '${controlador.carbsCtrl.text.isNotEmpty ? controlador.carbsCtrl.text : '0'} g ÷ ${controlador.relacionICCtrl.text} g/UI',
                  valor: '+${controlador.dosisComida.toStringAsFixed(1)} UI', colorValor: Colors.white,
                ),
                if (tieneCorreccion) ...[
                  const SizedBox(height: 6),
                  FilaDesgloseWidget(
                    icono: Icons.tune,
                    label: controlador.dosisCorreccion >= 0 ? TextosCalculadora.resCorreccionAlta : TextosCalculadora.resCorreccionBaja,
                    formula: '(${controlador.glucosaCtrl.text} − ${controlador.objetivoCtrl.text}) ÷ ${controlador.fsiCtrl.text}',
                    valor: controlador.dosisCorreccion >= 0 ? '+${controlador.dosisCorreccion.toStringAsFixed(1)} UI' : '${controlador.dosisCorreccion.toStringAsFixed(1)} UI',
                    colorValor: controlador.dosisCorreccion >= 0 ? Color(0xFFFF8A65) : Color(0xFF81C784),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24)),
                  FilaDesgloseWidget(
                    icono: Icons.functions, label: TextosCalculadora.resSubtotal, formula: '',
                    valor: '${controlador.dosisTotal.toStringAsFixed(1)} UI', colorValor: Colors.white, negrita: true,
                  ),
                ],
                if (tieneAjuste) ...[
                  const SizedBox(height: 6),
                  FilaDesgloseWidget(
                    icono: act.icono, label: '${TextosCalculadora.resAjusteActividad} (${act.nombre})',
                    formula: '-${((controlador.parametros?.ajustesActividad[act.nombre] ?? 0) * 100).toInt()}% por ejercicio',
                    valor: '-${controlador.ajusteActividad.toStringAsFixed(1)} UI', colorValor: Color(0xFF80CBC4),
                  ),
                ],
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white38)),
                FilaDesgloseWidget(
                  icono: Icons.check_circle_outline, label: TextosCalculadora.resDosisTotal, formula: '',
                  valor: '${controlador.dosisAjustada.toStringAsFixed(1)} UI', colorValor: Color(0xFF00D1FF), negrita: true, grande: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (controlador.estadoGlucosa.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: ChipEstadoGlucosaWidget(controlador: controlador)),
        ],
      ),
    );
  }
}
