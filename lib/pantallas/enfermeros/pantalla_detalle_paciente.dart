import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../database/database_helper.dart';
import 'pantalla_calculadora_enfermero.dart';

class PantallaDetallePaciente extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final String nombreEnfermero;

  const PantallaDetallePaciente({
    super.key,
    required this.paciente,
    required this.nombreEnfermero,
  });

  @override
  State<PantallaDetallePaciente> createState() => _PantallaDetallePacienteState();
}

class _PantallaDetallePacienteState extends State<PantallaDetallePaciente> {
  final TextEditingController _glucosaCtrl = TextEditingController();
  final TextEditingController _observacionCtrl = TextEditingController();
  final TextEditingController _insulinaCtrl = TextEditingController();

  List<Map<String, dynamic>> _historialGlucosa = [];
  List<Map<String, dynamic>> _medicamentos = [];
  List<Map<String, dynamic>> _historialInsulina = [];
  List<String> _observacionesBD = [];
  bool _cargando = true;

  int? _indiceSeleccionadoGrafica;

  @override
  void initState() {
    super.initState();
    _cargarDatosPaciente();
  }

  Future<void> _cargarDatosPaciente() async {
    final db = DatabaseHelper();
    final pacienteId = widget.paciente['id'];

    final glucosa = await db.obtenerGlucosaEnfermero(pacienteId);
    final meds = await db.obtenerMedicamentosEnfermero(pacienteId);
    final insul = await db.obtenerInsulinaEnfermero(pacienteId);
    final obs = await db.obtenerObservacionesEnfermero(pacienteId);

    if (mounted) {
      setState(() {
        _historialGlucosa = glucosa.map((e) => {'valor': e['valor'], 'fecha': DateTime.parse(e['fecha'])}).toList();
        _medicamentos = List<Map<String, dynamic>>.from(meds);
        _historialInsulina = insul.map((e) => {'unidades': e['unidades'], 'fecha': DateTime.parse(e['fecha'])}).toList();

        _observacionesBD = obs.map((e) => e['nota'] as String).toList();
        if (_observacionesBD.isEmpty && widget.paciente['estadoGeneral'] != null && widget.paciente['estadoGeneral'].toString().isNotEmpty) {
          _observacionesBD.add('NOTA DE INGRESO:\n${widget.paciente['estadoGeneral']}');
        }

        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _observacionCtrl.dispose();
    _insulinaCtrl.dispose();
    super.dispose();
  }

  double _calcularPromedio() {
    if (_historialGlucosa.isEmpty) return 0;
    double suma = 0;
    for (var item in _historialGlucosa) {
      suma += item['valor'];
    }
    return suma / _historialGlucosa.length;
  }

  double _calcularTIR() {
    if (_historialGlucosa.isEmpty) return 0;
    int enRango = 0;
    int minG = widget.paciente['rangoMin'] ?? 80;
    int maxG = widget.paciente['rangoMax'] ?? 130;
    for (var item in _historialGlucosa) {
      int val = item['valor'];
      if (val >= minG && val <= maxG) enRango++;
    }
    return (enRango / _historialGlucosa.length) * 100;
  }

  String _obtenerEstadoGlucosa(int valor) {
    int hipo = widget.paciente['hipoLimit'] ?? 70;
    int hiper = widget.paciente['hiperLimit'] ?? 180;
    int rMin = widget.paciente['rangoMin'] ?? 80;
    int rMax = widget.paciente['rangoMax'] ?? 130;

    if (valor < hipo) return 'Hipoglucemia';
    if (valor >= hipo && valor < rMin) return 'Bajo';
    if (valor >= rMin && valor <= rMax) return 'Normal';
    if (valor > rMax && valor <= hiper) return 'Elevado';
    return 'Hiperglucemia';
  }

  Color _obtenerColorEstado(String estado) {
    if (estado == 'Hipoglucemia') return const Color(0xFFD32F2F);
    if (estado == 'Bajo') return const Color(0xFFE65100);
    if (estado == 'Normal') return const Color(0xFF2E7D32);
    if (estado == 'Elevado') return const Color(0xFFE65100);
    return const Color(0xFFD32F2F);
  }

  void _mostrarDetallesPunto(Map<String, dynamic> registro) {
    String estado = _obtenerEstadoGlucosa(registro['valor']);
    Color colorEstado = _obtenerColorEstado(estado);
    String fecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(registro['fecha']);
    String hora = DateFormat("HH:mm a", 'es_ES').format(registro['fecha']);

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

  void _mostrarDialogoAgregarGlucosa() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Registrar Toma de Glucosa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _glucosaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Ej. 110', suffixText: 'mg/dL', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (_glucosaCtrl.text.isNotEmpty) {
                  int nuevoValor = int.parse(_glucosaCtrl.text);
                  if (nuevoValor <= 0 || nuevoValor > 600) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, ingresa un valor de glucosa realista (1-600 mg/dL)')));
                    return;
                  }

                  final db = DatabaseHelper();
                  await db.insertarGlucosaEnfermero({
                    'paciente_id': widget.paciente['id'],
                    'valor': nuevoValor,
                    'fecha': DateTime.now().toIso8601String()
                  });

                  await _cargarDatosPaciente();

                  if (mounted) {
                    _glucosaCtrl.clear();
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAgregarInsulina() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Suministrar Insulina', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _insulinaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Unidades administradas', suffixText: 'UI', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (_insulinaCtrl.text.isNotEmpty) {
                  final db = DatabaseHelper();
                  await db.insertarInsulinaEnfermero({
                    'paciente_id': widget.paciente['id'],
                    'unidades': int.parse(_insulinaCtrl.text),
                    'fecha': DateTime.now().toIso8601String()
                  });

                  await _cargarDatosPaciente();

                  if (mounted) {
                    _insulinaCtrl.clear();
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Registrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoObservacion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Añadir Observación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _observacionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Escriba nota del turno...', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (_observacionCtrl.text.isNotEmpty) {
                  String hora = DateFormat('hh:mm a').format(DateTime.now());
                  final db = DatabaseHelper();
                  await db.insertarObservacionEnfermero({
                    'paciente_id': widget.paciente['id'],
                    'nota': "[$hora] Enf. ${widget.nombreEnfermero}:\n${_observacionCtrl.text}",
                    'fecha': DateTime.now().toIso8601String()
                  });

                  await _cargarDatosPaciente();

                  if (mounted) {
                    _observacionCtrl.clear();
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Añadir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarPerfil() {
    final TextEditingController nombreEditCtrl = TextEditingController(text: widget.paciente['nombre']);
    final TextEditingController edadEditCtrl = TextEditingController(text: widget.paciente['edad']?.toString());
    final TextEditingController expEditCtrl = TextEditingController(text: widget.paciente['expediente']);
    final TextEditingController ubiEditCtrl = TextEditingController(text: widget.paciente['ubicacion']);
    final TextEditingController dietaEditCtrl = TextEditingController(text: widget.paciente['dieta']);
    final TextEditingController alergiasEditCtrl = TextEditingController(text: widget.paciente['alergias']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Nombre', nombreEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Edad', edadEditCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Expediente', expEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Ubicación (Cama/Piso)', ubiEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Dieta', dietaEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Alergias', alergiasEditCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = DatabaseHelper();
                await db.actualizarPacienteEnfermero(widget.paciente['id'], {
                  'nombre': nombreEditCtrl.text,
                  'edad': edadEditCtrl.text,
                  'expediente': expEditCtrl.text,
                  'ubicacion': ubiEditCtrl.text,
                  'dieta': dietaEditCtrl.text,
                  'alergias': alergiasEditCtrl.text.isEmpty ? 'Ninguna' : alergiasEditCtrl.text,
                });

                setState(() {
                  widget.paciente['nombre'] = nombreEditCtrl.text;
                  widget.paciente['edad'] = edadEditCtrl.text;
                  widget.paciente['expediente'] = expEditCtrl.text;
                  widget.paciente['ubicacion'] = ubiEditCtrl.text;
                  widget.paciente['dieta'] = dietaEditCtrl.text;
                  widget.paciente['alergias'] = alergiasEditCtrl.text.isEmpty ? 'Ninguna' : alergiasEditCtrl.text;
                });

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar Paciente', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF4A4A))),
          content: const Text('¿Estás seguro de que deseas eliminar a este paciente? Toda su información y expediente clínico se perderá de forma permanente.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, 'eliminar');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4A4A)),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _crearCampoEdicion(String label, TextEditingController controlador, {bool esNumero = false}) {
    return TextField(
      controller: controlador,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
        ),
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

    // Variables para la grafica
    int limiteHipo = widget.paciente['hipoLimit'] ?? 70;
    int limiteHiper = widget.paciente['hiperLimit'] ?? 180;
    int rangoMin = widget.paciente['rangoMin'] ?? 80;
    int rangoMax = widget.paciente['rangoMax'] ?? 130;
    List<Map<String, dynamic>> registrosGrafica = _historialGlucosa.reversed.toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C63BB),
          elevation: 0,
          title: const Text('Expediente Clínico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C63BB),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.paciente['nombre'] ?? 'Paciente', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(widget.paciente['ubicacion'] ?? 'Ubicación sin asignar', style: const TextStyle(fontSize: 18, color: Color(0xFFE8E8E8))),
                          const SizedBox(height: 4),
                          Text('Edad: ${widget.paciente['edad'] ?? '--'} | Dieta: ${widget.paciente['dieta'] ?? 'Normal'}', style: const TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                        onPressed: _mostrarDialogoEditarPerfil,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text('Control Glucémico', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black))),
                        TextButton.icon(
                          onPressed: _mostrarDialogoAgregarGlucosa,
                          icon: const Icon(Icons.add, color: Color(0xFF0C80EB), size: 20),
                          label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: const Color(0xFFE8F4F8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF008CCF))),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm, color: Color(0xFF008CCF)),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Tipo: ${widget.paciente['tipoDiabetes'] ?? 'No especificado'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008CCF)))),
                        ],
                      ),
                    ),

                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
                      child: registrosGrafica.isEmpty
                          ? const Center(child: Text('Aún no hay medidas registradas', style: TextStyle(color: Colors.grey)))
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 5),
                            width: registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 40,
                            child: GestureDetector(
                              onTapUp: (details) {
                                double offsetX = 40.0;
                                double paddingX = 20.0;
                                double startX = offsetX + paddingX;

                                double customPaintWidth = (registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 40) - 40.0;
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
                                    _mostrarDetallesPunto(_historialGlucosa[indiceReal]);
                                  }
                                }
                              },
                              child: CustomPaint(
                                painter: _GraficaEnfermeroPainter(
                                  historial: registrosGrafica,
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
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(child: _crearTarjetaStat('Promedio', '${_calcularPromedio().toStringAsFixed(1)}', 'mg/dL', Icons.timeline, const Color(0xFF008CCF))),
                        const SizedBox(width: 15),
                        Expanded(child: _crearTarjetaStat('TIR', '${_calcularTIR().toStringAsFixed(0)}%', 'En rango', Icons.check_circle, const Color(0xFF2E7D32))),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 50, thickness: 1),

              if (widget.paciente['tipoDiabetes'] != 'Tipo 2') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(child: Text('Suministro de Insulina', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black))),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.calculate, color: Color(0xFFE65100), size: 22),
                                  tooltip: 'Calculadora ADA',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => PantallaCalculadoraEnfermero(paciente: widget.paciente))
                                    );
                                    if (result == true) {
                                      await _cargarDatosPaciente();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 5),
                              TextButton.icon(
                                onPressed: _mostrarDialogoAgregarInsulina,
                                icon: const Icon(Icons.colorize, color: Color(0xFF0C80EB), size: 20),
                                label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
                        child: _historialInsulina.isEmpty
                            ? const Text('No se ha suministrado insulina.', style: TextStyle(color: Colors.grey))
                            : Column(
                          children: List.generate(_historialInsulina.length, (index) {
                            final ins = _historialInsulina[index];
                            final fechaStr = DateFormat('dd MMM yyyy - hh:mm a').format(ins['fecha']);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(backgroundColor: Color(0xFFE8F4F8), child: Icon(Icons.water_drop, color: Color(0xFF008CCF))),
                              title: Text('${ins['unidades']} Unidades', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(fechaStr),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 50, thickness: 1),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Checklist de Medicamentos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 15),
                    if (_medicamentos.isEmpty)
                      const Text('No hay medicamentos registrados.', style: TextStyle(color: Colors.grey)),
                    ...List.generate(_medicamentos.length, (index) {
                      final med = _medicamentos[index];
                      bool suministrado = med['suministrado'] == 1;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: suministrado ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F), width: 1.5)
                        ),
                        child: CheckboxListTile(
                          title: Text('${med['nombre']} - ${med['dosis']}', style: TextStyle(fontWeight: FontWeight.bold, decoration: suministrado ? TextDecoration.lineThrough : null)),
                          subtitle: Text(med['frecuencia']),
                          value: suministrado,
                          activeColor: const Color(0xFF2E7D32),
                          checkColor: Colors.white,
                          onChanged: (bool? val) async {
                            final db = DatabaseHelper();
                            await db.actualizarEstadoMedicamentoEnfermero(med['id'], val! ? 1 : 0);
                            await _cargarDatosPaciente();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Divider(height: 50, thickness: 1),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text('Observaciones de Turno', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black))),
                        TextButton.icon(
                          onPressed: _mostrarDialogoObservacion,
                          icon: const Icon(Icons.note_add, color: Color(0xFF0C80EB), size: 20),
                          label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (widget.paciente['alergias'] != null && widget.paciente['alergias'] != 'Ninguna')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD32F2F))),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Alergias: ${widget.paciente['alergias']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)))),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),
                    ...List.generate(_observacionesBD.length, (index) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFFD166))),
                        child: Text(_observacionesBD[index], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _mostrarDialogoEliminar,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Eliminar Paciente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }

  Widget _crearTarjetaStat(String titulo, String valor, String subtitulo, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2D2D2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(height: 10),
          Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(subtitulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _GraficaEnfermeroPainter extends CustomPainter {
  final List<Map<String, dynamic>> historial;
  final int limiteHipo, limiteHiper, rangoMin, rangoMax;
  final int? indiceSeleccionado;

  _GraficaEnfermeroPainter({
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

      if (val < limiteHipo) c = const Color(0xFFD32F2F);
      else if (val > limiteHiper) c = const Color(0xFFD32F2F);
      else if (val >= rangoMin && val <= rangoMax) c = const Color(0xFF2E7D32);
      else if (val < rangoMin) c = const Color(0xFFE65100);
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
        TextPainter tpFecha = TextPainter(
          text: TextSpan(
            text: DateFormat('HH:mm').format(historial[i]['fecha']),
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
  bool shouldRepaint(covariant _GraficaEnfermeroPainter oldDelegate) {
    return oldDelegate.indiceSeleccionado != indiceSeleccionado || oldDelegate.historial != historial;
  }
}