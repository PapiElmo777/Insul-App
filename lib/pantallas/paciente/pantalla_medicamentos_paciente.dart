import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class PantallaMedicamentosPaciente extends StatefulWidget {
  const PantallaMedicamentosPaciente({super.key});

  @override
  State<PantallaMedicamentosPaciente> createState() => _PantallaMedicamentosPacienteState();
}

class _PantallaMedicamentosPacienteState extends State<PantallaMedicamentosPaciente> {
  bool _cargando = true;
  int? _pacienteId;
  String _tipoDiabetes = '';

  // Insulina y Monitoreo
  String _metodoInsulina = 'No especificado';
  String _tipoInsulinaInyeccion = '';
  String _insulinaBasalMarca = '';
  String _insulinaBasalDosis = '';
  String _insulinaBasalHorario = '';
  String _insulinaRapidaMarca = '';
  String _insulinaRapidaPatron = '';
  String _insulinaRapidaHorario = '';
  String _bombaUnidades = '';
  String _bombaFrecuencia = '';
  String _frecuenciaMonitoreo = 'No especificado';

  // Medicamentos
  List<Map<String, dynamic>> _medicamentos = [];

  // Alertas locales
  bool _alertasInsulinaActivadas = true;
  bool _alertasGlucosaActivadas = true;
  bool _alertasMedsActivadas = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();

    if (usuarioId != null) {
      final paciente = await db.obtenerPacientePorUsuario(usuarioId);
      if (paciente != null) {
        _pacienteId = paciente['id'];
        _tipoDiabetes = paciente['tipo_diabetes'] ?? 'No especificado';

        _metodoInsulina = paciente['metodo_insulina'] ?? 'No especificado';
        _insulinaBasalMarca = paciente['insulina_basal_marca'] ?? '';
        _insulinaBasalDosis = paciente['insulina_basal_dosis'] ?? '';
        _insulinaBasalHorario = paciente['insulina_basal_horario'] ?? '';
        _insulinaRapidaMarca = paciente['insulina_rapida_marca'] ?? '';
        _insulinaRapidaPatron = paciente['insulina_rapida_patron'] ?? '';
        _insulinaRapidaHorario = paciente['insulina_rapida_horario'] ?? '';
        _bombaUnidades = paciente['bomba_unidades'] ?? '';
        _bombaFrecuencia = paciente['bomba_frecuencia'] ?? '';
        _frecuenciaMonitoreo = paciente['frecuencia_monitoreo'] ?? 'No especificado';

        if (_insulinaBasalMarca.isNotEmpty && _insulinaRapidaMarca.isNotEmpty) {
          _tipoInsulinaInyeccion = 'Ambas';
        } else if (_insulinaBasalMarca.isNotEmpty) {
          _tipoInsulinaInyeccion = 'Basal';
        } else if (_insulinaRapidaMarca.isNotEmpty) {
          _tipoInsulinaInyeccion = 'Bolo';
        }

        final medsDB = await db.obtenerMedicamentosDePaciente(_pacienteId!);
        _medicamentos = List<Map<String, dynamic>>.from(medsDB);

        if (paciente['med_oral_nombre'] != null && paciente['med_oral_nombre'].toString().isNotEmpty) {
          bool existePrincipal = _medicamentos.any((m) => m['nombre'] == paciente['med_oral_nombre']);
          if (!existePrincipal) {
            _medicamentos.insert(0, {
              'id': -1,
              'nombre': paciente['med_oral_nombre'],
              'gramaje': paciente['med_oral_dosis'] ?? '',
              'proposito': 'Medicamento Principal',
              'frecuencia': 'Habitual'
            });
          }
        }
      }
    }

    if (mounted) setState(() => _cargando = false);
  }

  void _mostrarDialogoEditarInsulina() {
    String tempMetodo = _metodoInsulina.isEmpty ? 'Inyecciones' : _metodoInsulina;
    String tempTipoIny = _tipoInsulinaInyeccion.isEmpty ? 'Ambas' : _tipoInsulinaInyeccion;

    final marcaBasalCtrl = TextEditingController(text: _insulinaBasalMarca);
    final dosisBasalCtrl = TextEditingController(text: _insulinaBasalDosis);
    final horarioBasalCtrl = TextEditingController(text: _insulinaBasalHorario);
    final marcaRapidaCtrl = TextEditingController(text: _insulinaRapidaMarca);
    final patronRapidaCtrl = TextEditingController(text: _insulinaRapidaPatron);
    final horarioRapidaCtrl = TextEditingController(text: _insulinaRapidaHorario);
    final bombaUnidCtrl = TextEditingController(text: _bombaUnidades);
    final bombaFrecCtrl = TextEditingController(text: _bombaFrecuencia);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Editar Esquema de Insulina', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Método de aplicación', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF008CCF)), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ['Inyecciones', 'Bomba', 'No usa'].contains(tempMetodo) ? tempMetodo : 'Inyecciones',
                          isExpanded: true,
                          items: ['Inyecciones', 'Bomba', 'No usa'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setStateDialog(() => tempMetodo = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (tempMetodo == 'Inyecciones') ...[
                      const Text('Tipo de Insulina', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF008CCF)), borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: ['Basal', 'Bolo', 'Ambas'].contains(tempTipoIny) ? tempTipoIny : 'Ambas',
                            isExpanded: true,
                            items: ['Basal', 'Bolo', 'Ambas'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) => setStateDialog(() => tempTipoIny = val!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas') ...[
                        _crearCampo('Marca Insulina Basal', marcaBasalCtrl),
                        const SizedBox(height: 10),
                        _crearCampo('Dosis Diaria (UI)', dosisBasalCtrl),
                        const SizedBox(height: 10),
                        _crearSelectorHora('Horario de Aplicación', horarioBasalCtrl, context, setStateDialog),
                        const SizedBox(height: 15),
                      ],

                      if (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas') ...[
                        _crearCampo('Marca Insulina Rápida', marcaRapidaCtrl),
                        const SizedBox(height: 10),
                        _crearCampo('Patrón de Uso (Bolo)', patronRapidaCtrl),
                        const SizedBox(height: 10),
                        _crearSelectorHora('Horario Habitual', horarioRapidaCtrl, context, setStateDialog),
                      ],
                    ] else if (tempMetodo == 'Bomba') ...[
                      _crearCampo('Unidades Base', bombaUnidCtrl),
                      const SizedBox(height: 10),
                      _crearCampo('Frecuencia/Config.', bombaFrecCtrl),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    final db = DatabaseHelper();
                    final usuarioId = await db.obtenerSesionActiva();
                    if (usuarioId != null) {
                      await db.actualizarPaciente(usuarioId, {
                        'metodo_insulina': tempMetodo,
                        'insulina_basal_marca': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas')) ? marcaBasalCtrl.text : '',
                        'insulina_basal_dosis': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas')) ? dosisBasalCtrl.text : '',
                        'insulina_basal_horario': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas')) ? horarioBasalCtrl.text : '',
                        'insulina_rapida_marca': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas')) ? marcaRapidaCtrl.text : '',
                        'insulina_rapida_patron': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas')) ? patronRapidaCtrl.text : '',
                        'insulina_rapida_horario': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas')) ? horarioRapidaCtrl.text : '',
                        'bomba_unidades': tempMetodo == 'Bomba' ? bombaUnidCtrl.text : '',
                        'bomba_frecuencia': tempMetodo == 'Bomba' ? bombaFrecCtrl.text : '',
                      });
                      await _cargarDatos();
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoEditarMonitoreo() {
    String tempFrecuencia = _frecuenciaMonitoreo;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Protocolo de Monitoreo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Frecuencia indicada por el médico:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF008CCF)), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ['Ayunas y antes de comidas', 'Al despertar y antes de dormir', 'Antes y después de comer', 'Solo si hay síntomas', 'Monitoreo continuo (Sensor)', 'Otro protocolo', 'No especificado'].contains(tempFrecuencia) ? tempFrecuencia : 'Ayunas y antes de comidas',
                          isExpanded: true,
                          items: ['Ayunas y antes de comidas', 'Al despertar y antes de dormir', 'Antes y después de comer', 'Solo si hay síntomas', 'Monitoreo continuo (Sensor)', 'Otro protocolo', 'No especificado'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) => setStateDialog(() => tempFrecuencia = val!),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                  ElevatedButton(
                    onPressed: () async {
                      final db = DatabaseHelper();
                      final usuarioId = await db.obtenerSesionActiva();
                      if (usuarioId != null) {
                        await db.actualizarPaciente(usuarioId, {'frecuencia_monitoreo': tempFrecuencia});
                        await _cargarDatos();
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
                    child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _mostrarDialogoMedicamento({Map<String, dynamic>? medicamentoExistente}) {
    final nombreCtrl = TextEditingController(text: medicamentoExistente?['nombre'] ?? '');
    final gramajeCtrl = TextEditingController(text: medicamentoExistente?['gramaje'] ?? '');
    final propositoCtrl = TextEditingController(text: medicamentoExistente?['proposito'] ?? '');
    final frecuenciaCtrl = TextEditingController(text: medicamentoExistente?['frecuencia'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(medicamentoExistente == null ? 'Añadir Medicamento' : 'Editar Medicamento', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampo('Nombre del Fármaco', nombreCtrl),
                const SizedBox(height: 10),
                _crearCampo('Dosis / Gramaje', gramajeCtrl),
                const SizedBox(height: 10),
                _crearCampo('Frecuencia y Horario', frecuenciaCtrl),
                const SizedBox(height: 10),
                _crearCampo('Propósito / Notas', propositoCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.isEmpty || _pacienteId == null) return;

                final db = DatabaseHelper();

                if (medicamentoExistente == null) {
                  await db.insertarOtroMedicamento({
                    'paciente_id': _pacienteId,
                    'nombre': nombreCtrl.text,
                    'gramaje': gramajeCtrl.text,
                    'frecuencia': frecuenciaCtrl.text,
                    'proposito': propositoCtrl.text,
                  });
                } else if (medicamentoExistente['id'] != -1) {
                  final baseDatos = await db.db;
                  await baseDatos.update('otros_medicamentos', {
                    'nombre': nombreCtrl.text,
                    'gramaje': gramajeCtrl.text,
                    'frecuencia': frecuenciaCtrl.text,
                    'proposito': propositoCtrl.text,
                  }, where: 'id = ?', whereArgs: [medicamentoExistente['id']]);
                }

                await _cargarDatos();
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

  Widget _crearCampo(String label, TextEditingController controlador) {
    return TextField(
      controller: controlador,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  Widget _crearSelectorHora(String label, TextEditingController controlador, BuildContext context, void Function(void Function()) setStateDialog) {
    return InkWell(
      onTap: () async {
        TimeOfDay? horaSeleccionada = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF1C63BB),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (horaSeleccionada != null) {
          setStateDialog(() {
            int horaFormato12 = horaSeleccionada.hourOfPeriod;
            if (horaFormato12 == 0) horaFormato12 = 12;

            final horaStr = horaFormato12.toString().padLeft(2, '0');
            final minutoStr = horaSeleccionada.minute.toString().padLeft(2, '0');
            final periodo = horaSeleccionada.period == DayPeriod.am ? 'AM' : 'PM';

            controlador.text = '$horaStr:$minutoStr $periodo';
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          suffixIcon: const Icon(Icons.access_time, color: Color(0xFF1C63BB)),
        ),
        child: Text(
          controlador.text.isEmpty ? 'Toca para seleccionar hora' : controlador.text,
          style: TextStyle(color: controlador.text.isEmpty ? Colors.grey.shade600 : Colors.black, fontSize: 14),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarMed() {
    _mostrarDialogoMedicamento();
  }

  Widget _filaDetalleMed(String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
        Expanded(flex: 3, child: Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _construirTarjeta({required String titulo, required IconData icono, required VoidCallback onEdit, required Widget contenido}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                      child: Icon(icono, color: const Color(0xFF1C63BB), size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                child: IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0C80EB)), onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          contenido,
        ],
      ),
    );
  }

  Widget _construirSwitch({required String titulo, required String subtitulo, required bool valor, required ValueChanged<bool> onChanged}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE8E8E8))),
      child: SwitchListTile(
        title: Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(subtitulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        value: valor,
        activeColor: const Color(0xFF0C80EB),
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)))
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0xFF1C63BB),
              expandedHeight: 140.0,
              floating: true,
              snap: true,
              pinned: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text('Mis Medicamentos', style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                        SizedBox(height: 5),
                        Text('Gestiona tu esquema de insulina, toma de glucosa y medicamentos orales.', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
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
              // Insulina y Monitoreo
              if (_tipoDiabetes != 'Tipo 2') ...[
                _construirTarjeta(
                    titulo: 'Esquema de Insulina',
                    icono: Icons.colorize,
                    onEdit: _mostrarDialogoEditarInsulina,
                    contenido: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_metodoInsulina == 'Inyecciones') ...[
                            if (_tipoInsulinaInyeccion == 'Basal' || _tipoInsulinaInyeccion == 'Ambas') ...[
                              _filaDetalleMed('Basal (Larga)', _insulinaBasalMarca.isEmpty ? 'No especificado' : '$_insulinaBasalMarca | $_insulinaBasalDosis UI'),
                              if (_insulinaBasalHorario.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                _filaDetalleMed('Aplicación', _insulinaBasalHorario),
                              ],
                              const Divider(height: 25, color: Color(0xFFD2D2D2)),
                            ],
                            if (_tipoInsulinaInyeccion == 'Bolo' || _tipoInsulinaInyeccion == 'Ambas') ...[
                              _filaDetalleMed('Bolo (Rápida)', _insulinaRapidaMarca.isEmpty ? 'No especificado' : '$_insulinaRapidaMarca | $_insulinaRapidaPatron'),
                              if (_insulinaRapidaHorario.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                _filaDetalleMed('Aplicación', _insulinaRapidaHorario),
                              ],
                            ],
                            if (_tipoInsulinaInyeccion.isEmpty) ...[
                              const Text('Configura tu tipo de insulina presionando el botón de editar.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                            ]
                          ] else if (_metodoInsulina == 'Bomba') ...[
                            _filaDetalleMed('Unidades Base', _bombaUnidades.isEmpty ? 'No especificado' : _bombaUnidades),
                            const Divider(height: 25, color: Color(0xFFD2D2D2)),
                            _filaDetalleMed('Configuración', _bombaFrecuencia.isEmpty ? 'No especificado' : _bombaFrecuencia),
                          ] else ...[
                            const Text('No utiliza insulina o no se ha configurado el método.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],

                          if (_metodoInsulina != 'No especificado' && _metodoInsulina != 'No usa') ...[
                            const SizedBox(height: 20),
                            _construirSwitch(
                              titulo: 'Alertas de Insulina',
                              subtitulo: 'Recordatorios para tu esquema',
                              valor: _alertasInsulinaActivadas,
                              onChanged: (val) => setState(() => _alertasInsulinaActivadas = val),
                            ),
                          ]
                        ]
                    )
                ),
                const SizedBox(height: 20),
              ],

              _construirTarjeta(
                  titulo: 'Protocolo de Monitoreo',
                  icono: Icons.monitor_heart,
                  onEdit: _mostrarDialogoEditarMonitoreo,
                  contenido: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_frecuenciaMonitoreo, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        _construirSwitch(
                          titulo: 'Notificaciones de Glucosa',
                          subtitulo: 'Recordatorios según tu protocolo',
                          valor: _alertasGlucosaActivadas,
                          onChanged: (val) => setState(() => _alertasGlucosaActivadas = val),
                        )
                      ]
                  )
              ),
              const SizedBox(height: 25),

              // Medicamentos
              Row(
                children: [
                  const Expanded(
                    child: Text('Fármacos Orales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoAgregarMed,
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Añadir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C63BB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              if (_medicamentos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
                  child: const Text('No tienes medicamentos orales registrados.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              else
                ..._medicamentos.map((med) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5)),
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                            child: const Icon(Icons.medication, color: Color(0xFF1C63BB), size: 28),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${med['nombre']} - ${med['gramaje']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 6),
                                Text('Frecuencia: ${med['frecuencia']}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                if (med['proposito'] != null && med['proposito'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Nota: ${med['proposito']}', style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                                  )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                                child: IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0C80EB), size: 20), onPressed: () => _mostrarDialogoMedicamento(medicamentoExistente: med), padding: const EdgeInsets.all(8), constraints: const BoxConstraints()),
                              ),
                              if (med['id'] != -1) ...[
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                                  child: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 20),
                                      onPressed: () async {
                                        final db = DatabaseHelper();
                                        final baseDatos = await db.db;
                                        await baseDatos.delete('otros_medicamentos', where: 'id = ?', whereArgs: [med['id']]);
                                        await _cargarDatos();
                                      },
                                      padding: const EdgeInsets.all(8), constraints: const BoxConstraints()
                                  ),
                                ),
                              ]
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 10),
              if (_medicamentos.isNotEmpty)
                _construirSwitch(
                  titulo: 'Notificaciones de Fármacos',
                  subtitulo: 'Recordatorios para tomar medicina',
                  valor: _alertasMedsActivadas,
                  onChanged: (val) => setState(() => _alertasMedsActivadas = val),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}