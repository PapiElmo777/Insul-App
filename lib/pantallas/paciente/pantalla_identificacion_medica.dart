import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';

class PantallaIdentificacionMedica extends StatefulWidget {
  final VoidCallback onActualizarDashboard;

  const PantallaIdentificacionMedica({super.key, required this.onActualizarDashboard});

  @override
  State<PantallaIdentificacionMedica> createState() => _PantallaIdentificacionMedicaState();
}

class _PantallaIdentificacionMedicaState extends State<PantallaIdentificacionMedica> {
  bool _cargando = true;
  bool _identificacionCompletada = false;

  int? _usuarioId;
  int? _pacienteId;
  Map<String, dynamic> _datosCompletos = {};
  List<Map<String, dynamic>> _medicamentos = [];

  // Variables Resumen Glucemico
  int _promedio = 0;
  int _tir = 0;
  int _pctHipo = 0;
  int _pctHiper = 0;
  int _minG = 0;
  int _maxG = 0;

  // Controladores del Formulario Inicial
  final _enfCronicasCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _hospCtrl = TextEditingController();
  final _cirugiasCtrl = TextEditingController();
  final _emergenciaNombreCtrl = TextEditingController();
  final _emergenciaTelCtrl = TextEditingController();
  final _medicoCtrl = TextEditingController();
  final _clinicaCtrl = TextEditingController();

  // Tipo SanguIneo
  String _tipoSanguineoSeleccionado = 'No sabe';
  final List<String> _tiposSanguineos = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'No sabe'];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();

    if (usuarioId != null) {
      _usuarioId = usuarioId;
      final usuario = await db.obtenerUsuarioPorId(usuarioId);
      final paciente = await db.obtenerPacientePorUsuario(usuarioId);

      if (paciente != null && usuario != null) {
        _pacienteId = paciente['id'];
        _identificacionCompletada = (paciente['identificacion_completada'] ?? 0) == 1;

        _datosCompletos = {
          'nombre_completo': '${usuario['nombre']} ${usuario['apellidos']}',
          'edad': paciente['edad']?.toString() ?? '--',
          'sexo': paciente['sexo'] ?? '--',
          'tipo_diabetes': paciente['tipo_diabetes'] ?? 'No especificado',
          'tipo_sanguineo': paciente['tipo_sanguineo'] ?? 'No sabe',
          'alergias': paciente['alergias'] ?? 'Ninguna',
          'enfermedades_cronicas': paciente['enfermedades_cronicas'] ?? 'Ninguna',
          'hospitalizaciones': paciente['hospitalizaciones'] ?? 'Ninguna',
          'cirugias': paciente['cirugias'] ?? 'Ninguna',
          'clinica': paciente['clinica'] ?? 'No especificada',
          'medico_nombre': paciente['medico_nombre'] ?? 'No asignado',
          'emergencia_nombre': paciente['emergencia_nombre'] ?? 'No asignado',
          'emergencia_telefono': paciente['emergencia_telefono'] ?? '--',
          'metodo_insulina': paciente['metodo_insulina'] ?? 'No usa',
          'insulina_basal_marca': paciente['insulina_basal_marca'] ?? '',
          'insulina_basal_dosis': paciente['insulina_basal_dosis'] ?? '',
          'insulina_rapida_marca': paciente['insulina_rapida_marca'] ?? '',
        };

        if (!_identificacionCompletada) {
          _alergiasCtrl.text = _datosCompletos['alergias'] == 'Ninguna' ? '' : _datosCompletos['alergias'];
          _emergenciaNombreCtrl.text = _datosCompletos['emergencia_nombre'] == 'No asignado' ? '' : _datosCompletos['emergencia_nombre'];
          _emergenciaTelCtrl.text = _datosCompletos['emergencia_telefono'] == '--' ? '' : _datosCompletos['emergencia_telefono'];
          _medicoCtrl.text = _datosCompletos['medico_nombre'] == 'No asignado' ? '' : _datosCompletos['medico_nombre'];

          if (_tiposSanguineos.contains(_datosCompletos['tipo_sanguineo'])) {
            _tipoSanguineoSeleccionado = _datosCompletos['tipo_sanguineo'];
          }
        }

        final medsBD = await db.obtenerMedicamentosDePaciente(_pacienteId!);
        _medicamentos = List<Map<String, dynamic>>.from(medsBD);
        if (paciente['med_oral_nombre'] != null && paciente['med_oral_nombre'].toString().isNotEmpty) {
          _medicamentos.insert(0, {'nombre': paciente['med_oral_nombre'], 'gramaje': paciente['med_oral_dosis'] ?? ''});
        }

        final registrosBD = await db.obtenerRegistrosGlucosa(_pacienteId!);
        final lecturas = registrosBD.where((r) => (r['valor'] as num) > 0).toList();

        if (lecturas.isNotEmpty) {
          int suma = 0;
          int countNormal = 0;
          int countHipo = 0;
          int countHiper = 0;
          int min = 999;
          int max = 0;

          int limHipo = (paciente['limite_hipo'] as num?)?.toInt() ?? 70;
          int limHiper = (paciente['limite_hiper'] as num?)?.toInt() ?? 180;
          int rMin = (paciente['rango_min'] as num?)?.toInt() ?? 80;
          int rMax = (paciente['rango_max'] as num?)?.toInt() ?? 130;

          for (var r in lecturas) {
            int v = (r['valor'] as num).toInt();
            suma += v;
            if (v < min) min = v;
            if (v > max) max = v;

            if (v < limHipo) countHipo++;
            else if (v > limHiper) countHiper++;
            else if (v >= rMin && v <= rMax) countNormal++;
          }

          _promedio = (suma / lecturas.length).round();
          _minG = min;
          _maxG = max;
          _tir = ((countNormal / lecturas.length) * 100).round();
          _pctHipo = ((countHipo / lecturas.length) * 100).round();
          _pctHiper = ((countHiper / lecturas.length) * 100).round();
        }
      }
    }

    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardarFormulario() async {
    if (_usuarioId == null) return;

    final db = DatabaseHelper();
    await db.actualizarPaciente(_usuarioId!, {
      'enfermedades_cronicas': _enfCronicasCtrl.text.isEmpty ? 'Ninguna' : _enfCronicasCtrl.text,
      'alergias': _alergiasCtrl.text.isEmpty ? 'Ninguna' : _alergiasCtrl.text,
      'tipo_sanguineo': _tipoSanguineoSeleccionado,
      'hospitalizaciones': _hospCtrl.text.isEmpty ? 'Ninguna' : _hospCtrl.text,
      'cirugias': _cirugiasCtrl.text.isEmpty ? 'Ninguna' : _cirugiasCtrl.text,
      'emergencia_nombre': _emergenciaNombreCtrl.text,
      'emergencia_telefono': _emergenciaTelCtrl.text,
      'medico_nombre': _medicoCtrl.text,
      'clinica': _clinicaCtrl.text.isEmpty ? 'No especificada' : _clinicaCtrl.text,
      'identificacion_completada': 1,
    });

    widget.onActualizarDashboard();
    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(backgroundColor: Color(0xFFF5F7FA), body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _identificacionCompletada ? _construirTarjetaIdentificacion() : _construirFormularioInicial(),
    );
  }

  // FORMULARIO INICIAL
  Widget _construirFormularioInicial() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF1C63BB),
          expandedHeight: 140.0,
          floating: true, snap: true, pinned: false, automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Identificación Médica', style: TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 5),
                    Text('Completa tu información clínica para emergencias.', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE65100))),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFFE65100)),
                      SizedBox(width: 10),
                      Expanded(child: Text('Esta información será vital en caso de una emergencia médica. Los medicamentos se sincronizarán automáticamente con tu pestaña de "Mis Medicamentos".', style: TextStyle(color: Color(0xFFE65100), fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                const Text('Salud General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                const SizedBox(height: 15),

                const Text('Tipo Sanguíneo', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _tipoSanguineoSeleccionado,
                      isExpanded: true,
                      icon: const Icon(Icons.water_drop, color: Color(0xFFD32F2F)),
                      items: _tiposSanguineos.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
                      onChanged: (val) => setState(() => _tipoSanguineoSeleccionado = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _crearCampoFormulario('Alergias (Medicamentos o alimentos)', _alergiasCtrl, Icons.warning_amber_rounded),
                const SizedBox(height: 15),
                _crearCampoFormulario('Enfermedades Crónicas (Ej. Hipertensión)', _enfCronicasCtrl, Icons.coronavirus_outlined),

                const SizedBox(height: 25),
                const Text('Historial Clínico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                const SizedBox(height: 15),
                _crearCampoFormulario('Hospitalizaciones Recientes (Motivo)', _hospCtrl, Icons.local_hospital_outlined, maxLines: 2),
                const SizedBox(height: 15),
                _crearCampoFormulario('Cirugías Previas', _cirugiasCtrl, Icons.content_cut, maxLines: 2),

                const SizedBox(height: 25),
                const Text('Contacto y Seguimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                const SizedBox(height: 15),
                _crearCampoFormulario('Nombre del Médico Tratante', _medicoCtrl, Icons.person_outline),
                const SizedBox(height: 15),
                _crearCampoFormulario('Clínica u Hospital de Atención', _clinicaCtrl, Icons.business_outlined),
                const SizedBox(height: 15),
                _crearCampoFormulario('Contacto de Emergencia (Nombre)', _emergenciaNombreCtrl, Icons.contact_emergency_outlined),
                const SizedBox(height: 15),
                _crearCampoFormulario('Teléfono de Emergencia', _emergenciaTelCtrl, Icons.phone_outlined, isPhone: true),

                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _guardarFormulario,
                    icon: const Icon(Icons.save_alt, color: Colors.white),
                    label: const Text('Generar Identificación Médica', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _crearCampoFormulario(String label, TextEditingController controller, IconData icon, {bool isPhone = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1C63BB)),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD2D2D2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD2D2D2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1C63BB), width: 2)),
      ),
    );
  }

  // TARJETA DE IDENTIFICACION MEDICA
  Widget _construirTarjetaIdentificacion() {

    String strInsulina = 'No usa insulina / No configurado';
    if (_datosCompletos['metodo_insulina'] != 'No usa' && _datosCompletos['metodo_insulina'] != 'No especificado' && _datosCompletos['metodo_insulina'] != null) {
      String metodo = _datosCompletos['metodo_insulina'];
      List<String> lineas = [];
      if (_datosCompletos['insulina_basal_marca'].toString().isNotEmpty) {
        String dosis = _datosCompletos['insulina_basal_dosis'].toString();
        lineas.add('• Basal: ${_datosCompletos['insulina_basal_marca']} ${dosis.isNotEmpty ? '($dosis UI)' : ''}');
      }
      if (_datosCompletos['insulina_rapida_marca'].toString().isNotEmpty) {
        lineas.add('• Rápida: ${_datosCompletos['insulina_rapida_marca']} (Por corrección/comida)');
      }
      if(lineas.isNotEmpty){
        strInsulina = '$metodo:\n${lineas.join('\n')}';
      } else {
        strInsulina = metodo;
      }
    }

    // ── FORMATEAMOS LOS MEDICAMENTOS ORALES ──
    String strMeds = 'Ningún medicamento registrado';
    if (_medicamentos.isNotEmpty) {
      strMeds = _medicamentos.map((m) => '• ${m['nombre']} (${m['gramaje']})').join('\n');
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF1C63BB),
          expandedHeight: 140.0,
          floating: true, snap: true, pinned: true, automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ID Médica', style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.medical_information, color: Colors.white, size: 28)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text('Resumen clínico en caso de emergencia.', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ──ENCABEZADO DE LA CREDENCIAL ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1C63BB), width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: Color(0xFF1C63BB), borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFF1C63BB), size: 30)),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_datosCompletos['nombre_completo'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('${_datosCompletos['edad']} años  |  Sexo: ${_datosCompletos['sexo']}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ID Expediente', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text('#PAC-00${_pacienteId ?? 'X'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Fecha de Reporte', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──INFORMACION CRITICA ──
                _construirSeccion(
                  titulo: 'Información Crítica',
                  icono: Icons.warning_rounded,
                  colorIcono: const Color(0xFFD32F2F),
                  contenido: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _filaInfo(Icons.medical_services, 'Diagnóstico', _datosCompletos['tipo_diabetes'], color: const Color(0xFF1C63BB))),
                          Expanded(child: _filaInfo(Icons.water_drop, 'Tipo Sanguíneo', _datosCompletos['tipo_sanguineo'], color: const Color(0xFFD32F2F), negrita: true)),
                        ],
                      ),
                      _filaInfo(Icons.colorize, 'Esquema de Insulina', strInsulina),
                      _filaInfo(Icons.medication, 'Fármacos Orales', strMeds),
                      _filaInfo(Icons.coronavirus, 'Enfermedades Crónicas', _datosCompletos['enfermedades_cronicas']),
                      _filaInfo(Icons.no_meals, 'Alergias', _datosCompletos['alergias'], color: const Color(0xFFD32F2F), negrita: true),
                      const Divider(height: 25),
                      _filaInfo(Icons.contact_emergency, 'Contacto de Emergencia', '${_datosCompletos['emergencia_nombre']} \n📞 ${_datosCompletos['emergencia_telefono']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──RESUMEN GLUCEMICO ──
                _construirSeccion(
                  titulo: 'Resumen Glucémico',
                  icono: Icons.pie_chart,
                  colorIcono: const Color(0xFF2E7D32),
                  contenido: Column(
                    children: [
                      Row(
                        children: [
                          _bloqueMetrica('Promedio', '$_promedio', 'mg/dL', const Color(0xFF1C63BB)),
                          const SizedBox(width: 10),
                          _bloqueMetrica('En Rango', '$_tir%', 'TIR Meta', const Color(0xFF2E7D32)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _minimetro('Hipo (<70)', '$_pctHipo%', const Color(0xFFD32F2F)),
                          _minimetro('Hiper (>180)', '$_pctHiper%', const Color(0xFFE65100)),
                          _minimetro('Mínima', '$_minG', const Color(0xFFD32F2F)),
                          _minimetro('Máxima', '$_maxG', const Color(0xFFE65100)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──EVENTOS CLINICOS ──
                _construirSeccion(
                  titulo: 'Eventos Clínicos',
                  icono: Icons.local_hospital,
                  colorIcono: const Color(0xFF008CCF),
                  contenido: Column(
                    children: [
                      _filaInfo(Icons.hotel, 'Hospitalizaciones Recientes', _datosCompletos['hospitalizaciones']),
                      _filaInfo(Icons.content_cut, 'Cirugías Previas', _datosCompletos['cirugias']),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──CONTACTO Y SEGUIMIENTO ──
                _construirSeccion(
                  titulo: 'Seguimiento Médico',
                  icono: Icons.business,
                  colorIcono: Colors.black87,
                  contenido: Column(
                    children: [
                      _filaInfo(Icons.person_pin, 'Médico Responsable', _datosCompletos['medico_nombre']),
                      _filaInfo(Icons.local_hospital_rounded, 'Clínica / Institución', _datosCompletos['clinica']),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccion({required String titulo, required IconData icono, required Color colorIcono, required Widget contenido}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colorIcono, size: 24),
              const SizedBox(width: 10),
              Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 20),
          contenido,
        ],
      ),
    );
  }

  Widget _filaInfo(IconData icono, String titulo, String valor, {Color color = Colors.black87, bool negrita = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(valor, style: TextStyle(fontSize: 14, color: color, fontWeight: negrita ? FontWeight.bold : FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bloqueMetrica(String titulo, String valor, String subtitulo, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          children: [
            Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(valor, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
            Text(subtitulo, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _minimetro(String titulo, String valor, Color color) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}