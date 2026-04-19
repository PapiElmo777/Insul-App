import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../servicios/servicios/reporte_paciente_service.dart';
import 'pantalla_registros_paciente.dart';
import '../../database/database_helper.dart';
import 'pantalla_perfil_paciente.dart';
import 'pantalla_medicamentos_paciente.dart';
import 'pantalla_calculadora_dosis.dart';
import 'pantalla_identificacion_medica.dart';

class PantallaInicioPaciente extends StatefulWidget {
  final String nombrePaciente;

  const PantallaInicioPaciente({
    super.key,
    this.nombrePaciente = 'Paciente',
  });

  @override
  State<PantallaInicioPaciente> createState() => _PantallaInicioPacienteState();
}

class _PantallaInicioPacienteState extends State<PantallaInicioPaciente> {
  int _indiceNavegacionActual = 0;
  String _fechaFormateada = '';

  int? _pacienteId;
  bool _cargandoDatos = true;
  File? _imagenPerfil;

  // Variables de paciente completas
  Map<String, dynamic> _datosPacienteComp = {};
  List<Map<String, dynamic>> _reportesGenerados = [];

  // Variables de control
  int limiteHipo = 70;
  int limiteHiper = 180;
  int rangoMin = 80;
  int rangoMax = 130;

  List<Map<String, dynamic>> _registrosGlucosa = [];

  @override
  void initState() {
    super.initState();
    _inicializarFecha();
    _cargarDatosBD();
  }

  Future<void> _cargarDatosBD() async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();

    if (usuarioId != null) {
      final usuario = await db.obtenerUsuarioPorId(usuarioId);
      final paciente = await db.obtenerPacientePorUsuario(usuarioId);
      if (paciente != null) {
        _pacienteId = paciente['id'];

        _datosPacienteComp = {
          'nombre': usuario?['nombre'] ?? widget.nombrePaciente,
          'edad': paciente['edad'],
          'peso': paciente['peso'],
          'altura': paciente['altura'],
          'imc': paciente['imc'],
          'tipoDiabetes': paciente['tipo_diabetes'],
          'medico': paciente['medico_nombre'],
          'limiteHipo': (paciente['limite_hipo'] as num?)?.toInt() ?? 70,
          'hiperLimit': (paciente['limite_hiper'] as num?)?.toInt() ?? 180,
          'rangoMin': (paciente['rango_min'] as num?)?.toInt() ?? 80,
          'rangoMax': (paciente['rango_max'] as num?)?.toInt() ?? 130,
        };

        if (usuario?['foto_perfil'] != null && usuario!['foto_perfil'].toString().isNotEmpty) {
          _imagenPerfil = File(usuario?['foto_perfil']);
        } else {
          _imagenPerfil = null;
        }

        limiteHipo = _datosPacienteComp['limiteHipo'];
        limiteHiper = _datosPacienteComp['hiperLimit'];
        rangoMin = _datosPacienteComp['rangoMin'];
        rangoMax = _datosPacienteComp['rangoMax'];

        final registrosBD = await db.obtenerRegistrosGlucosa(_pacienteId!);
        _registrosGlucosa = registrosBD
            .where((r) => (r['valor'] as num) > 0)
            .map((r) => {
          'valor': (r['valor'] as num).toInt(),
          'momento': r['momento'],
          'fecha': DateTime.parse(r['fecha']),
          'notas': r['notas'] ?? '',
        }).toList();

        final reportesBD = await db.obtenerReportesDePaciente(_pacienteId!);
        _reportesGenerados = reportesBD.map((r) => {
          'id': r['id'],
          'periodo': r['periodo'],
          'fecha': DateTime.parse(r['fecha']),
          'bytes': r['archivo_bytes'] as Uint8List,
        }).toList();
      }
    }

    if (mounted) {
      setState(() {
        _cargandoDatos = false;
      });
    }
  }

  Future<void> _inicializarFecha() async {
    await initializeDateFormatting('es_ES', null);
    final DateTime ahora = DateTime.now();
    final DateFormat formateador = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es_ES');
    String fecha = formateador.format(ahora);
    if (fecha.isNotEmpty) {
      fecha = fecha[0].toUpperCase() + fecha.substring(1);
    }
    setState(() {
      _fechaFormateada = fecha;
    });
  }

  String _obtenerSaludo() {
    var hora = DateTime.now().hour;
    if (hora < 12) {
      return 'Buenos días';
    } else if (hora < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  int _obtenerUltimaGlucosa() {
    if (_registrosGlucosa.isEmpty) return 0;
    return _registrosGlucosa.first['valor'];
  }

  String _obtenerTiempoUltimaLectura() {
    if (_registrosGlucosa.isEmpty) return '--';
    final fecha = _registrosGlucosa.first['fecha'] as DateTime;
    return DateFormat("d/M/yyyy 'a las' HH:mm", 'es_ES').format(fecha);
  }

  String _obtenerMomentoUltimaLectura() {
    if (_registrosGlucosa.isEmpty) return '--';
    return _registrosGlucosa.first['momento'];
  }

  String _obtenerEstadoGlucosa(int valor) {
    if (valor < limiteHipo) return 'Hipoglucemia';
    if (valor >= limiteHipo && valor < rangoMin) return 'Bajo';
    if (valor >= rangoMin && valor <= rangoMax) return 'Normal';
    if (valor > rangoMax && valor <= limiteHiper) return 'Elevado';
    return 'Hiperglucemia';
  }

  int _calcularPromedioGlucosa() {
    if (_registrosGlucosa.isEmpty) return 0;
    int suma = 0;
    for (var r in _registrosGlucosa) {
      suma += r['valor'] as int;
    }
    return (suma / _registrosGlucosa.length).round();
  }

  int _calcularTIR() {
    if (_registrosGlucosa.isEmpty) return 0;
    int enRango = 0;
    for (var r in _registrosGlucosa) {
      int val = r['valor'] as int;
      if (val >= rangoMin && val <= rangoMax) {
        enRango++;
      }
    }
    return ((enRango / _registrosGlucosa.length) * 100).round();
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
                            hintText: 'Ej. Me siento mareado, comí pastel...',
                            hintStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (valorCtrl.text.isNotEmpty) {
                                int valor = int.tryParse(valorCtrl.text) ?? 0;
                                if (valor > 0 && _pacienteId != null) {
                                  final db = DatabaseHelper();
                                  await db.insertarRegistroGlucosa({
                                    'paciente_id': _pacienteId,
                                    'valor': valor,
                                    'momento': momentoSeleccionado,
                                    'notas': notasCtrl.text,
                                    'fecha': fechaSeleccionada.toIso8601String(),
                                  });

                                  await _cargarDatosBD();

                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
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

  void _mostrarDialogoTIR() {
    int total = _registrosGlucosa.length;
    int cHipo = 0, cBajo = 0, cNormal = 0, cElevado = 0, cHiper = 0;

    if (total > 0) {
      for (var r in _registrosGlucosa) {
        int val = r['valor'] as int;
        if (val < limiteHipo) cHipo++;
        else if (val < rangoMin) cBajo++;
        else if (val <= rangoMax) cNormal++;
        else if (val <= limiteHiper) cElevado++;
        else cHiper++;
      }
    }

    int pctHipo = total > 0 ? ((cHipo / total) * 100).round() : 0;
    int pctBajo = total > 0 ? ((cBajo / total) * 100).round() : 0;
    int pctNormal = total > 0 ? ((cNormal / total) * 100).round() : 0;
    int pctElevado = total > 0 ? ((cElevado / total) * 100).round() : 0;
    int pctHiper = total > 0 ? ((cHiper / total) * 100).round() : 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tiempo en Rango (TIR)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2F2F2F))),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('El TIR es el porcentaje del tiempo que tu glucosa está en cada nivel (dentro y fuera de rango).', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 25),
                SizedBox(
                  height: 320,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 8), child: _etiquetaTir('Hiperglucemia', '$pctHiper%', const Color(0xFFD32F2F))),
                            _etiquetaTir('Elevado', '$pctElevado%', const Color(0xFFE65100)),
                            _etiquetaTir('En Rango', '$pctNormal%', const Color(0xFF2E7D32), esMeta: true),
                            _etiquetaTir('Bajo', '$pctBajo%', const Color(0xFFE65100)),
                            Padding(padding: const EdgeInsets.only(bottom: 8), child: _etiquetaTir('Hipoglucemia', '$pctHipo%', const Color(0xFFD32F2F))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      ClipPath(
                        clipper: _DropClipper(),
                        child: Container(
                          width: 145, height: 320, color: Colors.white,
                          child: Column(
                            children: [
                              Container(height: 50, width: double.infinity, color: const Color(0xFFD32F2F), alignment: Alignment.bottomCenter, padding: const EdgeInsets.only(bottom: 2), child: Text('>$limiteHiper\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                              Container(height: 55, width: double.infinity, color: const Color(0xFFE65100), alignment: Alignment.center, child: Text('${rangoMax + 1}-$limiteHiper\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                              Container(height: 110, width: double.infinity, color: const Color(0xFF2E7D32), alignment: Alignment.center, child: Text('Objetivo\n$rangoMin-$rangoMax\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white, height: 1.2))),
                              Container(height: 55, width: double.infinity, color: const Color(0xFFE65100), alignment: Alignment.center, child: Text('$limiteHipo-${rangoMin - 1}\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                              Container(height: 50, width: double.infinity, color: const Color(0xFFD32F2F), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('<$limiteHipo mg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoVariabilidad() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.waves, size: 50, color: Color(0xFF1C63BB)),
                const SizedBox(height: 15),
                const Text('Variabilidad Glucémica (CV)', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
                const SizedBox(height: 15),
                const Text('El Coeficiente de Variación (CV) mide qué tanto "brincan" tus niveles de azúcar respecto a tu promedio diario.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
                  child: Column(
                    children: [
                      Row(children: const [Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20), SizedBox(width: 10), Expanded(child: Text('Menor al 36% indica niveles estables (buen control).', style: TextStyle(fontSize: 13)))]),
                      const SizedBox(height: 10),
                      Row(children: const [Icon(Icons.warning, color: Color(0xFFE65100), size: 20), SizedBox(width: 10), Expanded(child: Text('Mayor al 36% significa picos altos y bajos frecuentes, lo que puede causar daño a largo plazo.', style: TextStyle(fontSize: 13)))]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text('Entendido', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _etiquetaTir(String titulo, String porcentaje, Color color, {bool esMeta = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(porcentaje, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
        if (esMeta)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('META', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 9),
              ],
            ),
          ),
      ],
    );
  }

  Widget _construirLeyendaColores() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _itemLeyenda(const Color(0xFFD32F2F), 'Hipo'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Bajo'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFF2E7D32), 'Normal'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Elevado'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFD32F2F), 'Hiper'),
          ],
        ),
      ),
    );
  }

  Widget _itemLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(
        index: _indiceNavegacionActual,
        children: [
          _construirDashboard(), // 0: Inicio
          SafeArea(
            child: PantallaRegistrosPaciente(
              registros: _registrosGlucosa,
              limiteHipo: limiteHipo,
              limiteHiper: limiteHiper,
              rangoMin: rangoMin,
              rangoMax: rangoMax,
              onAgregarRegistro: (nuevoRegistro) async {
                if (_pacienteId != null) {
                  final db = DatabaseHelper();
                  await db.insertarRegistroGlucosa({
                    'paciente_id': _pacienteId,
                    'valor': nuevoRegistro['valor'],
                    'momento': nuevoRegistro['momento'],
                    'notas': nuevoRegistro['notas'],
                    'fecha': (nuevoRegistro['fecha'] as DateTime).toIso8601String(),
                  });
                  await _cargarDatosBD();
                }
              },
            ),
          ),

          PantallaCalculadoraDosis(onRegistroGuardado: _cargarDatosBD),

          _construirTabHistorial(),

          const SafeArea(child: PantallaMedicamentosPaciente()),
          SafeArea(child: PantallaIdentificacionMedica(onActualizarDashboard: _cargarDatosBD)),

          SafeArea(
            child: TabPerfilPaciente(
              nombrePaciente: widget.nombrePaciente,
              onActualizarDashboard: _cargarDatosBD,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _construirBottomNavigation(),
    );
  }

  Widget _construirTabHistorial() {
    double cv = 0.0;
    if (_registrosGlucosa.isNotEmpty) {
      double prom = _calcularPromedioGlucosa().toDouble();
      double sumaCuadrados = 0;
      for (var r in _registrosGlucosa) {
        sumaCuadrados += math.pow((r['valor'] - prom), 2);
      }
      double desvStd = math.sqrt(sumaCuadrados / _registrosGlucosa.length);
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
                      Text('Historial Clínico', style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(height: 5),
                      Text('Análisis y exportación de Perfil Ambulatorio de Glucosa (AGP).', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.picture_as_pdf, size: 60, color: Color(0xFF1C63BB)),
                  const SizedBox(height: 15),
                  const Text('Informe AGP del Paciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                        if (_registrosGlucosa.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Necesitas registrar lecturas de glucosa primero.')));
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                        );

                        try {
                          final bytes = await ReportePacienteService.generarReporteAGP(
                            paciente: _datosPacienteComp,
                            registros: _registrosGlucosa,
                          );

                          final db = DatabaseHelper();
                          final String idUnico = DateTime.now().millisecondsSinceEpoch.toString();

                          await db.insertarReportePaciente({
                            'id': idUnico,
                            'paciente_id': _pacienteId,
                            'periodo': 'Histórico Completo',
                            'fecha': DateTime.now().toIso8601String(),
                            'archivo_bytes': bytes,
                          });

                          await _cargarDatosBD();

                          if (!mounted) return;
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VisorAGPPantalla(bytes: bytes),
                            ),
                          );
                        } catch(e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text('Generar PDF para Médico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008CCF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text('Resumen del Periodo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _mostrarDialogoVariabilidad,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF0C80EB), width: 1.5)
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Variabilidad (CV)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                              SizedBox(width: 4),
                              Icon(Icons.info_outline, size: 14, color: Color(0xFF1C63BB)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text('${cv.toStringAsFixed(1)}%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cv > 36 ? const Color(0xFFE65100) : const Color(0xFF2E7D32))),
                          const Text('Toca para saber más', style: TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
                    child: Column(
                      children: [
                        const Text('Lecturas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text('${_registrosGlucosa.length}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                        const Text('Registros totales', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            const Divider(thickness: 1, color: Color(0xFFD2D2D2)),
            const SizedBox(height: 20),

            const Text('Historial de Archivos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),

            if (_reportesGenerados.isEmpty)
              const Text('Aún no has generado ningún informe para tu médico.', style: TextStyle(color: Colors.grey, fontSize: 14))
            else
              ...List.generate(_reportesGenerados.length, (index) {
                final reporte = _reportesGenerados[index];
                final String fechaF = DateFormat('dd/MM/yyyy').format(reporte['fecha']);
                final titulo = 'Historial periodo ($fechaF)';

                return Card(
                  key: Key(reporte['id']),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFFD2D2D2)),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                      child: const Icon(Icons.description, color: Color(0xFF1C63BB)),
                    ),
                    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('Generado a las: ${DateFormat('HH:mm').format(reporte['fecha'])}', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.visibility, color: Color(0xFF0C80EB)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisorAGPPantalla(
                            bytes: reporte['bytes'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _construirDashboard() {
    final ultimaG = _obtenerUltimaGlucosa();
    final estadoG = _obtenerEstadoGlucosa(ultimaG);

    Color colorFondo;
    Color colorTexto = Colors.white;
    Color colorBorde;

    if (estadoG == 'Hipoglucemia' || estadoG == 'Hiperglucemia') {
      colorFondo = const Color(0xFFFFEBEE);
      colorTexto = const Color(0xFFD32F2F);
      colorBorde = const Color(0xFFD32F2F);
    } else if (estadoG == 'Bajo' || estadoG == 'Elevado') {
      colorFondo = const Color(0xFFFFF3E0);
      colorTexto = const Color(0xFFE65100);
      colorBorde = const Color(0xFFE65100);
    } else {
      colorFondo = const Color(0xFFE8F5E9);
      colorTexto = const Color(0xFF2E7D32);
      colorBorde = const Color(0xFF2E7D32);
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
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_obtenerSaludo()},\n${widget.nombrePaciente}',
                              style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 26, color: Colors.white, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(_fechaFormateada, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFFE8E8E8))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() { _indiceNavegacionActual = 6; });
                        },
                        child: Container(
                          width: 55, height: 55,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2), border: Border.all(color: Colors.white, width: 2)),
                          child: _imagenPerfil != null
                              ? ClipOval(child: Image.file(_imagenPerfil!, fit: BoxFit.cover, width: 55, height: 55))
                              : const Icon(Icons.person, color: Colors.white, size: 30),
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
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Última Lectura',
                        style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF3F3F3F)),
                      ),
                      Icon(Icons.show_chart_rounded, color: Colors.grey.shade500, size: 24),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _registrosGlucosa.isEmpty ? '--' : ultimaG.toString(),
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 52, height: 1.0, color: Color(0xFF01689C)),
                      ),
                      const SizedBox(width: 6),
                      const Text('mg/dL', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 20, color: Color(0xFF848282))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_registrosGlucosa.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: colorFondo, border: Border.all(color: colorBorde, width: 1.5), borderRadius: BorderRadius.circular(20)),
                          child: Text(estadoG, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 11, color: colorTexto)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF888888), width: 1.5), borderRadius: BorderRadius.circular(20)),
                          child: Text(_obtenerMomentoUltimaLectura(), style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF888888))),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_obtenerTiempoUltimaLectura(), style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFFC5C5C5))),
                      GestureDetector(
                        onTap: () {
                          setState(() { _indiceNavegacionActual = 1; });
                        },
                        child: const Text('Ver todos registros', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF888888), decoration: TextDecoration.underline)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            _construirLeyendaColores(),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFD2D2D2), width: 2), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('Tiempo en nivel normal (TIR)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F))),
                        const SizedBox(height: 2),
                        Text(
                          _registrosGlucosa.isEmpty ? '--%' : '${_calcularTIR()}%',
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 38, height: 1.2, color: Color(0xFF01689C)),
                        ),
                        GestureDetector(
                          onTap: _registrosGlucosa.isEmpty ? null : _mostrarDialogoTIR,
                          child: Text(
                            'Ver mas',
                            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: _registrosGlucosa.isEmpty ? Colors.transparent : const Color(0xFF888888), decoration: TextDecoration.underline),
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
                        const Text('Promedio', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F))),
                        const SizedBox(height: 2),
                        Text(
                          _registrosGlucosa.isEmpty ? '--' : _calcularPromedioGlucosa().toString(),
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 38, height: 1.2, color: Color(0xFF01689C)),
                        ),
                        const Text('Histórico total', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF888888))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Acciones Rápidas', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF2F2F2F))),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFE8E8E8), thickness: 1.5, height: 1),
                  _crearAccionRapida(Icons.edit_document, 'Registrar Lectura de Glucosa', () {
                    _mostrarFormularioNuevaMedida();
                  }),
                  _crearAccionRapida(Icons.medication, 'Registrar Medicamento', () {
                    setState(() { _indiceNavegacionActual = 4; });
                  }),
                  _crearAccionRapida(Icons.calculate, 'Calcular Dosis de Insulina', () {
                    setState(() { _indiceNavegacionActual = 2; });
                  }),
                  const Divider(color: Color(0xFFE8E8E8), thickness: 1.5, height: 1),
                  _crearAccionRapida(Icons.timeline, 'Ver Historial Completo', () {
                    setState(() { _indiceNavegacionActual = 1; });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Información importante', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2F2F2F))),
                  const SizedBox(height: 15),
                  _crearVinietaInfo('Esta aplicación es una herramienta de apoyo, no reemplaza la consulta médica'),
                  const SizedBox(height: 10),
                  _crearVinietaInfo('Consulta con tu médico para establecer tu rango objetivo personalizado'),
                  const SizedBox(height: 10),
                  _crearVinietaInfo('Mantén tu información actualizada para obtener mejores resultados.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _crearAccionRapida(IconData icono, String texto, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Icon(icono, color: const Color(0xFF1C63BB), size: 26),
            const SizedBox(width: 15),
            Expanded(child: Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2F2F2F)))),
          ],
        ),
      ),
    );
  }

  Widget _crearVinietaInfo(String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 8.0),
          child: Icon(Icons.circle, size: 6, color: Color(0xFF2F2F2F)),
        ),
        Expanded(child: Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), height: 1.4))),
      ],
    );
  }

  Widget _construirBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: _indiceNavegacionActual,
          onTap: (index) {
            setState(() { _indiceNavegacionActual = index; });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2F2F2F),
          unselectedItemColor: const Color(0xFF888888),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.home_filled, size: 28, color: _indiceNavegacionActual == 0 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 0) _puntoRojo()]),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.show_chart_rounded, size: 28, color: _indiceNavegacionActual == 1 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 1) _puntoRojo()]),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calculate, size: 28, color: _indiceNavegacionActual == 2 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 2) _puntoRojo()]),
              label: 'Cálculo',
            ),
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.picture_as_pdf_sharp, size: 28, color: _indiceNavegacionActual == 3 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 3) _puntoRojo()]),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.medication, size: 28, color: _indiceNavegacionActual == 4 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 4) _puntoRojo()]),
              label: 'Medicamentos',
            ),
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.badge, size: 28, color: _indiceNavegacionActual == 5 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 5) _puntoRojo()]),
              label: 'ID Médica',
            ),
            BottomNavigationBarItem(
              icon: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person, size: 28, color: _indiceNavegacionActual == 6 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)), if (_indiceNavegacionActual == 6) _puntoRojo()]),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _puntoRojo() {
    return Container(margin: const EdgeInsets.only(top: 4), width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFFF4A4A), shape: BoxShape.circle));
  }
}

class VisorAGPPantalla extends StatelessWidget {
  final Uint8List bytes;

  const VisorAGPPantalla({
    super.key,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C63BB),
        title: const Text('Informe AGP Generado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        build: (format) async => bytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'Reporte_AGP_InsulApp.pdf',
      ),
    );
  }
}

// Gota TIR
class _DropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    double r = w / 2;
    double cy = h - r;
    path.moveTo(w / 2, 0);
    path.quadraticBezierTo(w, cy - (r * 1.2), w, cy);
    path.arcToPoint(Offset(0, cy), radius: Radius.circular(r), clockwise: true);
    path.quadraticBezierTo(0, cy - (r * 1.2), w / 2, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}