import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../controlador_dashboard_paciente.dart';
import '../../pantalla_inicio_paciente.dart';

class TabHistorial extends StatelessWidget {
  final ControladorDashboardPaciente controlador;

  const TabHistorial({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    double cv = 0.0;
    if (controlador.registrosGlucosa.isNotEmpty) {
      double prom = controlador.calcularPromedioGlucosa().toDouble();
      double sumaCuadrados = 0;
      for (var r in controlador.registrosGlucosa) {
        sumaCuadrados += math.pow((r['valor'] - prom), 2);
      }
      double desvStd = math.sqrt(
        sumaCuadrados / controlador.registrosGlucosa.length,
      );
      cv = (desvStd / prom) * 100;
    }

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF1C63BB),
            expandedHeight: 140.0,
            floating: true,
            snap: true,
            pinned: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Historial Clínico',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Análisis y exportación de Perfil Ambulatorio de Glucosa (AGP).',
                        style: TextStyle(
                          color: Color(0xFFE8E8E8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 60,
                    color: Color(0xFF1C63BB),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Informe AGP del Paciente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Genera un reporte clínico detallado para tu médico tratante con gráficas, promedios y variabilidad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (controlador.registrosGlucosa.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Necesitas registrar lecturas de glucosa primero.',
                              ),
                            ),
                          );
                          return;
                        }

                        String periodoSeleccionado = 'Todos';
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Seleccionar Período',
                                style: TextStyle(
                                  color: Color(0xFF1C63BB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        [
                                          '7 Días',
                                          '14 Días',
                                          '1 Mes',
                                          '3 Meses',
                                          'Todos',
                                        ].map((opcion) {
                                          return RadioListTile<String>(
                                            title: Text(opcion),
                                            value: opcion,
                                            groupValue: periodoSeleccionado,
                                            onChanged: (val) {
                                              setStateDialog(
                                                () =>
                                                    periodoSeleccionado = val!,
                                              );
                                            },
                                            activeColor: const Color(
                                              0xFF1C63BB,
                                            ),
                                          );
                                        }).toList(),
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0C80EB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Continuar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != true) return;

                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );

                        final nav = Navigator.of(context, rootNavigator: true);
                        try {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          final bytes = await controlador.generarPDFAGP(
                            context,
                            periodoSeleccionado,
                          );
                          nav.pop();

                          if (bytes != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VisorAGPPantalla(bytes: bytes),
                              ),
                            );
                          }
                        } catch (e) {
                          nav.pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Generar PDF para Médico',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008CCF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Resumen del Periodo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _mostrarDialogoVariabilidad(context),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF0C80EB),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Variabilidad (CV)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C63BB),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Color(0xFF1C63BB),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${cv.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: cv > 36
                                  ? const Color(0xFFE65100)
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                          const Text(
                            'Toca para saber más',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFD2D2D2)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Lecturas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${controlador.registrosGlucosa.length}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C63BB),
                          ),
                        ),
                        const Text(
                          'Registros totales',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            const Divider(thickness: 1, color: Color(0xFFD2D2D2)),
            const SizedBox(height: 20),

            const Text(
              'Historial de Archivos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            if (controlador.reportesGenerados.isEmpty)
              const Text(
                'Aún no has generado ningún informe para tu médico.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              )
            else
              ...List.generate(controlador.reportesGenerados.length, (index) {
                final reporte = controlador.reportesGenerados[index];
                final titulo = 'Historial (${reporte['periodo']})';

                return Card(
                  key: Key(reporte['id']),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFFD2D2D2)),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F4F8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Color(0xFF1C63BB),
                        ),
                      ),
                      title: Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        'Generado a las: ${DateFormat('HH:mm').format(reporte['fecha'])}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.visibility,
                        color: Color(0xFF0C80EB),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VisorAGPPantalla(bytes: reporte['bytes']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoVariabilidad(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.waves, size: 50, color: Color(0xFF1C63BB)),
                const SizedBox(height: 15),
                const Text(
                  'Variabilidad Glucémica (CV)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'El Coeficiente de Variación (CV) mide qué tanto "brincan" tus niveles de azúcar respecto a tu promedio diario.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFD2D2D2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Menor al 36% indica niveles estables (buen control).',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(
                            Icons.warning,
                            color: Color(0xFFE65100),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mayor al 36% significa picos altos y bajos frecuentes, lo que puede causar daño a largo plazo.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008CCF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
