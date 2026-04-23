import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../database/database_helper.dart';

class TabMedicamentosFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const TabMedicamentosFamiliar({super.key, required this.paciente});

  @override
  State<TabMedicamentosFamiliar> createState() => _TabMedicamentosFamiliarState();
}

class _TabMedicamentosFamiliarState extends State<TabMedicamentosFamiliar> {
  bool _cargando = true;
  bool _primeraCarga = true;
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

  // Medicamentos y Registros
  List<Map<String, dynamic>> _medicamentos = [];
  List<Map<String, dynamic>> _historialInsulina = [];

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
    if (_primeraCarga) {
      _tipoDiabetes = widget.paciente['tipo_diabetes'] ?? 'No especificado';
      _metodoInsulina = widget.paciente['metodo_insulina'] ?? 'No especificado';
      _insulinaBasalMarca = widget.paciente['insulina_basal_marca'] ?? '';
      _insulinaBasalDosis = widget.paciente['insulina_basal_dosis'] ?? '';
      _insulinaBasalHorario = widget.paciente['insulina_basal_horario'] ?? '';
      _insulinaRapidaMarca = widget.paciente['insulina_rapida_marca'] ?? '';
      _insulinaRapidaPatron = widget.paciente['insulina_rapida_patron'] ?? '';
      _insulinaRapidaHorario = widget.paciente['insulina_rapida_horario'] ?? '';
      _bombaUnidades = widget.paciente['bomba_unidades'] ?? '';
      _bombaFrecuencia = widget.paciente['bomba_frecuencia'] ?? '';
      _frecuenciaMonitoreo = widget.paciente['frecuencia_monitoreo'] ?? 'No especificado';

      if (_insulinaBasalMarca.isNotEmpty && _insulinaRapidaMarca.isNotEmpty) {
        _tipoInsulinaInyeccion = 'Ambas';
      } else if (_insulinaBasalMarca.isNotEmpty) {
        _tipoInsulinaInyeccion = 'Basal';
      } else if (_insulinaRapidaMarca.isNotEmpty) {
        _tipoInsulinaInyeccion = 'Bolo';
      }
      _primeraCarga = false;
    }

    final medsDB = await db.obtenerMedicamentosDePacienteCuidador(widget.paciente['id']);
    _medicamentos = List<Map<String, dynamic>>.from(medsDB);

    final registrosDB = await db.obtenerRegistrosGlucosaCuidador(widget.paciente['id']);
    _historialInsulina = registrosDB.where((r) {
      final nota = (r['notas'] ?? '').toString();
      return nota.contains('Dosis ADA Calculada:') || nota.contains('Dosis Manual:');
    }).map((r) {
      final nota = r['notas'].toString();
      final regex = RegExp(r'Dosis (?:ADA Calculada|Manual):\s*([0-9.]+)\s*UI');
      final match = regex.firstMatch(nota);
      String dosis = '0';
      if(match != null && match.groupCount >= 1) {
        dosis = match.group(1)!;
      }

      DateTime fechaParseada;
      try {
        fechaParseada = DateTime.parse(r['fecha'].toString());
      } catch (e) {
        fechaParseada = DateTime.now();
      }

      return {
        'dosis': dosis,
        'fecha': fechaParseada,
        'momento': r['momento'] ?? 'No especificado'
      };
    }).toList();

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

                    final datosActualizados = {
                      'metodo_insulina': tempMetodo,
                      'insulina_basal_marca': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas')) ? marcaBasalCtrl.text : '',
                      'insulina_basal_dosis': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas')) ? dosisBasalCtrl.text : '',
                      'insulina_basal_horario': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Basal' || tempTipoIny == 'Ambas')) ? horarioBasalCtrl.text : '',
                      'insulina_rapida_marca': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas')) ? marcaRapidaCtrl.text : '',
                      'insulina_rapida_patron': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas')) ? patronRapidaCtrl.text : '',
                      'insulina_rapida_horario': (tempMetodo == 'Inyecciones' && (tempTipoIny == 'Bolo' || tempTipoIny == 'Ambas')) ? horarioRapidaCtrl.text : '',
                      'bomba_unidades': tempMetodo == 'Bomba' ? bombaUnidCtrl.text : '',
                      'bomba_frecuencia': tempMetodo == 'Bomba' ? bombaFrecCtrl.text : '',
                    };

                    await db.actualizarPacienteCuidador(widget.paciente['id'], datosActualizados);
                    widget.paciente.addAll(datosActualizados);

                    setState(() {
                      _metodoInsulina = tempMetodo;
                      _tipoInsulinaInyeccion = tempTipoIny;
                      _insulinaBasalMarca = marcaBasalCtrl.text;
                      _insulinaBasalDosis = dosisBasalCtrl.text;
                      _insulinaBasalHorario = horarioBasalCtrl.text;
                      _insulinaRapidaMarca = marcaRapidaCtrl.text;
                      _insulinaRapidaPatron = patronRapidaCtrl.text;
                      _insulinaRapidaHorario = horarioRapidaCtrl.text;
                      _bombaUnidades = bombaUnidCtrl.text;
                      _bombaFrecuencia = bombaFrecCtrl.text;
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
      },
    );
  }

  void _mostrarDialogoAgregarDosisInsulina() {
    final dosisCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    String momentoSeleccionado = 'Almuerzo';
    DateTime fechaSeleccionada = DateTime.now();

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Registrar Aplicación', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _crearCampo('Unidades aplicadas (UI)', dosisCtrl, esNumero: true),
                        const SizedBox(height: 15),
                        const Align(alignment: Alignment.centerLeft, child: Text('Momento:', style: TextStyle(fontSize: 13, color: Colors.grey))),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: momentoSeleccionado,
                              isExpanded: true,
                              items: ['Desayuno', 'Almuerzo', 'Cena', 'Merienda', 'Madrugada', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setStateDialog(() => momentoSeleccionado = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _crearCampo('Notas / Insulina utilizada', notasCtrl),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                    ElevatedButton(
                      onPressed: () async {
                        if (dosisCtrl.text.isEmpty) return;
                        final dosis = double.tryParse(dosisCtrl.text) ?? 0.0;
                        if(dosis <= 0) return;

                        final db = DatabaseHelper();
                        String notasFinales = "Dosis Manual: $dosis UI.";
                        if(notasCtrl.text.isNotEmpty) notasFinales += " Notas: ${notasCtrl.text}";

                        await db.insertarRegistroGlucosaCuidador({
                          'paciente_cuidador_id': widget.paciente['id'],
                          'valor': 0,
                          'momento': momentoSeleccionado,
                          'notas': notasFinales,
                          'fecha': fechaSeleccionada.toIso8601String(),
                        });

                        if (mounted) Navigator.pop(context);

                        await _cargarDatos();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aplicación de insulina registrada con éxito.'), backgroundColor: Color(0xFF2E7D32)));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                      child: const Text('Guardar Dosis', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }
          );
        }
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
                      await db.actualizarPacienteCuidador(widget.paciente['id'], {'frecuencia_monitoreo': tempFrecuencia});

                      setState(() => _frecuenciaMonitoreo = tempFrecuencia);
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
                if (nombreCtrl.text.isEmpty) return;

                final db = DatabaseHelper();

                if (medicamentoExistente == null) {
                  await db.insertarOtroMedicamentoCuidador({
                    'paciente_cuidador_id': widget.paciente['id'],
                    'nombre': nombreCtrl.text,
                    'gramaje': gramajeCtrl.text,
                    'frecuencia': frecuenciaCtrl.text,
                    'proposito': propositoCtrl.text,
                  });
                } else {
                  await db.actualizarMedicamentoCuidador(medicamentoExistente['id'], {
                    'nombre': nombreCtrl.text,
                    'gramaje': gramajeCtrl.text,
                    'frecuencia': frecuenciaCtrl.text,
                    'proposito': propositoCtrl.text,
                  });
                }

                if (mounted) Navigator.pop(context);
                await _cargarDatos();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _crearCampo(String label, TextEditingController controlador, {bool esNumero = false}) {
    return TextField(
      controller: controlador,
      keyboardType: esNumero ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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
                  'Gestión de Medicamentos',
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
          body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)))
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _construirHeaderEspecializado(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  const Text('Configura el tipo de insulina presionando el botón de editar.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
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
                                  subtitulo: 'Recordatorios para su esquema',
                                  valor: _alertasInsulinaActivadas,
                                  onChanged: (val) => setState(() => _alertasInsulinaActivadas = val),
                                ),
                              ]
                            ]
                        )
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_metodoInsulina != 'No usa' && _metodoInsulina != 'No especificado') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 10),
                              const Expanded(child: Text('Historial de Aplicaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))),
                              ElevatedButton.icon(
                                onPressed: _mostrarDialogoAgregarDosisInsulina,
                                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                label: const Text('Dosis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          if (_historialInsulina.isEmpty)
                            const Text('No hay aplicaciones de insulina registradas.', style: TextStyle(color: Colors.grey, fontSize: 14))
                          else
                            ..._historialInsulina.take(5).map((registro) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      width: 10, height: 10,
                                      decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${registro['dosis']} UI', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
                                          Text(DateFormat("dd/MM/yyyy 'a las' HH:mm").format(registro['fecha'] as DateTime), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                          Text('Momento: ${registro['momento']}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      ),
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
                              subtitulo: 'Recordatorios según su protocolo',
                              valor: _alertasGlucosaActivadas,
                              onChanged: (val) => setState(() => _alertasGlucosaActivadas = val),
                            )
                          ]
                      )
                  ),
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      const Expanded(
                        child: Text('Fármacos Orales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarDialogoMedicamento(),
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
                      child: Text('No hay medicamentos orales registrados para ${widget.paciente['nombre']}.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
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
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                                    child: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 20),
                                        onPressed: () async {
                                          final db = DatabaseHelper();
                                          await db.eliminarMedicamentoCuidador(med['id']);
                                          await _cargarDatos();
                                        },
                                        padding: const EdgeInsets.all(8), constraints: const BoxConstraints()
                                    ),
                                  )
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
        ],
      ),
    );
  }
}