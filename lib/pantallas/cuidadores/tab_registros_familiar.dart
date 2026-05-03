import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../database/database_helper.dart';

class TabRegistrosFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const TabRegistrosFamiliar({super.key, required this.paciente});

  @override
  State<TabRegistrosFamiliar> createState() => _TabRegistrosFamiliarState();
}

class _TabRegistrosFamiliarState extends State<TabRegistrosFamiliar> {
  bool _cargando = true;
  List<Map<String, dynamic>> _registros = [];
  String _filtroDias = 'Todos';
  int? _indiceSeleccionadoGrafica;

  late int limiteHipo;
  late int limiteHiper;
  late int rangoMin;
  late int rangoMax;

  @override
  void initState() {
    super.initState();
    _inicializarLimites();
    _cargarRegistros();
  }

  void _inicializarLimites() {
    limiteHipo = (widget.paciente['limite_hipo'] as num?)?.toInt() ?? 70;
    limiteHiper = (widget.paciente['limite_hiper'] as num?)?.toInt() ?? 180;
    rangoMin = (widget.paciente['rango_min'] as num?)?.toInt() ?? 80;
    rangoMax = (widget.paciente['rango_max'] as num?)?.toInt() ?? 130;
  }

  Future<void> _cargarRegistros() async {
    final db = DatabaseHelper();
    final data = await db.obtenerRegistrosGlucosaCuidador(widget.paciente['id']);

    final registrosParseados = data.map((r) {
      DateTime fecha;
      try {
        fecha = DateTime.parse(r['fecha'].toString());
      } catch (e) {
        fecha = DateTime.now();
      }
      return {
        ...r,
        'fecha': fecha,
      };
    }).toList();

    if (mounted) {
      setState(() {
        _registros = registrosParseados;
        _cargando = false;
      });
    }
  }

  String _obtenerEstadoGlucosa(int valor) {
    if (valor < limiteHipo) return 'Hipoglucemia';
    if (valor >= limiteHipo && valor < rangoMin) return 'Bajo';
    if (valor >= rangoMin && valor <= rangoMax) return 'Normal';
    if (valor > rangoMax && valor <= limiteHiper) return 'Elevado';
    return 'Hiperglucemia';
  }

  Color _obtenerColorEstado(String estado) {
    if (estado == 'Hipoglucemia') return const Color(0xFFD32F2F);
    if (estado == 'Bajo') return const Color(0xFFE65100);
    if (estado == 'Normal') return const Color(0xFF2E7D32);
    if (estado == 'Elevado') return const Color(0xFFE65100);
    return const Color(0xFFD32F2F);
  }

  List<Map<String, dynamic>> _obtenerRegistrosFiltrados() {
    final registrosValidos = _registros.where((r) => (r['valor'] as num) > 0).toList();
    if (_filtroDias == 'Todos') return registrosValidos;

    int dias = int.parse(_filtroDias);
    DateTime limite = DateTime.now().subtract(Duration(days: dias));

    return registrosValidos.where((r) {
      DateTime fechaRegistro = r['fecha'] is DateTime ? r['fecha'] : DateTime.parse(r['fecha'].toString());
      return fechaRegistro.isAfter(limite);
    }).toList();
  }

  void _mostrarDetallesPunto(Map<String, dynamic> registro) {
    int valorG = (registro['valor'] as num).toInt();
    String estado = _obtenerEstadoGlucosa(valorG);
    Color colorEstado = _obtenerColorEstado(estado);
    DateTime fechaObj = registro['fecha'] is DateTime ? registro['fecha'] : DateTime.parse(registro['fecha'].toString());
    String fecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(fechaObj);
    String hora = DateFormat("HH:mm a", 'es_ES').format(fechaObj);
    String notas = registro['notas']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                  Text('$valorG', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 48, color: colorEstado, height: 1.0)),
                  const SizedBox(width: 5),
                  const Text('mg/dL', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF1C63BB), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(fecha[0].toUpperCase() + fecha.substring(1), style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF1C63BB), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(hora, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              if (notas.isNotEmpty) ...[
                const Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, color: Color(0xFF1C63BB), size: 20),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notas del paciente', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(notas, style: const TextStyle(fontSize: 14, color: Colors.black87, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              if (estado == 'Hipoglucemia' || estado == 'Hiperglucemia') ...[
                const SizedBox(height: 20),
                _construirMedidaCorrectivaADA(estado),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() { _indiceSeleccionadoGrafica = null; });
    });
  }

  Widget _construirMedidaCorrectivaADA(String estado) {
    if (estado != 'Hipoglucemia' && estado != 'Hiperglucemia') return const SizedBox.shrink();

    Color color = estado == 'Hipoglucemia' ? const Color(0xFFD32F2F) : const Color(0xFFE65100);
    String titulo = estado == 'Hipoglucemia' ? '⚠️ Medida Correctiva (ADA): Hipoglucemia' : '⚠️ Medida Correctiva (ADA): Hiperglucemia';
    String texto = estado == 'Hipoglucemia'
        ? 'Aplica la regla 15-15:\n\n1. Dale 15g de carbohidratos de acción rápida (ej. ½ vaso de jugo, 1 cda. de miel).\n2. Espera 15 min y vuelve a medir su glucosa.\n3. Si sigue menor a 70 mg/dL, repite.\n4. Al normalizarse, dale un snack o comida.'
        : 'Sigue estas recomendaciones:\n\n1. Dale abundante agua.\n2. Aplica su dosis de corrección de insulina según lo indicado por el médico.\n3. Si la glucosa es mayor a 240 mg/dL, verifica si hay cetonas en orina.\n4. Consulte a su médico.';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 12),
          const Text('Fuente: American Diabetes Association (ADA)', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  void _mostrarDialogoProtocoloADA(String estado) {
    String titulo = estado == 'Hipoglucemia' ? '⚠️ Medida Correctiva (ADA): Hipoglucemia' : '⚠️ Medida Correctiva (ADA): Hiperglucemia';
    String texto = estado == 'Hipoglucemia'
        ? 'Aplica la regla 15-15:\n\n1. Dale 15g de carbohidratos de acción rápida (ej. ½ vaso de jugo, 1 cda. de miel).\n2. Espera 15 min y vuelve a medir su glucosa.\n3. Si sigue menor a 70 mg/dL, repite.\n4. Al normalizarse, dale un snack o comida.'
        : 'Sigue estas recomendaciones:\n\n1. Dale abundante agua.\n2. Aplica su dosis de corrección de insulina según lo indicado por el médico.\n3. Si la glucosa es mayor a 240 mg/dL, verifica si hay cetonas en orina.\n4. Consulte a su médico.';

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(titulo, style: TextStyle(color: estado == 'Hipoglucemia' ? const Color(0xFFD32F2F) : const Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 16)),
            content: Text(texto, style: const TextStyle(fontSize: 14, height: 1.4)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido', style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
    );
  }

  void _mostrarFormularioNuevaMedida() {
    final TextEditingController valorCtrl = TextEditingController();
    final TextEditingController notasCtrl = TextEditingController();
    String momentoSeleccionado = 'Antes de comer';
    String? errorTexto;

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

                        const Align(alignment: Alignment.centerLeft, child: Text('Nivel de Glucosa (mg/dL) *', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: valorCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'ej. 120',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: (v) {
                            if (errorTexto != null) setStateSheet(() => errorTexto = null);
                          },
                        ),
                        const SizedBox(height: 15),

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

                        const Align(alignment: Alignment.centerLeft, child: Text('Notas: (opcional)', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: notasCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ej. Comió pastel, se siente cansado...',
                            hintStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 25),
                        if (errorTexto != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD32F2F))),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text(errorTexto!, style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (valorCtrl.text.isNotEmpty) {
                                int valor = int.tryParse(valorCtrl.text) ?? 0;

                                if (valor < 20 || valor > 600) {
                                  setStateSheet(() => errorTexto = 'Ingresa un valor realista (20 - 600 mg/dL)');
                                  return;
                                }

                                if (valor > 0) {
                                  String notaAutomatica = '';
                                  List<Map<String, dynamic>> registrosLecturas = _registros.where((r) => (r['valor'] as num) > 0).toList();

                                  if (registrosLecturas.isNotEmpty) {
                                    int ultimaGlucosa = (registrosLecturas.first['valor'] as num).toInt();
                                    String estadoAnterior = _obtenerEstadoGlucosa(ultimaGlucosa);

                                    if (estadoAnterior == 'Hipoglucemia' || estadoAnterior == 'Hiperglucemia') {
                                      String nuevoEstado = _obtenerEstadoGlucosa(valor);
                                      if (nuevoEstado == 'Hipoglucemia' || nuevoEstado == 'Hiperglucemia') {
                                        notaAutomatica = "Se realizó el protocolo y no se logró estabilizar la glucosa.";
                                      } else {
                                        notaAutomatica = "Se realizó el protocolo y se estabilizó la glucosa.";
                                      }
                                    }
                                  }

                                  String notaFinal = notasCtrl.text;
                                  if (notaAutomatica.isNotEmpty) {
                                    notaFinal = notaFinal.isEmpty ? notaAutomatica : "$notaFinal - $notaAutomatica";
                                  }

                                  final db = DatabaseHelper();
                                  await db.insertarRegistroGlucosaCuidador({
                                    'paciente_cuidador_id': widget.paciente['id'],
                                    'valor': valor,
                                    'momento': momentoSeleccionado,
                                    'notas': notaFinal,
                                    'fecha': DateTime.now().toIso8601String(),
                                  });

                                  if (mounted) Navigator.pop(context);
                                  await _cargarRegistros();

                                  String estadoNuevo = _obtenerEstadoGlucosa(valor);
                                  if (estadoNuevo == 'Hipoglucemia' || estadoNuevo == 'Hiperglucemia') {
                                    _mostrarDialogoProtocoloADA(estadoNuevo);
                                  }
                                }
                              } else {
                                setStateSheet(() => errorTexto = 'El nivel de glucosa no puede estar vacío');
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

  Widget _construirHeaderEspecializado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 15, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF1C63BB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Para ${widget.paciente['nombre']}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
      );
    }

    List<Map<String, dynamic>> registrosGrafica = _obtenerRegistrosFiltrados();
    List<Map<String, dynamic>> registrosLecturas = _registros.where((r) => (r['valor'] as num) > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _construirHeaderEspecializado(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _mostrarFormularioNuevaMedida,
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 22),
                      label: const Text('Añadir Nueva Lectura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C80EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        shadowColor: const Color(0xFF0C80EB).withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (registrosLecturas.isNotEmpty &&
                      DateTime.now().difference(registrosLecturas.first['fecha']).inHours < 6 &&
                      (_obtenerEstadoGlucosa((registrosLecturas.first['valor'] as num).toInt()) == 'Hipoglucemia' ||
                          _obtenerEstadoGlucosa((registrosLecturas.first['valor'] as num).toInt()) == 'Hiperglucemia')) ...[
                    _construirMedidaCorrectivaADA(_obtenerEstadoGlucosa((registrosLecturas.first['valor'] as num).toInt())),
                    const SizedBox(height: 25),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Análisis Gráfico',
                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1E1E1E)),
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
                                    double paddingX = 20.0;
                                    double startX = offsetX + paddingX;

                                    double customPaintWidth = (registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 80) - 40.0;
                                    double graphWidth = customPaintWidth - offsetX;
                                    double activeWidth = graphWidth - (paddingX * 2);

                                    double stepX = registrosGrafica.length > 1 ? activeWidth / (registrosGrafica.length - 1) : activeWidth / 2;
                                    double dx = details.localPosition.dx;

                                    int index = ((dx - startX) / stepX).round();

                                    if (index >= 0 && index < registrosGrafica.length) {
                                      double pointX = registrosGrafica.length == 1 ? startX + (activeWidth / 2) : startX + (index * stepX);
                                      if ((dx - pointX).abs() < 30.0) {
                                        setState(() { _indiceSeleccionadoGrafica = index; });
                                        int indiceReal = (registrosGrafica.length - 1) - index;
                                        _mostrarDetallesPunto(registrosGrafica[indiceReal]);
                                      }
                                    }
                                  },
                                  child: CustomPaint(
                                    painter: _GraficaFamiliarPainter(
                                      historial: registrosGrafica.reversed.toList(),
                                      limiteHipo: limiteHipo,
                                      limiteHiper: limiteHiper,
                                      rangoMin: rangoMin,
                                      rangoMax: rangoMax,
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
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            'Últimas Lecturas',
                            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1E1E1E)),
                          ),
                        ),
                        if (registrosLecturas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(child: Text('No hay lecturas registradas.', style: TextStyle(color: Colors.grey))),
                          )
                        else
                          ...registrosLecturas.take(10).map((registro) => _crearTarjetaRegistro(registro)).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearTarjetaRegistro(Map<String, dynamic> registro) {
    int val = (registro['valor'] as num).toInt();
    DateTime fecha = registro['fecha'] is DateTime ? registro['fecha'] : DateTime.parse(registro['fecha'].toString());
    String momento = registro['momento']?.toString() ?? 'No especificado';
    String notas = registro['notas']?.toString() ?? '';
    String estado = _obtenerEstadoGlucosa(val);
    Color colorFondo, colorBorde, colorTexto, colorIcono;

    if (estado == 'Hipoglucemia' || estado == 'Hiperglucemia') {
      colorFondo = const Color(0xFFFFEBEE); colorBorde = const Color(0xFFD32F2F); colorTexto = const Color(0xFFD32F2F); colorIcono = const Color(0xFFFFCDD2);
    } else if (estado == 'Bajo' || estado == 'Elevado') {
      colorFondo = const Color(0xFFFFF3E0); colorBorde = const Color(0xFFE65100); colorTexto = const Color(0xFFE65100); colorIcono = const Color(0xFFFFE0B2);
    } else { // Normal (Verde)
      colorFondo = const Color(0xFFE8F5E9); colorBorde = const Color(0xFF2E7D32); colorTexto = const Color(0xFF2E7D32); colorIcono = const Color(0xFFC8E6C9);
    }

    return GestureDetector(
      onTap: () => _mostrarDetallesPunto(registro),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colorFondo, border: Border.all(color: colorBorde, width: 2), borderRadius: BorderRadius.circular(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45, height: 45,
              decoration: BoxDecoration(color: colorIcono, border: Border.all(color: colorFondo, width: 2), shape: BoxShape.circle),
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
                        crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(val.toString(), style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 28, color: colorTexto, height: 1.0)),
                          const SizedBox(width: 4),
                          const Text('mg/dL', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xFF848282))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: colorIcono, border: Border.all(color: colorTexto, width: 1), borderRadius: BorderRadius.circular(10)),
                        child: Text(estado, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 10, color: colorTexto)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(DateFormat("d 'de' MMMM yyyy · HH:mm", 'es_ES').format(fecha), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                  Text(momento, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87)),
                  if (notas.isNotEmpty)
                    Text('"$notas"', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF626060), fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficaFamiliarPainter extends CustomPainter {
  final List<Map<String, dynamic>> historial;
  final int limiteHipo, limiteHiper, rangoMin, rangoMax;
  final int? indiceSeleccionado;

  _GraficaFamiliarPainter({
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
      if ((item['valor'] as num) > maxY) maxY = (item['valor'] as num).toDouble() + 30;
      if ((item['valor'] as num) < minY) minY = (item['valor'] as num).toDouble() - 10;
    }

    double graphHeight = size.height - 40;
    double offsetX = 40.0;
    double paddingX = 20.0;
    double startX = offsetX + paddingX;

    double graphWidth = size.width - offsetX;
    double activeWidth = graphWidth - (paddingX * 2);

    double valToY(double val) {
      return graphHeight - (((val - minY) / (maxY - minY)) * graphHeight) + 10;
    }

    Paint bgPaint = Paint();
    bgPaint.color = const Color(0xFFD32F2F).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(limiteHipo.toDouble()), size.width, graphHeight + 10), bgPaint);
    bgPaint.color = const Color(0xFFE65100).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rangoMin.toDouble()), size.width, valToY(limiteHipo.toDouble())), bgPaint);
    bgPaint.color = const Color(0xFF2E7D32).withOpacity(0.15);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rangoMax.toDouble()), size.width, valToY(rangoMin.toDouble())), bgPaint);
    bgPaint.color = const Color(0xFFE65100).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(limiteHiper.toDouble()), size.width, valToY(rangoMax.toDouble())), bgPaint);
    bgPaint.color = const Color(0xFFD32F2F).withOpacity(0.1);
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
    double stepX = historial.length > 1 ? activeWidth / (historial.length - 1) : activeWidth / 2;

    for (int i = 0; i < historial.length; i++) {
      double x = historial.length == 1 ? startX + (activeWidth / 2) : startX + (i * stepX);
      double y = valToY((historial[i]['valor'] as num).toDouble());
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
      int val = (historial[i]['valor'] as num).toInt();
      Color c;

      if (val < limiteHipo || val > limiteHiper) c = const Color(0xFFD32F2F);
      else if (val >= rangoMin && val <= rangoMax) c = const Color(0xFF2E7D32);
      else c = const Color(0xFFE65100);

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
        DateTime fechaObj = historial[i]['fecha'] is DateTime ? historial[i]['fecha'] : DateTime.parse(historial[i]['fecha'].toString());
        TextPainter tpFecha = TextPainter(
          text: TextSpan(
            text: DateFormat('dd/MM').format(fechaObj),
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
  bool shouldRepaint(covariant _GraficaFamiliarPainter oldDelegate) {
    return oldDelegate.indiceSeleccionado != indiceSeleccionado || oldDelegate.historial != historial;
  }
}