import 'package:flutter/material.dart';
import '../../../modelos/paciente_clinico.dart';
import '../../pantalla_configuracion_ada.dart';
import '../controlador_calculadora.dart';
import 'tarjeta_base.dart';
import 'constantes_calculadora.dart';

class ActividadFisica {
  final String nombre;
  final IconData icono;
  final String descripcion;
  const ActividadFisica(this.nombre, this.icono, this.descripcion);
}

const actividadesDisponibles = [
  ActividadFisica('Sedentario', Icons.weekend_outlined, 'Sin actividad física hoy'),
  ActividadFisica('Ligero', Icons.directions_walk_outlined, 'Caminata corta, tareas del hogar'),
  ActividadFisica('Moderado', Icons.directions_bike_outlined, '30-60 min ejercicio moderado'),
  ActividadFisica('Intenso', Icons.fitness_center_outlined, 'Más de 60 min o ejercicio de alta intensidad'),
];

const momentosDisponibles = ['Desayuno', 'Almuerzo', 'Cena', 'Merienda', 'Otro'];

class AvisoMedicoWidget extends StatelessWidget {
  const AvisoMedicoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFFFA000), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information_outlined, color: Color(0xFFF57F17), size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              TextosCalculadora.avisoMedico,
              style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SeccionMomentoWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  const SeccionMomentoWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return TarjetaBaseWidget(
      titulo: TextosCalculadora.seccionMomento,
      icono: Icons.schedule_outlined,
      hijo: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: momentosDisponibles.map((m) {
            final sel = m == controlador.momentoComida;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  controlador.seleccionarMomento(m);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? Color(0xFF1C63BB) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Color(0xFF1C63BB) : Color(0xFFD2D2D2), width: 1.5),
                    boxShadow: sel ? [BoxShadow(color: Color(0xFF1C63BB).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                  ),
                  child: Text(m, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ReferenciaCarbsWidget extends StatelessWidget {
  const ReferenciaCarbsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final alimentos = [
      ('Tortilla de maíz', '12 g'), ('Arroz cocido ½ tz', '22 g'),
      ('Pan blanco 1 reba.', '13 g'), ('Manzana mediana', '25 g'),
      ('Refresco 355 ml', '38 g'), ('Frijoles ½ tz', '20 g'),
    ];

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text(TextosCalculadora.refCarbsTitulo, style: TextStyle(fontSize: 12, color: Color(0xFF1C63BB), fontWeight: FontWeight.bold)),
      leading: const Icon(Icons.info_outline, color: Color(0xFF1C63BB), size: 18),
      iconColor: Color(0xFF1C63BB),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Color(0xFFE8F0FB), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(TextosCalculadora.refCarbsSubtitulo, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: alimentos.map((a) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Color(0xFFD2D2D2), width: 1)),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 11),
                      children: [
                        TextSpan(text: '${a.$1}  ', style: TextStyle(color: Colors.black87)),
                        TextSpan(text: a.$2, style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SeccionDatosWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  const SeccionDatosWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return TarjetaBaseWidget(
      titulo: TextosCalculadora.seccionDatos,
      icono: Icons.restaurant_outlined,
      hijo: Column(
        children: [
          CampoTextoWidget(
            controlador: controlador.carbsCtrl,
            titulo: TextosCalculadora.campoCarbsTitulo,
            hint: TextosCalculadora.campoCarbsHint,
            sufijo: 'g',
            icono: Icons.grain_outlined,
            color: Color(0xFF2E7D32),
            ayuda: TextosCalculadora.campoCarbsAyuda,
          ),
          const SizedBox(height: 14),
          CampoTextoWidget(
            controlador: controlador.glucosaCtrl,
            titulo: TextosCalculadora.campoGlucosaTitulo,
            hint: TextosCalculadora.campoGlucosaHint,
            sufijo: 'mg/dL',
            icono: Icons.water_drop_outlined,
            color: Color(0xFF1C63BB),
            ayuda: TextosCalculadora.campoGlucosaAyuda,
          ),
          const SizedBox(height: 10),
          const ReferenciaCarbsWidget(),
        ],
      ),
    );
  }
}

class SeccionActividadWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  const SeccionActividadWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return TarjetaBaseWidget(
      titulo: TextosCalculadora.seccionActividad,
      icono: Icons.directions_run_outlined,
      subtitulo: TextosCalculadora.subtituloActividad,
      hijo: Column(
        children: actividadesDisponibles.map((act) {
          final sel = act.nombre == controlador.actividadSeleccionada;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                controlador.seleccionarActividad(act.nombre);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sel ? Color(0xFF1C63BB).withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? Color(0xFF1C63BB) : Color(0xFFE0E0E0), width: sel ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: sel ? Color(0xFF1C63BB) : Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: Icon(act.icono, color: sel ? Colors.white : Color(0xFF9E9E9E), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(act.nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sel ? Color(0xFF1C63BB) : Colors.black87)),
                          Text(act.descripcion, style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    if ((controlador.parametros?.ajustesActividad[act.nombre] ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: sel ? Color(0xFF1C63BB) : Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                        child: Text('-${((controlador.parametros?.ajustesActividad[act.nombre] ?? 0) * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : Color(0xFF2E7D32))),
                      ),
                    if (sel) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_circle, color: Color(0xFF1C63BB), size: 18)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SeccionAvanzadosWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  const SeccionAvanzadosWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE0E0E0))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Color(0xFF1C63BB).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.tune, color: Color(0xFF1C63BB), size: 18),
          ),
          title: const Text(TextosCalculadora.seccionAvanzados, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          subtitle: Text(controlador.estadoConfiguracion, style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          children: [
            TextButton.icon(onPressed: controlador.cargarDatosPaciente, icon: const Icon(Icons.refresh), label: const Text(TextosCalculadora.paramRecargar)),
            TextButton.icon(onPressed: controlador.pacienteId == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaConfiguracionAda(paciente: PacienteClinico(controlador.ambitoPaciente, controlador.pacienteId!)))), icon: const Icon(Icons.settings), label: const Text(TextosCalculadora.paramConfigurar)),
            const Divider(height: 1),
            const SizedBox(height: 14),
            CampoTextoWidget(
              controlador: controlador.relacionICCtrl,
              titulo: TextosCalculadora.paramICTitulo,
              hint: TextosCalculadora.paramSinConfig, sufijo: 'g/UI', icono: Icons.science_outlined, color: Color(0xFF6A1B9A),
              ayuda: TextosCalculadora.paramICAyuda,
              readOnly: true,
            ),
            const SizedBox(height: 14),
            CampoTextoWidget(
              controlador: controlador.fsiCtrl,
              titulo: TextosCalculadora.paramFSITitulo,
              hint: TextosCalculadora.paramSinConfig, sufijo: 'mg/dL/UI', icono: Icons.arrow_downward_outlined, color: Color(0xFFD32F2F),
              ayuda: TextosCalculadora.paramFSIAyuda,
              readOnly: true,
            ),
            const SizedBox(height: 14),
            CampoTextoWidget(
              controlador: controlador.objetivoCtrl,
              titulo: TextosCalculadora.paramObjetivoTitulo,
              hint: TextosCalculadora.paramSinConfig, sufijo: 'mg/dL', icono: Icons.flag_outlined, color: Color(0xFF2E7D32),
              ayuda: TextosCalculadora.paramObjetivoAyuda,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(10)),
              child: Text('💡 Estos valores fueron cargados de ${controlador.ambitoPaciente == AmbitoPaciente.personal ? "tu" : "su"} perfil. Solo el médico puede autorizar una nueva versión.', style: const TextStyle(fontSize: 11, color: Color(0xFF4A148C))),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertasClinicasWidget extends StatelessWidget {
  const AlertasClinicasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFD32F2F).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD32F2F).withValues(alpha: 0.6), width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emergency_outlined, color: Color(0xFFFF5252), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              TextosCalculadora.alertaHipoglucemia,
              style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class ReferenciaCalculoWidget extends StatelessWidget {
  const ReferenciaCalculoWidget({super.key});

  Widget _filaFormula(String titulo, String formula, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 6, right: 8), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12),
              children: [
                TextSpan(text: '$titulo: ', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                TextSpan(text: formula, style: TextStyle(color: Color(0xFF616161))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFFE0E0E0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.book_outlined, color: Color(0xFF1C63BB), size: 18),
            SizedBox(width: 8),
            Text(TextosCalculadora.metodoCalculoTitulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          ]),
          const SizedBox(height: 12),
          _filaFormula(TextosCalculadora.metodoBoloComida, 'Carbs (g) ÷ Relación I:C', Color(0xFF2E7D32)),
          const SizedBox(height: 6),
          _filaFormula(TextosCalculadora.metodoBoloCorreccion, '(Glucosa actual − Objetivo) ÷ FSI', Color(0xFF1C63BB)),
          const SizedBox(height: 10),
          const Text(TextosCalculadora.metodoAutorizacion, style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}

