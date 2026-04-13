import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PantallaRegistrosPaciente extends StatefulWidget {
  final List<Map<String, dynamic>> registros;
  final int limiteHipo;
  final int limiteHiper;
  final int rangoMin;
  final int rangoMax;
  final Function(Map<String, dynamic>) onAgregarRegistro;

  const PantallaRegistrosPaciente({
    super.key,
    required this.registros,
    required this.limiteHipo,
    required this.limiteHiper,
    required this.rangoMin,
    required this.rangoMax,
    required this.onAgregarRegistro,
  });

  @override
  State<PantallaRegistrosPaciente> createState() => _PantallaRegistrosPacienteState();
}

class _PantallaRegistrosPacienteState extends State<PantallaRegistrosPaciente> {

  String _obtenerEstadoGlucosa(int valor) {
    if (valor < widget.limiteHipo) return 'Bajo';
    if (valor > widget.limiteHiper) return 'Alto';
    if (valor >= widget.rangoMin && valor <= widget.rangoMax) return 'Normal';
    return 'Alerta';
  }

  void _mostrarFormularioNuevaMedida() {
    final TextEditingController valorCtrl = TextEditingController();
    final TextEditingController notasCtrl = TextEditingController();
    String momentoSeleccionado = 'Antes de comer';
    DateTime fechaSeleccionada = DateTime.now();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateSheet) {
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 20, right: 20, top: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                        const SizedBox(height: 20),
                        const Text('Nueva Medición', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 22)),
                        const SizedBox(height: 25),

                        // Campo Nivel
                        const Align(alignment: Alignment.centerLeft, child: Text('Nivel de Glucosa (mg/dL) *', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: valorCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'ej. 120',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Periodo
                        const Align(alignment: Alignment.centerLeft, child: Text('Periodo:', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: momentoSeleccionado,
                              isExpanded: true,
                              items: ['Ayunas', 'Antes de comer', 'Después de comer', 'Antes de dormir', 'Madrugada', 'Otro']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setStateSheet(() => momentoSeleccionado = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Notas
                        const Align(alignment: Alignment.centerLeft, child: Text('Notas: (opcional)', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: notasCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ej. Me siento mareado, comí pastel...',
                            hintStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Boton Guardar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (valorCtrl.text.isNotEmpty) {
                                int valor = int.tryParse(valorCtrl.text) ?? 0;
                                if (valor > 0) {
                                  widget.onAgregarRegistro({
                                    'valor': valor,
                                    'momento': momentoSeleccionado,
                                    'fecha': fechaSeleccionada,
                                    'notas': notasCtrl.text,
                                  });
                                  Navigator.pop(context);
                                }
                              }
                            },
                            icon: const Icon(Icons.save_alt, color: Colors.white),
                            label: const Text('Guardar Nueva Lectura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C80EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 30.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C63BB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registro de Glucosa',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _mostrarFormularioNuevaMedida,
                icon: const Icon(Icons.add, size: 18, color: Color(0xFF1C63BB)),
                label: const Text(
                  'Nueva Lectura',
                  style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          'Historial de Lecturas',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      if (widget.registros.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              'Aún no hay lecturas registradas.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...widget.registros.map((registro) => _crearTarjetaRegistro(registro)).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1C63BB), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF1C63BB), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tus Valores de Referencia',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1C63BB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _filaReferencia('Hipogucemia', '< ${widget.limiteHipo} mg/dL', const Color(0xFFFF9800)),
                      const Divider(color: Colors.white, thickness: 1),
                      _filaReferencia('Bajo / Alerta', '${widget.limiteHipo} - ${widget.rangoMin - 1} mg/dL', Colors.orange.shade600),
                      const Divider(color: Colors.white, thickness: 1),
                      _filaReferencia('Normal / Meta', '${widget.rangoMin} - ${widget.rangoMax} mg/dL', const Color(0xFF4CAF50)),
                      const Divider(color: Colors.white, thickness: 1),
                      _filaReferencia('Elevado / Alerta', '${widget.rangoMax + 1} - ${widget.limiteHiper} mg/dL', const Color(0xFFFFC107)),
                      const Divider(color: Colors.white, thickness: 1),
                      _filaReferencia('Hiperglucemia', '> ${widget.limiteHiper} mg/dL', const Color(0xFFF44336)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filaReferencia(String etiqueta, String valor, Color colorPunto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: colorPunto, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2F2F2F))),
            ],
          ),
          Text(valor, style: TextStyle(fontWeight: FontWeight.bold, color: colorPunto)),
        ],
      ),
    );
  }

  Widget _crearTarjetaRegistro(Map<String, dynamic> registro) {
    int val = registro['valor'];
    DateTime fecha = registro['fecha'];
    String momento = registro['momento'];
    String notas = registro['notas'];

    String estado = _obtenerEstadoGlucosa(val);
    Color colorFondo, colorBorde, colorTexto, colorIcono;

    if (estado == 'Bajo') {
      colorFondo = const Color(0xFFFFEDC6);
      colorBorde = const Color(0xFFF09802);
      colorTexto = const Color(0xFFE08D01);
      colorIcono = const Color(0xFFFFE2A4);
    } else if (estado == 'Alto') {
      colorFondo = const Color(0xFFFFBCBC);
      colorBorde = const Color(0xFF810404);
      colorTexto = const Color(0xFF810404);
      colorIcono = const Color(0xFFFF7B7B);
    } else if (estado == 'Normal') {
      colorFondo = const Color(0xFFDBFED1);
      colorBorde = const Color(0xFF4FAB04);
      colorTexto = const Color(0xFF2B940B);
      colorIcono = const Color(0xFFC1FFB0);
    } else {
      colorFondo = Colors.yellow.shade100;
      colorBorde = Colors.orange.shade600;
      colorTexto = Colors.orange.shade800;
      colorIcono = Colors.yellow.shade200;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorFondo,
        border: Border.all(color: colorBorde, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: colorIcono,
              border: Border.all(color: colorFondo, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.water_drop_outlined, color: colorBorde, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          val.toString(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 28,
                            color: colorTexto,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'mg/dL',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF848282),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorIcono,
                        border: Border.all(color: colorTexto, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: colorTexto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.black87),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat("d 'de' MMMM yyyy · HH:mm", 'es_ES').format(fecha),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
                Text(
                  momento,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87),
                ),
                if (notas.isNotEmpty)
                  Text(
                    '"$notas"',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF626060), fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}