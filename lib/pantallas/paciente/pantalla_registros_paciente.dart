import 'package:flutter/material.dart';
import 'package:intl/intl.dart'hide TextDirection;

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
  String _filtroDias = 'Todos';
  int? _indiceSeleccionadoGrafica;

  String _obtenerEstadoGlucosa(int valor) {
    if (valor < widget.limiteHipo) return 'Bajo';
    if (valor > widget.limiteHiper) return 'Alto';
    if (valor >= widget.rangoMin && valor <= widget.rangoMax) return 'Normal';
    return 'Alerta';
  }

  Color _obtenerColorEstado(String estado) {
    if (estado == 'Bajo') return const Color(0xFFFF9800);
    if (estado == 'Alto') return const Color(0xFFF44336);
    if (estado == 'Normal') return const Color(0xFF4CAF50);
    return Colors.orange.shade600; // Alerta
  }

  List<Map<String, dynamic>> _obtenerRegistrosFiltrados() {
    if (_filtroDias == 'Todos') return widget.registros;

    int dias = int.parse(_filtroDias);
    DateTime limite = DateTime.now().subtract(Duration(days: dias));

    return widget.registros.where((r) {
      DateTime fechaRegistro = r['fecha'];
      return fechaRegistro.isAfter(limite);
    }).toList();
  }

  void _mostrarDetallesPunto(Map<String, dynamic> registro) {
    String estado = _obtenerEstadoGlucosa(registro['valor']);
    Color colorEstado = _obtenerColorEstado(estado);
    String fecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(registro['fecha']);
    String hora = DateFormat("HH:mm a", 'es_ES').format(registro['fecha']);
    String notas = registro['notas'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detalle de Lectura', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: colorEstado),
                    ),
                    child: Text(estado, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${registro['valor']}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 48, color: colorEstado, height: 1.0)),
                  const SizedBox(width: 5),
                  const Text('mg/dL', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              _filaDetalle(Icons.calendar_today, 'Fecha', fecha[0].toUpperCase() + fecha.substring(1)),
              const Divider(height: 20),
              _filaDetalle(Icons.access_time, 'Hora', hora),
              const Divider(height: 20),
              _filaDetalle(Icons.restaurant_menu, 'Periodo', registro['momento']),
              const Divider(height: 20),
              _filaDetalle(
                  Icons.note_alt_outlined,
                  'Notas',
                  notas.isNotEmpty ? '"$notas"' : 'Sin notas registradas',
                  esNota: notas.isNotEmpty
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _indiceSeleccionadoGrafica = null;
      });
    });
  }

  Widget _filaDetalle(IconData icono, String titulo, String valor, {bool esNota = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: const Color(0xFF1C63BB), size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                  valor,
                  style: TextStyle(
                    fontSize: 15,
                    color: esNota ? Colors.black54 : Colors.black87,
                    fontWeight: esNota ? FontWeight.normal : FontWeight.w600,
                    fontStyle: esNota ? FontStyle.italic : FontStyle.normal,
                  )
              ),
            ],
          ),
        ),
      ],
    );
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
    List<Map<String, dynamic>> registrosGrafica = _obtenerRegistrosFiltrados();
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        ...widget.registros.take(10).map((registro) => _crearTarjetaRegistro(registro)).toList(),
                      if (widget.registros.length > 10)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('Mostrando los 10 registros más recientes...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Grafica
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Análisis Gráfico',
                            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1E1E1E)),
                          ),
                          Icon(Icons.show_chart, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['7', '14', '30', '90', 'Todos'].map((opcion) {
                            bool seleccionado = _filtroDias == opcion;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(opcion == 'Todos' ? opcion : '$opcion Días'),
                                selected: seleccionado,
                                selectedColor: const Color(0xFF1C63BB),
                                labelStyle: TextStyle(color: seleccionado ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                                onSelected: (bool selected) {
                                  setState(() {
                                    _filtroDias = opcion;
                                    _indiceSeleccionadoGrafica = null;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: registrosGrafica.isEmpty
                            ? const Center(child: Text('No hay datos en este periodo', style: TextStyle(color: Colors.grey)))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 5),
                              width: registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 80,
                              child: GestureDetector(
                                onTapUp: (details) {
                                  double offsetX = 40.0;
                                  double graphWidth = (registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 80) - offsetX;
                                  double stepX = registrosGrafica.length > 1 ? graphWidth / (registrosGrafica.length - 1) : graphWidth / 2;
                                  double dx = details.localPosition.dx;

                                  int index = ((dx - offsetX) / stepX).round();

                                  if (index >= 0 && index < registrosGrafica.length) {
                                    double pointX = registrosGrafica.length == 1 ? offsetX + (graphWidth / 2) : offsetX + (index * stepX);
                                    if ((dx - pointX).abs() < 25.0) {
                                      setState(() { _indiceSeleccionadoGrafica = index; });
                                      int indiceReal = (registrosGrafica.length - 1) - index;
                                      _mostrarDetallesPunto(registrosGrafica[indiceReal]);
                                    }
                                  }
                                },
                                child: CustomPaint(
                                  painter: _GraficaPacientePainter(
                                    historial: registrosGrafica.reversed.toList(),
                                    limiteHipo: widget.limiteHipo,
                                    limiteHiper: widget.limiteHiper,
                                    rangoMin: widget.rangoMin,
                                    rangoMax: widget.rangoMax,
                                    indiceSeleccionado: _indiceSeleccionadoGrafica,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                      _filaReferencia('Hipoglucemia', '< ${widget.limiteHipo} mg/dL', const Color(0xFFFF9800)),
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
    String notas = registro['notas'] ?? '';
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

class _GraficaPacientePainter extends CustomPainter {
  final List<Map<String, dynamic>> historial;
  final int limiteHipo, limiteHiper, rangoMin, rangoMax;
  final int? indiceSeleccionado;

  _GraficaPacientePainter({
    required this.historial,
    required this.limiteHipo,
    required this.limiteHiper,
    required this.rangoMin,
    required this.rangoMax,
    this.indiceSeleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historial.isEmpty) return;

    double maxY = limiteHiper.toDouble() + 50.0;
    double minY = limiteHipo.toDouble() - 20.0;
    if (minY < 0) minY = 0;

    for (var item in historial) {
      if (item['valor'] > maxY) maxY = item['valor'].toDouble() + 30;
      if (item['valor'] < minY) minY = item['valor'].toDouble() - 10;
    }

    double graphHeight = size.height - 40;
    double offsetX = 40.0;
    double graphWidth = size.width - offsetX;

    double valToY(double val) {
      return graphHeight - (((val - minY) / (maxY - minY)) * graphHeight) + 10;
    }

    Paint bgPaint = Paint();

    bgPaint.color = const Color(0xFFFF9800).withOpacity(0.1); // Hipo
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(limiteHipo.toDouble()), size.width, graphHeight + 10), bgPaint);

    bgPaint.color = Colors.orange.shade600.withOpacity(0.1); // Alerta
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rangoMin.toDouble()), size.width, valToY(limiteHipo.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFF4CAF50).withOpacity(0.15); // Normal
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rangoMax.toDouble()), size.width, valToY(rangoMin.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFFFFC107).withOpacity(0.1); // Elevado
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(limiteHiper.toDouble()), size.width, valToY(rangoMax.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFFF44336).withOpacity(0.1); // Hiper
    canvas.drawRect(Rect.fromLTRB(offsetX, 10, size.width, valToY(limiteHiper.toDouble())), bgPaint);

    Paint lineRef = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1;
    List<int> yLabels = [maxY.toInt(), limiteHiper, rangoMax, rangoMin, limiteHipo, minY.toInt()];
    yLabels = yLabels.toSet().toList()..sort((a, b) => b.compareTo(a));

    for (int yVal in yLabels) {
      double yPos = valToY(yVal.toDouble());
      canvas.drawLine(Offset(offsetX, yPos), Offset(size.width, yPos), lineRef);
      TextPainter tpY = TextPainter(
        text: TextSpan(text: '$yVal', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tpY.layout();
      tpY.paint(canvas, Offset(offsetX - tpY.width - 5, yPos - 6));
    }

    List<Offset> points = [];
    double stepX = historial.length > 1 ? graphWidth / (historial.length - 1) : graphWidth / 2;

    for (int i = 0; i < historial.length; i++) {
      double x = historial.length == 1 ? offsetX + (graphWidth / 2) : offsetX + (i * stepX);
      double y = valToY(historial[i]['valor'].toDouble());
      points.add(Offset(x, y));
    }

    Paint linePaint = Paint()
      ..color = const Color(0xFF1C63BB)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    Path path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        double controlPointX = (points[i - 1].dx + points[i].dx) / 2;
        path.cubicTo(controlPointX, points[i - 1].dy, controlPointX, points[i].dy, points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      int val = historial[i]['valor'];
      Color c;
      if (val < limiteHipo) c = const Color(0xFFFF9800);
      else if (val > limiteHiper) c = const Color(0xFFF44336);
      else if (val >= rangoMin && val <= rangoMax) c = const Color(0xFF4CAF50);
      else if (val < rangoMin) c = Colors.orange.shade600;
      else c = const Color(0xFFFFC107);

      if (indiceSeleccionado == i) {
        canvas.drawCircle(points[i], 14.0, Paint()..color = c.withOpacity(0.4)..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 8.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 6.0, Paint()..color = c..style = PaintingStyle.fill);
      } else {
        canvas.drawCircle(points[i], 6.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 4.0, Paint()..color = c..style = PaintingStyle.fill);
      }

      if (historial.length <= 14 || val < limiteHipo || val > limiteHiper || indiceSeleccionado == i) {
        TextPainter tpVal = TextPainter(
          text: TextSpan(text: '$val', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: indiceSeleccionado == i ? 13 : 11)),
          textDirection: TextDirection.ltr,
        );
        tpVal.layout();
        tpVal.paint(canvas, Offset(points[i].dx - tpVal.width / 2, points[i].dy - (indiceSeleccionado == i ? 24 : 20)));
      }

      if (i == 0 || i == points.length - 1 || historial.length <= 14) {
        TextPainter tpFecha = TextPainter(
          text: TextSpan(
            text: DateFormat('dd/MM').format(historial[i]['fecha']),
            style: const TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        );
        tpFecha.layout();
        tpFecha.paint(canvas, Offset(points[i].dx - tpFecha.width / 2, graphHeight + 10));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraficaPacientePainter oldDelegate) {
    return oldDelegate.indiceSeleccionado != indiceSeleccionado || oldDelegate.historial != historial;
  }
}