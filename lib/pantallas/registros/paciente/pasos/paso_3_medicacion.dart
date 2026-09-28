import 'package:flutter/material.dart';
import '../controlador_registro_paciente.dart';
import '../ui_helpers.dart';

class Paso3Medicacion extends StatelessWidget {
  final ControladorRegistroPaciente controlador;

  const Paso3Medicacion({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase3Completa = controlador.frecuenciaMonitoreo != null &&
        (controlador.frecuenciaMonitoreo != 'Otro protocolo' || controlador.otroMonitoreoCtrl.text.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medicación Habitual', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 3 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          if (controlador.tipoDiabetes == 'Tipo 1') ...[
            const Text('Método de aplicación de Insulina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: crearChipSeleccion('Inyecciones', controlador.metodoInsulina == 'Inyecciones', () => controlador.actualizarMetodoInsulina('Inyecciones'))),
                const SizedBox(width: 15),
                Expanded(child: crearChipSeleccion('Bomba', controlador.metodoInsulina == 'Bomba', () => controlador.actualizarMetodoInsulina('Bomba'))),
              ],
            ),
            const SizedBox(height: 20),

            if (controlador.metodoInsulina == 'Inyecciones') ...[
              const Text('Tipo de Insulina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: crearChipSeleccion('Basal', controlador.tipoInsulinaInyeccion == 'Basal', () => controlador.actualizarTipoInsulinaInyeccion('Basal'))),
                  const SizedBox(width: 10),
                  Expanded(child: crearChipSeleccion('Bolo', controlador.tipoInsulinaInyeccion == 'Bolo', () => controlador.actualizarTipoInsulinaInyeccion('Bolo'))),
                  const SizedBox(width: 10),
                  Expanded(child: crearChipSeleccion('Ambas', controlador.tipoInsulinaInyeccion == 'Ambas', () => controlador.actualizarTipoInsulinaInyeccion('Ambas'))),
                ],
              ),
              const SizedBox(height: 20),

              if (controlador.tipoInsulinaInyeccion == 'Basal' || controlador.tipoInsulinaInyeccion == 'Ambas') ...[
                crearTarjetaGlass(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insulina Basal (Larga duración)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text('Mantiene tu glucosa estable en ayunas.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 15),
                      crearCampoTexto(titulo: 'Marca (Ej. Lantus, Tresiba)', hint: 'Escribe la marca', controlador: controlador.insulinaBasalMarcaCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                      const SizedBox(height: 15),
                      crearCampoTexto(titulo: 'Dosis Fija Diaria (Unidades)', hint: 'Ej. 20', controlador: controlador.insulinaBasalDosisCtrl, esNumero: true, onChanged: controlador.refrescarUI),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (controlador.tipoInsulinaInyeccion == 'Bolo' || controlador.tipoInsulinaInyeccion == 'Ambas') ...[
                crearTarjetaGlass(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insulina de Bolo (Acción rápida)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text('Para cubrir comidas o corregir niveles altos.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 15),
                      crearCampoTexto(titulo: 'Marca (Ej. Humalog, Novolog)', hint: 'Escribe la marca', controlador: controlador.insulinaRapidaMarcaCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                      const SizedBox(height: 15),
                      crearCampoTexto(titulo: 'Patrón de uso', hint: 'Ej. 5 U por comida...', controlador: controlador.insulinaRapidaPatronCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                    ],
                  ),
                ),
              ],
            ] else if (controlador.metodoInsulina == 'Bomba') ...[
              crearCampoTexto(titulo: 'Unidades Base', hint: 'Ej. 0.5 U/hr', controlador: controlador.bombaUnidadesCtrl, esNumero: false, onChanged: controlador.refrescarUI),
              const SizedBox(height: 20),
              crearCampoTexto(titulo: 'Frecuencia / Configuración', hint: 'Ej. Liberación continua...', controlador: controlador.bombaFrecuenciaCtrl, esNumero: false, onChanged: controlador.refrescarUI),
            ],
            const SizedBox(height: 30),
          ] else ...[
            const Text('Medicamento Principal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Metformina', controlador: controlador.medOralNombreCtrl, esNumero: false, onChanged: controlador.refrescarUI),
            const SizedBox(height: 20),
            crearCampoTexto(titulo: 'Dosis y Frecuencia', hint: 'Ej. 850mg cada 12 hrs', controlador: controlador.medOralDosisCtrl, esNumero: false, onChanged: controlador.refrescarUI),
            const SizedBox(height: 30),
          ],

          crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Otros Medicamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('Para presión, colesterol, suplementos, etc.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),

                  if (controlador.otrosMedicamentos.isNotEmpty) ...[
                    ...controlador.otrosMedicamentos.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> med = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                              child: const Icon(Icons.medication, color: Color(0xFF1C63BB), size: 20),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${med['nombre']} ${med['gramaje']}mg', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 3),
                                    Text('${med['proposito']} • ${med['frecuencia']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                  ],
                                )
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF008CCF)),
                              onPressed: () => controlador.editarMedicamento(idx),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                              onPressed: () => controlador.eliminarMedicamento(idx),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: controlador.mostrarFormularioOtroMed
                        ? Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Detalles del Medicamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(flex: 2, child: crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Losartán', controlador: controlador.otroMedNombreCtrl, esNumero: false, onChanged: controlador.refrescarUI)),
                              const SizedBox(width: 15),
                              Expanded(flex: 1, child: crearCampoTexto(titulo: 'Gramaje', hint: 'Ej. 50', controlador: controlador.otroMedGramajeCtrl, esNumero: true, onChanged: controlador.refrescarUI)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          crearCampoTexto(titulo: '¿Para qué es?', hint: 'Ej. Presión', controlador: controlador.otroMedPropositoCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                          const SizedBox(height: 15),
                          crearCampoTexto(titulo: 'Frecuencia', hint: 'Ej. 1 al día', controlador: controlador.otroMedFrecuenciaCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: controlador.limpiarYOCultarFormulario,
                                child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => controlador.guardarMedicamento(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D1FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(controlador.indiceEditando != null ? 'Actualizar' : 'Guardar', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                        : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: controlador.iniciarAnadirMedicamento,
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00D1FF)),
                        label: const Text('Añadir medicamento', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              )
          ),
          const SizedBox(height: 30),

          const Text('Protocolo de Monitoreo de Glucosa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          const Text('¿Cada cuánto te indicó el médico medir tu azúcar?', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 10),
          crearDropdown(
              valorActual: controlador.frecuenciaMonitoreo,
              hint: 'Selecciona una frecuencia',
              opciones: controlador.opcionesMonitoreo,
              onChange: controlador.actualizarFrecuenciaMonitoreo
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: controlador.frecuenciaMonitoreo == 'Otro protocolo'
                ? Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: crearCampoTexto(
                  titulo: 'Especifica tu protocolo',
                  hint: 'Ej. Cada 4 horas / Madrugada',
                  controlador: controlador.otroMonitoreoCtrl,
                  esNumero: false,
                  onChanged: controlador.refrescarUI
              ),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase3Completa ? controlador.siguientePaso : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008CCF),
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
